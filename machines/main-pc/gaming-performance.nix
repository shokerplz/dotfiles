{
  config,
  pkgs,
  lib,
  ...
}: let
  # Wrapper script for launching games with NVIDIA + gamemode
  game-run = pkgs.writeShellScriptBin "game-run" ''
    # Force NVIDIA GPU
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only

    # Run with gamemode
    exec ${pkgs.gamemode}/bin/gamemoderun "$@"
  '';
in {
  # =============================================================================
  # GAMING KERNEL - Zen Kernel
  # =============================================================================
  # The Zen kernel is optimized for desktop responsiveness and gaming.
  # It includes patches for better interactivity, reduced latency, and
  # improved scheduler behavior for gaming workloads.
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # =============================================================================
  # KERNEL PARAMETERS - Gaming Optimizations
  # =============================================================================
  boot.kernelParams = [
    # Reduce kernel timer interrupt frequency for smoother frame pacing
    # 1000Hz is good for gaming (vs default 250Hz)
    "tsc=reliable"

    # Disable watchdog timers - not needed for desktop, reduces overhead
    "nowatchdog"
    "nmi_watchdog=0"

    # Transparent Huge Pages - can improve memory performance
    "transparent_hugepage=always"

    # Split lock detection can cause performance issues in games
    "split_lock_detect=off"

    # Prevent kernel from moving running processes between CPUs unnecessarily
    "workqueue.power_efficient=0"

    # NVIDIA-specific: enable PAT (Page Attribute Table) for better GPU memory access
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # =============================================================================
  # SYSCTL TWEAKS - System Performance
  # =============================================================================
  boot.kernel.sysctl = {
    # Virtual memory tweaks for gaming
    "vm.swappiness" = 10; # Prefer RAM over swap
    "vm.vfs_cache_pressure" = 50; # Keep directory/inode caches longer
    "vm.dirty_ratio" = 10; # Percentage of RAM for dirty pages before sync
    "vm.dirty_background_ratio" = 5; # Start background writeback earlier
    "vm.page-cluster" = 0; # Disable readahead for swap (we have zram)

    # Increase max memory map areas (needed for some games and Wine)
    "vm.max_map_count" = 2147483642;

    # Network performance for online gaming (low latency)
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

    # Increase inotify limits for games with many files
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;

    # File handle limits
    "fs.file-max" = 2097152;

    # Kernel scheduler tweaks
    "kernel.sched_autogroup_enabled" = 0; # Disable autogroup for better game priority control
  };

  # =============================================================================
  # ZRAM SWAP - Fast Compressed Memory
  # =============================================================================
  # ZRAM provides fast compressed swap in RAM, reducing I/O latency
  # when memory pressure occurs during gaming
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Best balance of compression and speed
    memoryPercent = 50; # Use up to 50% of RAM for compressed swap
    priority = 100; # Higher priority than disk swap
  };

  # =============================================================================
  # ANANICY-CPP - Automatic Process Nice Daemon
  # =============================================================================
  # Automatically adjusts process priorities for better gaming performance
  # Uses CachyOS rules which are well-maintained and gaming-focused
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    settings = {
      check_freq = 5; # Check every 5 seconds
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

  # =============================================================================
  # GAMEMODE - Enhanced Configuration
  # =============================================================================
  programs.gamemode = {
    enable = lib.mkForce true;
    enableRenice = true; # Allow gamemode to renice processes
    settings = {
      general = {
        renice = 10; # Renice game processes by -10 (higher priority)
        softrealtime = "auto"; # Use soft realtime scheduling when available
        ioprio = 0; # Highest I/O priority for games
        inhibit_screensaver = 1;
      };

      # GPU optimizations for NVIDIA
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1; # Force maximum performance mode
      };

      # Custom scripts
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send -u low 'GameMode' 'Performance mode activated'";
        end = "${pkgs.libnotify}/bin/notify-send -u low 'GameMode' 'Performance mode deactivated'";
      };
    };
  };

  # =============================================================================
  # I/O SCHEDULER - Optimized for NVMe/SSD
  # =============================================================================
  # Use 'none' or 'mq-deadline' for NVMe SSDs
  services.udev.extraRules = ''
    # Set I/O scheduler for NVMe drives
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    # Set I/O scheduler for SATA SSDs
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # Set I/O scheduler for HDDs
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  # =============================================================================
  # ADDITIONAL GAMING PACKAGES
  # =============================================================================
  environment.systemPackages = with pkgs; [
    # Game launcher wrapper (use as: game-run <command>)
    game-run

    # Performance monitoring
    btop
    nvtopPackages.nvidia # GPU monitoring for NVIDIA
    iotop

    # I/O latency testing
    ioping

    # CPU frequency management
    cpupower-gui
  ];

  # Enable cpupower-gui service
  services.cpupower-gui.enable = true;

  # =============================================================================
  # CPU POWER MANAGEMENT
  # =============================================================================
  # Disable power-profiles-daemon if enabled (we manage power via gamemode)
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Set CPU governor to performance for gaming
  # Note: Can also be dynamically changed via gamemode
  powerManagement.cpuFreqGovernor = "performance";

  # =============================================================================
  # REALTIME AUDIO (Optional but recommended for low-latency audio in games)
  # =============================================================================
  security.rtkit.enable = true;

  # Allow users in the 'games' group to use realtime scheduling
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
