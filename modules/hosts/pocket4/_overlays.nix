{...}: {
  nixpkgs.overlays = [
    (final: prev: let
      mkPinnedPkgs = {
        rev,
        hash,
      }:
        import (prev.fetchFromGitHub {
          owner = "NixOS";
          repo = "nixpkgs";
          inherit rev hash;
        }) {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
    in {
      gamescope = (mkPinnedPkgs {
        rev = "3e2cf88148e732abc1d259286123e06a9d8c964a";
        hash = "sha256-gDcMJdnBJg7ncP+eqENwH9pOW0azcCOW5y50N+jKdL8=";
      }).gamescope;

      linux-firmware = (mkPinnedPkgs {
        rev = "159d23cb00fa98f259c78cafc29c2e1fdf7feb4e";
        hash = "sha256-ZaekwmNPt/WQmkRGXoV9tL9Dixnmm2VhnTyNyFMN40I=";
      }).linux-firmware;
    })
  ];
}
