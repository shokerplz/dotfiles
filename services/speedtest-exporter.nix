{ config, pkgs, ... }:

{

  imports = [
    ../modules/speedtest-exporter.nix
  ];

  config.services.speedtest-exporter = {
    enable = true;
    acceptOoklaTerms = true;
    cacheSeconds = 3600;
  };

  config.nixpkgs.overlays = [
    (final: prev: {
      speedtest-exporter = final.callPackage ../packages/speedtest-exporter.nix { };
    })
  ];
}
