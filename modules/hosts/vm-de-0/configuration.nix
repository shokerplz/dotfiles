{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vmDe0Configuration = {
    lib,
    pkgs-current,
    ...
  }: {
    imports = [
      self.nixosModules.commonDefault
      self.nixosModules.roleServer
      self.nixosModules.locationDE
      self.nixosModules.serviceXrayRelay
      inputs.disko.nixosModules.disko
      ../../../secrets/xray-role-exit.nix
      ./_disko.nix
    ];

    nixpkgs.pkgs = pkgs-current;

    boot.initrd.availableKernelModules = [
      "ahci"
      "sd_mod"
      "sr_mod"
      "virtio_blk"
      "virtio_net"
      "virtio_pci"
      "virtio_scsi"
    ];

    boot.loader.grub.enable = true;

    networking = {
      hostName = "vm-de-0";
      domain = "ikovalev.nl";
      useDHCP = false;
      useNetworkd = true;
      usePredictableInterfaceNames = false;
      networkmanager.enable = lib.mkForce false;
      defaultGateway = {
        address = "5.189.128.1";
        interface = "eth0";
      };
      defaultGateway6 = {
        address = "fe80::1";
        interface = "eth0";
      };
      nameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      interfaces.eth0 = {
        ipv4.addresses = [
          {
            address = "5.189.191.2";
            prefixLength = 18;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a02:c207:2320:6416::1";
            prefixLength = 64;
          }
        ];
      };
    };

    systemd.network.enable = true;
    systemd.network.wait-online.enable = false;

    services.qemuGuest.enable = true;
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [443];

    dotfiles.services.xrayRelay = {
      enable = true;
      role = "exit";
    };

    virtualisation.docker.enable = lib.mkForce false;
    networking.firewall.extraCommands = lib.mkForce "";
    networking.firewall.extraStopCommands = lib.mkForce "";

    system.stateVersion = "25.05";
  };
}
