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
        remotePlay.openFirewall = true;
      };
    };

    programs.steam.package = pkgs.steam.override {
      extraPkgs = pkgs':
        with pkgs'; [
          libxcursor
          libxi
          libxinerama
          libxscrnsaver
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
