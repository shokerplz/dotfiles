{self, ...}: {
  flake.nixosModules.rpi5Configuration = {
    pkgs-current,
    pkgs-old,
    ...
  }: {
    imports = [
      self.nixosModules.commonDefault
      self.nixosModules.commonSSH
      self.nixosModules.locationHome
      self.nixosModules.serviceGrafana
      self.nixosModules.servicePrometheus
      self.nixosModules.servicePromtail
      self.nixosModules.serviceSpeedtestExporter
      self.nixosModules.serviceNodeExporter
      self.nixosModules.serviceCertExporter
      self.nixosModules.serviceCloudflareDDNS
      self.nixosModules.serviceReverseProxy
      ./_hardware-configuration.nix
      ./_docker.nix
      ./_packages.nix
      ./_network.nix
    ];

    nixpkgs.pkgs = pkgs-current;

    networking = {
      hostName = "rpi5";
      domain = "home";
    };

    boot.loader = {
      efi.canTouchEfiVariables = false;
      systemd-boot.enable = true;
    };

    boot.kernelPackages = pkgs-old.linuxPackages_rpi4;

    dotfiles.services.reverseProxy.enable = true;
    dotfiles.services.reverseProxy.sites = {
      builder.enable = true;
      files.enable = true;
      git.enable = true;
      homeAssistant.enable = true;
      kino.enable = true;
      monitoring.enable = true;
      n8n.enable = true;
      nixCache.enable = true;
      searxng.enable = true;
    };

    system.stateVersion = "24.11";
  };
}
