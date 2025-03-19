{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zfs
    linuxKernel.packages.linux_zen.zfs_2_3
  ];
}
