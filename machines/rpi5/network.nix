{

  ...
}:

{
  # Disable networkmanager and dhcpd to allow 2 ips on one interface
  networking.networkmanager.enable = false;
  networking.dhcpcd.enable = false;

  # Enable systemd network
  systemd.network.enable = true;

  # Set static ips
  systemd.network.networks."end0" = {
    matchConfig.Name = "end0";
    networkConfig = {
      Address = [
        "10.0.1.20/24" # MACHINE'S IP
        "10.0.1.99/24" # PUBLIC FORWARDED IP
        "10.0.1.98/24" # PRIVATE IP FOR GITLAB
      ];
      Gateway = "10.0.1.1";
      DNS = [ "10.0.1.1" ];
    };
  };

  # Listen ONLY on machine's IP
  services.openssh.listenAddresses = [
    {
      addr = "10.0.1.20";
      port = 22;
    }
  ];

  # Disable caching DNS queries (needed for LB)
  services.resolved.extraConfig = ''
    Cache = no
  '';

  # Allow HTTP + HTTPS for LB
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
