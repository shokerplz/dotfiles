{ config, pkgs, ... }:

{
  # Default packages that should be installed everywhere
  environment.systemPackages = with pkgs; [
    neovim
    wget
    tcpdump
    htop
    curl
    acpi
    smartmontools
  ];
}
