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
      capSysNice = false; # Does not work in 2025
    };
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
  };

  programs.steam.package = pkgs.steam.override {
    extraPkgs =
      pkgs': with pkgs'; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib # Provides libstdc++.so.6
        libkrb5
        keyutils
        # Add other libraries as needed
      ];
  };

  # Enable gamemode. Usage: in steam specify `gamemoderun %command%`
  programs.gamemode.enable = true;

  hardware.graphics.enable32Bit = true;

  # This is needed for protonup to start
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ikovalev/.steam/root/compatibilitytools.d";
  };
}
