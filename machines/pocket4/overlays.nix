{ config, pkgs, ... }:

{
  nixpkgs.overlays = with pkgs; [
    (final: prev: {
      ryzen-smu = prev."ryzen-smu".overrideAttrs (_: rec {
        src = prev.fetchFromGitHub {
          owner = "amkillam";
          repo = "ryzen_smu";
          rev = "c4986ced92cca69e3f4e51caff1402e9baafdee2";
          hash = "sha256-I99bAZArcIPppYnUU6d1IwbhEzYnDGTzSE7Pc7wW5rA=";
        };
        version = "2025-05-09";
      });
    })
  ];

}
