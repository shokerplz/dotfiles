{pkgs, ...}: {
  services.xserver.videoDrivers = ["amdgpu" "nvidia"];

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
