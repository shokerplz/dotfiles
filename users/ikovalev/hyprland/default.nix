# Hyprland desktop environment configuration
# Modular setup for window manager, status bar, launchers, and services
{pkgs, lib, ...}: let
  scripts = import ./scripts.nix {inherit pkgs;};
  hyprlandConfig = import ./hyprland.nix {inherit pkgs scripts;};
  waybarConfig = import ./waybar.nix {};
  wofiConfig = import ./wofi.nix {inherit pkgs;};
  dunstConfig = import ./dunst.nix {};
  servicesConfig = import ./services.nix {};
in
  lib.mkMerge [
    hyprlandConfig
    waybarConfig
    wofiConfig
    dunstConfig
    servicesConfig
  ]
