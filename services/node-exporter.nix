{ ... }:

{
  # Node exporter service
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    # https://github.com/prometheus/node_exporter?tab=readme-ov-file#collectors
    enabledCollectors = [
      "systemd"
      "ethtool"
      "softirqs"
      "tcpstat"
    ];
  };

  # Node exporter firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 9100 -s 10.0.0.0/16 -j nixos-fw-accept
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 9100 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
