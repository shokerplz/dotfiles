{
  config,
  pkgs,
  lib,
  ...
}: let
  docker = config.virtualisation.oci-containers.backend;
  dockerBin = "${pkgs.${docker}}/bin/${docker}";
in {
  systemd.services.docker-monitoring-network = {
    description = "Create Docker monitoring network";

    wantedBy = ["multi-user.target"];

    requires = ["${docker}.service"];
    after = ["${docker}.service"];

    partOf = ["${docker}.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      for i in $(seq 1 30); do
        if ${dockerBin} info >/dev/null 2>&1; then
          break
        fi
        sleep 1
      done

      if ! ${dockerBin} info >/dev/null 2>&1; then
        echo "Docker did not become ready after 30 seconds"
        exit 1
      fi

      ${dockerBin} network inspect monitoring >/dev/null 2>&1 || \
        ${dockerBin} network create monitoring
    '';
  };
}
