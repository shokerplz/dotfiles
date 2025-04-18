{ pkgs, ... }:

{

  # Install some useful packages
  environment.systemPackages = with pkgs; [
    mangohud
    protonup
    lutris
    wine
    gamemode
  ];

  # Enable gamemode. Usage: in steam specify `gamemoderun %command%`
  programs.gamemode.enable = true;

  hardware.graphics.enable32Bit = true;

  # This is needed for protonup to start
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ikovalev/.steam/root/compatibilitytools.d";
  };
}
