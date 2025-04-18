{
  config,
  pkgs,
  lib,
  nixpkgs-24-11,
  ...
}:

let
  libfprint-focaltech = pkgs.callPackage ../../packages/libfprint-tod-pocket4.nix { };
in
{

  # Enable fprintd
  services.fprintd = {
    enable = true;
    package = nixpkgs-24-11.fprintd.override {
      libfprint = libfprint-focaltech;
    };
  };
}
