{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.roleGaming = {
    lib,
    pkgs,
    ...
  }: {
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
        capSysNice = false;
      };
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };
    };

    programs.steam.package = pkgs.steam.override {
      extraPkgs = pkgs':
        with pkgs'; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
    };

    programs.gamemode.enable = true;

    hardware.graphics.enable32Bit = true;

    # This is needed for protonup to start
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/ikovalev/.steam/root/compatibilitytools.d";
    };
  };
}
