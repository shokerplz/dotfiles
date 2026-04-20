{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.pocket4Configuration = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.commonDefault
      self.nixosModules.commonNFSClient
      self.nixosModules.commonSSH
      self.nixosModules.roleGraphical
      self.nixosModules.roleGaming
      self.nixosModules.roleLaptop
      self.nixosModules.locationHome
      self.nixosModules.serviceNodeExporter
      inputs.nixos-hardware.nixosModules.gpd-pocket-4
      inputs.gpd-fan-driver.nixosModules.default
      inputs.gpd-fp-driver.nixosModules.default
      ./_hardware-configuration.nix
      ./_overlays.nix
      ./_packages.nix
      ./_power.nix
      ./_ai.nix
      ./_fingerprint-scanner.nix
    ];

    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;

    dotfiles.commonDocker.startOnBoot = false;
    dotfiles.commonSSH.startOnBoot = false;

    virtualisation.libvirtd.onBoot = "ignore";

    boot = {
      kernelParams = [
        "amd_iommu=off"
        "amdgpu.gttsize=65536"
        "ttm.pages_limit=67108864"
        "pcie_aspm=force"
        "nmi_watchdog=0"
      ];
      kernel.sysctl = {
        "vm.swappiness" = 10;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "vm.page-cluster" = 0;

        "vm.max_map_count" = 2147483642;

        "net.core.netdev_max_backlog" = 16384;
        "net.core.somaxconn" = 8192;
        "net.core.rmem_default" = 1048576;
        "net.core.rmem_max" = 16777216;
        "net.core.wmem_default" = 1048576;
        "net.core.wmem_max" = 16777216;
        "net.core.optmem_max" = 65536;
        "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        "net.ipv4.tcp_fastopen" = 3;
        "net.ipv4.tcp_tw_reuse" = 1;
        "net.ipv4.tcp_fin_timeout" = 10;
        "net.ipv4.tcp_slow_start_after_idle" = 0;
        "net.ipv4.tcp_mtu_probing" = 1;

        "fs.inotify.max_user_watches" = 524288;
        "fs.inotify.max_user_instances" = 1024;

        "fs.file-max" = 2097152;

        "kernel.sched_autogroup_enabled" = 0;
      };
    };

    networking.hostName = "pocket4";

    networking.networkmanager.dns = "systemd-resolved";
    services.resolved.enable = true;
    networking.nameservers = ["127.0.0.53"];

    hardware.gpd-fan.enable = true;
    hardware.amdgpu.opencl.enable = true;

    systemd.services.fprintd.serviceConfig = {
      PrivateTmp = lib.mkForce false;
      ReadWritePaths = lib.mkForce [
        "/tmp"
        "/sys/devices"
      ];
    };
    systemd.services.fprintd.environment = {
      FP_DEBUG_IMAGES = "1";
      G_MESSAGES_DEBUG = "all";
    };

    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };
    programs.virt-manager.enable = true;

    users.users.ikovalev.extraGroups = [
      "video"
      "render"
      "libvirtd"
      "plugdev"
    ];

    services.openssh = {
      ports = [22];
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        AllowUsers = ["ikovalev"];
      };
    };

    system.stateVersion = "24.11";
  };
}
