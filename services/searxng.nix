{
  config,
  pkgs,
  ...
}: {
  services.searx = {
    enable = true;
    
    settings = {
      server = {
        port = 8888;
        bind_address = "0.0.0.0";
        secret_key = "supersecretkeythatshouldbesecret"; # TODO: Move to sops-nix
      };
      ui = {
        theme_args.simple_style = "auto";
      };
    };
  };

  # Open Firewall for local network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 8888 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 8888 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
