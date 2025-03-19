{ config, pkgs, ... }:

{
  # Node exporter service
  virtualisation.oci-containers = {
    containers = {
      node-exporter = {
        image = "quay.io/prometheus/node-exporter:latest";
        cmd = [ "--path.rootfs=/host" ];
        extraOptions = [
          "--pid=host"
        ];
        ports = [ "9100:9100/tcp" ];
        volumes = [ "/:/host:ro,rslave" ];
      };
    };
  };

  # Node exporter firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 9100 -s 10.0.0.0/16 -j nixos-fw-accept
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 9100 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
