{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.locationRU = {
    lib,
    pkgs,
    ...
  }: {
    time.timeZone = "Europe/Moscow";
  };
}
