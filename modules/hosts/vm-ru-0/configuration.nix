{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.vmRu0Configuration = {
    lib,
    pkgs-current,
    ...
  }: {
    imports = [
      self.nixosModules.commonDefault
      self.nixosModules.roleServer
      self.nixosModules.locationRU
      self.nixosModules.serviceXrayRelay
      inputs.disko.nixosModules.disko
      ../../../secrets/xray-role-entry.nix
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
      hostName = "vm-ru-0";
      domain = "ikovalev.nl";
      useDHCP = false;
      useNetworkd = true;
      usePredictableInterfaceNames = false;
      networkmanager.enable = lib.mkForce false;
      nameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      defaultGateway = {
        address = "130.49.173.1";
        interface = "eth0";
      };
      interfaces.eth0 = {
        ipv4.addresses = [
          {
            address = "130.49.173.113";
            prefixLength = 24;
          }
        ];
      };
    };

    systemd.network.enable = true;
    systemd.network.wait-online.enable = false;

    services.qemuGuest.enable = true;

    dotfiles.services.xrayRelay = {
      enable = true;
      role = "entry";
    };

    virtualisation.docker.enable = lib.mkForce false;
    networking.firewall.extraCommands = lib.mkForce "";
    networking.firewall.extraStopCommands = lib.mkForce "";

    system.stateVersion = "25.05";
  };
}
