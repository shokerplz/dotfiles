{ pkgs, ... }:

{

  # Install some useful packages
  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    lutris
    heroic
    wine
    gamemode
  ];

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };

  # Enable gamemode. Usage: in steam specify `gamemoderun %command%`
  programs.gamemode.enable = true;

  hardware.graphics.enable32Bit = true;

  # This is needed for protonup to start
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ikovalev/.steam/root/compatibilitytools.d";
  };
}
