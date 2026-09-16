#!/usr/bin/env python3
"""Bounded, local application checks; only fixed labels reach the textfile."""

import json
import os
from pathlib import Path
import sys
import tempfile
import time
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET


MAX_RESPONSE = 2 * 1024 * 1024
QUEUE_LIMIT = 1000
INDEXER_OUTAGE_CHECKS = {"IndexerStatusCheck", "IndexerLongTermStatusCheck"}
GITLAB_DEPENDENCIES = ("database", "redis", "gitaly", "application")
REDIS_CHECKS = {
    name + "_check" for name in (
        "action_cable", "cache", "concurrency_limit", "db_load_balancing",
        "feature_flag", "queues", "queues_metadata", "rate_limiting",
        "repository_cache", "sessions", "shared_state", "trace_chunks",
        "chat", "workhorse", "redis",
    )
}


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def request_json(url, key=None, method="GET", timeout=5, allowed_statuses=(200,)):
    headers = {"Accept": "application/json"}
    if key:
        headers["X-Api-Key"] = key
    request = urllib.request.Request(
        url, headers=headers, method=method,
        data=b"" if method == "POST" else None,
    )
    # Never forward an API key via redirects or a process-wide proxy setting.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}), NoRedirect())
    try:
        response = opener.open(request, timeout=timeout)
    except urllib.error.HTTPError as error:
        if error.code not in allowed_statuses:
            raise
        response = error
    with response as response:
        if response.status not in allowed_statuses:
            raise ValueError("unexpected status")
        body = response.read(MAX_RESPONSE + 1)
    if len(body) > MAX_RESPONSE:
        raise ValueError("response too large")
    return json.loads(body)


def arr_connection(service, credentials):
    name = service["service"]
    if name not in ("sonarr", "radarr", "prowlarr"):
        raise ValueError("unknown service")
    root = ET.parse(credentials / (name + "-config")).getroot()
    port = int(root.findtext("Port", ""))
    base = root.findtext("UrlBase", "").strip().rstrip("/")
    if not 1 <= port <= 65535 or (base and not base.startswith("/")):
        raise ValueError("invalid address")
    if any(c in base for c in "?#\r\n"):
        raise ValueError("invalid base path")
    if service.get("apiKeyCredential"):
        key = (credentials / service["apiKeyCredential"]).read_text().strip()
    else:
        key = root.findtext("ApiKey", "").strip()
    if not key or any(c in key for c in "\r\n"):
        raise ValueError("missing API key")
    version = "v1" if name == "prowlarr" else "v3"
    return f"http://127.0.0.1:{port}{base}/api/{version}", key


def health_result(data):
    if not isinstance(data, list):
        raise ValueError("invalid health response")
    counts = dict.fromkeys(("notice", "warning", "error"), 0)
    actionable = False
    for issue in data:
        severity = issue["type"]
        if severity not in (*counts, "ok"):
            raise ValueError("invalid severity")
        if severity != "ok":
            counts[severity] += 1
        source = issue.get("source")
        wiki = issue.get("wikiUrl")
        # RSS/search checks also report missing configuration, which must still alert.
        provider_outage = source in INDEXER_OUTAGE_CHECKS or (
            source in ("IndexerRssCheck", "IndexerSearchCheck")
            and isinstance(wiki, str)
            and wiki.partition("#")[2] == "indexers-are-unavailable-due-to-failures"
        )
        actionable |= severity in ("warning", "error") and not provider_outage
    return not actionable, counts


def queue_result(data):
    records = data["records"]
    total = data["totalRecords"]
    if (not isinstance(records, list) or type(total) is not int
            or total != len(records) or total > QUEUE_LIMIT):
        raise ValueError("incomplete queue response")
    counts = dict.fromkeys(("total", "warning", "error", "blocked", "failed"), 0)
    counts["total"] = total
    ids = set()
    for item in records:
        if type(item["id"]) is not int or item["id"] in ids:
            raise ValueError("invalid queue identifier")
        ids.add(item["id"])
        status = item["trackedDownloadStatus"]
        state = item["trackedDownloadState"]
        if status not in ("ok", "warning", "error") or state not in (
            "downloading", "importBlocked", "importPending", "importing",
            "imported", "failedPending", "failed", "ignored",
        ):
            raise ValueError("invalid queue state")
        if status != "ok":
            counts[status] += 1
        counts["blocked"] += state == "importBlocked"
        counts["failed"] += state in ("failedPending", "failed")
    return not any(counts[s] for s in ("warning", "error", "blocked", "failed")), counts


def download_clients_result(configured, results):
    # ProviderControllerBase.TestAll skips settings-invalid enabled providers.
    # Require full coverage as well as isValid and empty validationFailures.
    if not isinstance(configured, list) or not isinstance(results, list):
        raise ValueError("invalid client response")
    expected = {}
    configured_ids = set()
    for client in configured:
        identifier = client["id"]
        if (type(identifier) is not int or identifier in configured_ids
                or type(client["enable"]) is not bool):
            raise ValueError("invalid client configuration")
        configured_ids.add(identifier)
        if client["enable"]:
            implementation = client["implementation"]
            if not isinstance(implementation, str) or not implementation:
                raise ValueError("invalid client implementation")
            expected[identifier] = {"QBittorrent": "qbittorrent", "Nzbget": "nzbget"}.get(implementation, "other")
    seen = {}
    for result in results:
        identifier = result["id"]
        if (type(identifier) is not int or identifier in seen
                or type(result["isValid"]) is not bool
                or not isinstance(result["validationFailures"], list)):
            raise ValueError("invalid client test result")
        seen[identifier] = result["isValid"] and not result["validationFailures"]
    if set(seen) - set(expected):
        raise ValueError("unexpected client test result")
    checked = {"configuration": bool(expected) and set(seen) == set(expected)}
    for dependency in sorted(set(expected.values())):
        identifiers = [identifier for identifier, group in expected.items() if group == dependency]
        if all(identifier in seen for identifier in identifiers):
            checked[dependency] = all(seen[identifier] for identifier in identifiers)
    return checked


