{
  config,
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    (final: prev: {
      ringboard-custom = nixpkgs-unstable.ringboard.overrideAttrs (oldAttrs: finalAttrs: rec {
        src = nixpkgs-unstable.fetchFromGitHub {
          owner = "shokerplz";
          repo = "clipboard-history";
          rev = "0f7d43369ddc9455f1e9feeb7ea74fd370b2cd27";
          hash = "sha256-TolfZ2jMmEWLuNNhE10UfDDyi8tOcGbjUmmI0lyvxMc=";
        };
        version = "0.12.3-custom";
        cargoDeps = nixpkgs-unstable.rustPlatform.fetchCargoVendor {
          inherit src version;
          hash = "sha256-MFfuUu/hpb6Uaqe21bvXNKRyJazAL5m+Vw/vAeeDYEk=";
        };
      });
    })
  ];
}
