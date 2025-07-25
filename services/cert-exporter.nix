{ ... }:
{
  # Cert exporter service
  services.prometheus.exporters.node-cert = {
    enable = true;
    port = 9141;
    includeGlobs = [ "/var/lib/acme/*/*.pem" ];
  };

  # Cert exporter firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 9141 -s 10.0.0.0/16 -j nixos-fw-accept
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 9141 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
