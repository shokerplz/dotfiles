{ pkgs, ...}:

{
  # Enable steam
  programs.steam.enable = true;

  # Enable gamescope. Usage: in steam specify `gamescope %command%`
  programs.steam.gamescopeSession.enable = true;

  # Install some useful packages
  environment.systemPackages = with pkgs; [
    mangohud
    protonup
    lutris
  ];

  # Enable gamemode. Usage: in steam specify `gamemoderun %command%`
  programs.gamemode.enable = true;

  # This is needed for protonup to start
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ikovalev/.steam/root/compatibilitytools.d";
  };
}