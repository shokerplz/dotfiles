{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.mainPCConfiguration = {
    pkgs,
    lib,
    pkgs-current,
    ...
  }: {
    imports = [
      self.nixosModules.commonDefault
      self.nixosModules.commonNFSClient
      self.nixosModules.commonSSH
      self.nixosModules.roleGraphical
      self.nixosModules.roleGaming
      self.nixosModules.locationHome
      self.nixosModules.serviceNodeExporter
      ./_hardware-configuration.nix
      ./_packages.nix
      ./_power.nix
      ./_amd.nix
      ./_steamvr.nix
      ./_sunshine.nix
      ./_win-pc-conn.nix
    ];

    nixpkgs.pkgs = pkgs-current;

    boot = {
      loader = {
        # Defaults + limit grub selection to 1 second
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 1;
      };
      # Some fixes + performance tweaks
      extraModprobeConfig = ''
        options snd_hda_intel power_save=0 power_save_controller=N enable_msi=1
        softdep btusb pre: mt7925e btmtk
      '';

      kernelPackages = pkgs.linuxPackages_zen;
      kernelParams = [
        "pcie_port_pm=off"
        "pcie_aspm.policy=performance"

        "tsc=reliable"
        "nowatchdog"
        "nmi_watchdog=0"

        "transparent_hugepage=always"

        "split_lock_detect=off"

        "workqueue.power_efficient=0"
      ];
      # Allows to virtualise arm
      binfmt.emulatedSystems = ["aarch64-linux"];
      kernelModules = ["kvm-amd"];

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

    # Speed up boot time
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;

    dotfiles.commonDocker.startOnBoot = false;

    virtualisation = {
      libvirtd.enable = true;
      libvirtd.onBoot = "ignore";
    };

    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    hardware.mediatek-mt7927 = {
      enable = true;
      enableWifi = true;
      enableBluetooth = true;
      disableAspm = true;
    };

    hardware.firmware = [
      (pkgs.runCommand "mediatek-mt7927-bt-firmware-compat" {} ''
        install -Dm644 ${inputs.mt7927.packages.${pkgs.stdenv.hostPlatform.system}.firmware}/lib/firmware/mediatek/mt6639/BT_RAM_CODE_MT6639_2_1_hdr.bin \
          $out/lib/firmware/mediatek/mt7927/BT_RAM_CODE_MT6639_2_1_hdr.bin
      '')
    ];

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x14c3", ATTR{device}=="0x6639", TEST=="link/l1_aspm", ATTR{link/l1_aspm}="0"
    '';

    nix = {
      settings = {
        extra-platforms = ["aarch64-linux"];
      };
    };

    networking.hostName = "main-pc";

    users = {
      extraGroups = {
        "qemu-libvirtd".members = ["ikovalev"];
        libvirtd.members = ["ikovalev"];
      };

      users.ikovalev.group = "ikovalev";
      groups.ikovalev = {};
      users.ikovalev.isNormalUser = true;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.11"; # Did you read the comment?
  };
}
