{
  config,
  pkgs,
  lib,
  ...
}: let
  game-run = pkgs.writeShellScriptBin "game-run" ''
    # Run with gamemode
    exec ${pkgs.gamemode}/bin/gamemoderun "$@"
  '';
in {
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [
    "tsc=reliable"
    "nowatchdog"
    "nmi_watchdog=0"

    "transparent_hugepage=always"

    "split_lock_detect=off"

    "workqueue.power_efficient=0"
  ];

  boot.kernel.sysctl = {
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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    settings = {
      check_freq = 5;
      cgroup_load = true;
      type_load = true;
      rule_load = true;
      apply_nice = true;
      apply_latnice = true;
      apply_ioclass = true;
      apply_ionice = true;
      apply_sched = true;
      apply_oom_score_adj = true;
      apply_cgroup = true;
    };
  };

  programs.gamemode = {
    enable = lib.mkForce true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
        ioprio = 0;
        inhibit_screensaver = 1;
      };

      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1;
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send -u low 'GameMode' 'Performance mode activated'";
        end = "${pkgs.libnotify}/bin/notify-send -u low 'GameMode' 'Performance mode deactivated'";
      };
    };
  };

  services.udev.extraRules = ''
    # Set I/O scheduler for NVMe drives
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    # Set I/O scheduler for SATA SSDs
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # Set I/O scheduler for HDDs
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';
  environment.systemPackages = with pkgs; [
    game-run

    btop
    iotop

    ioping

    cpupower-gui
  ];

  services.cpupower-gui.enable = true;

  services.power-profiles-daemon.enable = lib.mkForce false;

  powerManagement.cpuFreqGovernor = "performance";

  security.rtkit.enable = true;

  security.pam.loginLimits = [
    {
      domain = "@wheel";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "@wheel";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "@wheel";
      type = "soft";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@wheel";
      type = "hard";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@wheel";
      type = "soft";
      item = "nice";
      value = "-20";
    }
    {
      domain = "@wheel";
      type = "hard";
      item = "nice";
      value = "-20";
    }
  ];
}
