{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.locationHome = {
    lib,
    pkgs,
    ...
  }: {
    time.timeZone = "Europe/Amsterdam";
    nix.settings.substituters = [
      "https://nix-cache.ikovalev.nl"
    ];
    nix.settings.trusted-public-keys = [
      "nix-cache.ikovalev.nl:Krpx8e2jWFxP2mc+AqXkkMX0tGBFCskuRcWUcNZ4DtQ="
    ];
  };
}
