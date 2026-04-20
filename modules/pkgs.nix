{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.currentPkgs = {pkgs-current, ...}: {
    nixpkgs.pkgs = pkgs-current;
  };

  perSystem = {
    config,
    system,
    ...
  }: let
    currentPkgs = import inputs.nixpkgs-current {
      inherit system;
      overlays = [];
      config = {
        allowUnfree = true;
      };
    };

    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      overlays = [];
      config = {
        allowUnfree = true;
      };
    };
  in {
    _module.args = {
      pkgs = currentPkgs;
      pkgs-current = currentPkgs;
      pkgs-unstable = unstablePkgs;
    };

    packages.nixos-anywhere-zram = currentPkgs.callPackage ../packages/nixos-anywhere-zram.nix {
      upstream = inputs.nixos-anywhere.packages.${system}.default;
    };

    apps.nixos-anywhere-zram = {
      type = "app";
      program = "${config.packages.nixos-anywhere-zram}/bin/nixos-anywhere-zram";
    };
  };
}
