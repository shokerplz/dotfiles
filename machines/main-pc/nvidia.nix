{
  config,
  lib,
  pkgs,
  ...
}:

let
  # got this value from `nvidia‑smi --query-supported-clocks`
  gpuMemClk = 9501;
in

{

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkForce true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia-container-toolkit.enable = true;

  nixpkgs.config.cudaSupport = true;

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    nvidiaPersistenced = true;
    prime = {
      offload.enable = true;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # This prevents random sound crashes (nvidia should just fix their drivers)
  systemd.services.nvidia-lock-memclk = {
    description = "Lock NVIDIA memory clock to prevent HDMI audio drop‑outs";
    after       = [ "nvidia-persistenced.service" "display-manager.service" ];
    wantedBy    = [ "multi-user.target" ];
    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi --lock-memory-clocks=${toString gpuMemClk}";
    };
  };

  environment.systemPackages = with pkgs; [
    cudatoolkit
  ];

}
