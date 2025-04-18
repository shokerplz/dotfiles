{ config, pkgs, lib, ... }:

let
  libfprint-focaltech = pkgs.callPackage ../../packages/libfprint-tod-pocket4.nix {};
in {

  # Enable fprintd 
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override {
      libfprint = libfprint-focaltech;
    };
  };
}
