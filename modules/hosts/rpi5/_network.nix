{...}: {
  networking.networkmanager.enable = false;
  networking.dhcpcd.enable = false;
  networking.useDHCP = false;

  systemd.network.enable = true;

  systemd.network.networks.end0 = {
    matchConfig.Name = "end0";
    networkConfig = {
      Address = [
        "10.0.1.20/24"
        "10.0.1.99/24"
        "10.0.1.98/24"
      ];
      Gateway = "10.0.1.1";
      DNS = ["10.0.1.1"];
    };
  };

  services.openssh.listenAddresses = [
    {
      addr = "10.0.1.20";
      port = 22;
    }
  ];

  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;

  services.resolved.settings.Resolve.Cache = "no";

  networking.firewall = {
    extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 443 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 80 -j nixos-fw-accept
    '';
    extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 443 -j nixos-fw-accept || true
      iptables -D nixos-fw -p tcp --dport 80 -j nixos-fw-accept || true
    '';
  };
}
