{
  config,
  pkgs,
  inputs,
  ...
}: let
  arrBaseDir = "/mnt/zfs-pool0/kino";
  arrServices = [
    "bazarr"
    "prowlarr"
    "sonarr"
    "radarr"
  ];
  sonarrSearchScript = pkgs.writeShellScriptBin "sonarr-missing-search" ''
    set -euo pipefail
    export PATH="${pkgs.curl}/bin:${pkgs.jq}/bin:${pkgs.coreutils}/bin:$PATH"

    API_KEY=$(cat ${config.sops.secrets.sonarrApiKey.path})
    BASE_URL="http://127.0.0.1:8989/sonarr/api/v3"

    # Check for missing episodes aired in the last 7 days
    CUTOFF_DATE=$(date -d "7 days ago" -u +"%Y-%m-%dT%H:%M:%SZ")

    # Fetch currently queued episodes to avoid redundant searches
    QUEUE_RESPONSE=$(curl -s -H "X-Api-Key: $API_KEY" "$BASE_URL/queue")
    QUEUED_IDS=$(echo "$QUEUE_RESPONSE" | jq -c '[.records[].episodeId] | unique')

    # Fetch missing episodes, sorted by air date descending
    RESPONSE=$(curl -s -H "X-Api-Key: $API_KEY" "$BASE_URL/wanted/missing?pageSize=100&sortKey=airDateUtc&sortDirection=descending")

    # Filter IDs for episodes aired after cutoff AND not in queue
    EPISODE_IDS=$(echo "$RESPONSE" | jq -c --arg cutoff "$CUTOFF_DATE" --argjson queued "$QUEUED_IDS" '[.records[] | select(.airDateUtc >= $cutoff) | select(.id as $id | $queued | index($id) | not) | .id]')

    # Trigger search if there are episodes
    if [ "$EPISODE_IDS" != "[]" ]; then
       echo "Triggering search for recent missing episodes..."
       curl -s -X POST \
         -H "X-Api-Key: $API_KEY" \
         -H "Content-Type: application/json" \
         -d "{\"name\": \"EpisodeSearch\", \"episodeIds\": $EPISODE_IDS}" \
         "$BASE_URL/command" > /dev/null
    fi
  '';
in {
  imports = [
    ./qbittorrent.nix
    ./nzbget.nix
    ../secrets/arr.nix
  ];

  system.activationScripts.createArrDirs = ''
    mkdir -p /mnt/zfs-pool0/kino/{${builtins.concatStringsSep "," arrServices}}/config
    chgrp -R arr /mnt/zfs-pool0/kino/{${builtins.concatStringsSep "," arrServices}}/config
    chgrp -R arr /mnt/zfs-pool0/kino/data
    find /mnt/zfs-pool0/kino/data -type d -exec chmod g+wx {} +
    chown sonarr /mnt/zfs-pool0/kino/sonarr/config
    chown radarr /mnt/zfs-pool0/kino/radarr/config
  '';

  # Create arr group
  users.groups.arr = {};

  # Arr services
  services.radarr = {
    enable = true;
    group = "arr";
    dataDir = "${arrBaseDir}/radarr/config";
    environmentFiles = [
      config.sops.templates."radarr_env".path
    ];
  };
  services.sonarr = {
    enable = true;
    group = "arr";
    dataDir = "${arrBaseDir}/sonarr/config";
    environmentFiles = [
      config.sops.templates."sonarr_env".path
    ];
  };
  services.prowlarr = {
    enable = true;
  };
  services.bazarr = {
    enable = true;
    group = "arr";
  };
  services.jellyseerr = {
    enable = true;
  };

  # Download clients
  services.nzbget.enable = true;
  services.qbittorrent.enable = true;

  # Search missing episodes sonarr
  systemd.services.sonarr-missing-search = {
    description = "Trigger Sonarr Missing Episode Search";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${sonarrSearchScript}/bin/sonarr-missing-search";
    };
    wants = ["network-online.target"];
    after = ["network-online.target"];
  };

  systemd.timers.sonarr-missing-search = {
    description = "Run Sonarr Missing Episode Search every 30 minutes";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "30m";
    };
  };

  # Arr stack firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 5080 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 6789 -s 10.0.0.0/16 -j nixos-fw-accept
    iptables -A nixos-fw -p tcp --dport 5055 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 7878 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 8989 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 9696 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 6767 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 5080 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 6789 -s 10.0.0.0/16 -j nixos-fw-accept || true
    iptables -D nixos-fw -p tcp --dport 5055 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
