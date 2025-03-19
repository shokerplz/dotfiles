{ config, pkgs, ... }:

{
  # Speedtest exporter service
  virtualisation.oci-containers = {
    containers = {
      speedtest-exporter = {
        image = "ghcr.io/miguelndecarvalho/speedtest-exporter";
        extraOptions = [
          "--network=monitoring"
          "--health-cmd=wget --no-verbose --tries=1 --spider http://0.0.0.0:\${SPEEDTEST_PORT:=9798}/"
        ];
      };
    };
  };
}
