{pkgs, ...}: {
  boot.kernelParams = [
    "amdgpu.freesync_video=0"
  ];

  environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1";

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.amdgpu.opencl.enable = true;

  users.users.ikovalev.extraGroups = [
    "video"
    "render"
  ];

  environment.systemPackages = with pkgs; [
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];
}
