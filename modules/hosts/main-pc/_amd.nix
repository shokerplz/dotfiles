{pkgs-current, ...}: {
  environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1";

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.amdgpu.opencl.enable = true;

  users.users.ikovalev.extraGroups = [
    "video"
    "render"
  ];

  environment.systemPackages = with pkgs-current; [
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
  ];
}
