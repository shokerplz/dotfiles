{
  config,
  lib,
  pkgs,
  ...
}: let
  # got this value from `nvidia‑smi --query-supported-clocks`
  gpuMemClk = 9501;
in {
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkForce true;
  };

  # Preserve video memory across suspend/resume - critical for Wayland
  boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

  hardware.nvidia-container-toolkit.enable = true;

  nixpkgs.config.cudaSupport = true;

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Power management - REQUIRED for suspend/resume to work properly
    # This enables the NVIDIA driver to save and restore GPU state during suspend.
    # Without this, resume from suspend often results in a frozen/black screen.
    powerManagement.enable = true;
    # finegrained allows GPU to fully power down when idle, but adds latency
    # when starting games. Keep disabled for faster game launches.
    powerManagement.finegrained = false;

    # Use open source kernel modules (better for newer GPUs)
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Keep GPU initialized for faster response
    nvidiaPersistenced = true;

    # No PRIME configuration needed - this system has only an NVIDIA GPU
    # (no integrated graphics present)
  };

  # This prevents random sound crashes (nvidia should just fix their drivers)
  systemd.services.nvidia-lock-memclk = {
    description = "Lock NVIDIA memory clock to prevent HDMI audio drop‑outs";
    after = [
      "nvidia-persistenced.service"
      "display-manager.service"
    ];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi --lock-memory-clocks=${toString gpuMemClk}";
    };
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
  ];

}
