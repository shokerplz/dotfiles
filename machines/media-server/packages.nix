{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zfs
    git
  ];
}
