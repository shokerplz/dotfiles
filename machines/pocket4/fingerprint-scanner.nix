{ config, pkgs, lib, ... }:

let
  libfprint-focaltech = pkgs.callPackage ../../packages/libfprint-tod-pocket4.nix {};
  pkgs = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/21808d22b1cda1898b71cf1a1beb524a97add2c4.tar.gz";
  }) {};

  fprintd = pkgs.fprintd;
in {

  # Enable fprintd 
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override {
      libfprint = libfprint-focaltech;
			fprintd = fprintd;
    };
  };
}
