{ ... }:
{
  flake.nixosModules.serviceFlaresolverr =
    { ... }:
    {
      services.flaresolverr.enable = true;
    };
}