def gitlab_result(data):
    if not isinstance(data, dict) or not data:
        raise ValueError("invalid readiness response")
    overall = data.get("status")
    if overall not in (None, "ok", "failed"):
        raise ValueError("invalid overall readiness status")
    components = {}
    for name, checks in data.items():
        if name == "status":
            continue
        if not isinstance(checks, list) or not checks:
            raise ValueError("invalid readiness component")
        statuses = [check["status"] for check in checks]
        if any(status not in ("ok", "failed") for status in statuses):
            raise ValueError("invalid readiness status")
        components[name] = all(status == "ok" for status in statuses)
    redis = {name: ok for name, ok in components.items()
             if name in REDIS_CHECKS or name.startswith(("redis_", "queue_shard"))}
    if not redis or not {"db_check", "gitaly_check"} <= components.keys():
        raise ValueError("missing readiness components")
    if overall is None and "master_check" not in components:
        raise ValueError("missing overall readiness status")
    return {
        "database": components["db_check"],
        "redis": all(redis.values()),
        "gitaly": components["gitaly_check"],
        "application": overall != "failed" and all(ok for name, ok in components.items() if name not in redis and name not in ("db_check", "gitaly_check")),
    }


def check_metrics(service, check, dependency, success, started, duration):
    labels = f'service="{service}",check="{check}",dependency="{dependency}"'
    return [
        f"service_check_success{{{labels}}} {int(success)}",
        f"service_check_last_run_timestamp_seconds{{{labels}}} {started:.3f}",
        f"service_check_duration_seconds{{{labels}}} {duration:.6f}",
    ]


def collect(config, credentials):
    lines = [
        "# HELP service_check_success Actionable application check result; external indexer outages do not fail native health.",
        "# TYPE service_check_success gauge",
        "# HELP service_check_last_run_timestamp_seconds Poll start time, not the age of cached application state.",
        "# TYPE service_check_last_run_timestamp_seconds gauge",
        "# HELP service_check_duration_seconds Time spent polling or testing the application.",
        "# TYPE service_check_duration_seconds gauge",
        "# HELP arr_health_issues All cached native health issues, including informational external indexer outages.",
        "# TYPE arr_health_issues gauge",
        "# HELP arr_queue_items Items in the application's cached queue response; state counts may overlap.",
        "# TYPE arr_queue_items gauge",
    ]
    for service in config["arr"]:
        name = service["service"]
        if name not in ("sonarr", "radarr", "prowlarr"):
            raise ValueError("unknown service")
        checks = [("native_health", "application")]
        if name != "prowlarr":
            checks += [("queue", "downloads"), ("download_clients", "configuration")]
        for check, dependency in checks:
            started, monotonic = time.time(), time.monotonic()
            results, extra = {dependency: False}, []
            try:
                base, key = arr_connection(service, credentials)
                if check == "native_health":
                    success, counts = health_result(request_json(base + "/health", key))
                    results[dependency] = success
                    extra = [f'arr_health_issues{{service="{name}",severity="{s}"}} {n}' for s, n in counts.items()]
                elif check == "queue":
                    success, counts = queue_result(request_json(
                        base + f"/queue?page=1&pageSize={QUEUE_LIMIT}&includeUnknownSeriesItems=true&includeUnknownMovieItems=true", key,
                    ))
                    results[dependency] = success
                    extra = [f'arr_queue_items{{service="{name}",state="{s}"}} {n}' for s, n in counts.items()]
                else:
                    clients = request_json(base + "/downloadclient", key)
                    tested = request_json(base + "/downloadclient/testall", key, "POST", timeout=15, allowed_statuses=(200, 400))
                    results = download_clients_result(clients, tested)
            except Exception:
                # Exceptions and response bodies may contain API keys or passwords.
                # A failed check replaces the previous result without logging them.
                pass
            duration = time.monotonic() - monotonic
            for dependency, success in results.items():
                lines.extend(check_metrics(name, check, dependency, success, started, duration))
            lines.extend(extra)
    if config.get("gitlab"):
        started, monotonic = time.time(), time.monotonic()
        results = {"api": False}
        try:
            components = gitlab_result(request_json(config["gitlab"] + "/-/readiness?all=1", timeout=10, allowed_statuses=(200, 503)))
            results = {"api": True, **components}
        except Exception:
            pass
        duration = time.monotonic() - monotonic
        for dependency, success in results.items():
            lines.extend(check_metrics("gitlab", "readiness", dependency, success, started, duration))
    return "\n".join(lines) + "\n"


def atomic_write(path, content):
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, prefix=".service-health-", delete=False) as output:
            temporary = output.name
            output.write(content)
            output.flush()
            os.fsync(output.fileno())
            os.fchmod(output.fileno(), 0o644)
        os.replace(temporary, path)
    finally:
        if temporary and os.path.exists(temporary):
            os.unlink(temporary)


def main():
    try:
        config = json.loads(Path(sys.argv[1]).read_text())
        credentials = Path(os.environ.get("CREDENTIALS_DIRECTORY", "/run/credentials/service-health-checks.service"))
        atomic_write(Path(sys.argv[2]), collect(config, credentials))
    except Exception:
        print("service-health-checks: collector failed", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
