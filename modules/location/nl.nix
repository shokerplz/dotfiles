{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.locationNL = {
    lib,
    pkgs,
    ...
  }: {
    time.timeZone = "Europe/Amsterdam";
  };
}
