{...}: {
  flake.nixosModules.serviceSearxNG = {
    config,
    ...
  }: {
    imports = [
      ../../secrets/searxng.nix
    ];

    services.searx = {
      enable = true;

      environmentFile = config.sops.templates.searxng_env.path;

      settings = {
        server = {
          port = 8888;
          bind_address = "0.0.0.0";
          secret_key = "@SEARXNG_SECRET@";
        };
        search = {
          formats = ["html" "json"];
        };
        ui = {
          theme_args.simple_style = "auto";
        };
      };
    };

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8888 -s 10.0.0.0/16 -j nixos-fw-accept
    '';

    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 8888 -s 10.0.0.0/16 -j nixos-fw-accept || true
    '';
  };
}
