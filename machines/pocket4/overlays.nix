{
  config,
  pkgs,
  ...
}: {
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
      gamescope = let
        oldPkgs = import (prev.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "3e2cf88148e732abc1d259286123e06a9d8c964a";
          hash = "sha256-gDcMJdnBJg7ncP+eqENwH9pOW0azcCOW5y50N+jKdL8=";
        }) {inherit (prev) system;};
      in
        oldPkgs.gamescope;
      linux-firmware = let
        oldPkgs = import (prev.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          rev = "159d23cb00fa98f259c78cafc29c2e1fdf7feb4e";
          hash = "sha256-ZaekwmNPt/WQmkRGXoV9tL9Dixnmm2VhnTyNyFMN40I=";
        }) {inherit (prev) system;};
      in
        oldPkgs.linux-firmware;
    })
  ];
}
