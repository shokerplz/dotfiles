{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.media-server = withSystem "x86_64-linux" ({
    pkgs-current,
    pkgs-unstable,
    ...
  }:
    inputs.nixpkgs-current.lib.nixosSystem {
      modules = [
        self.nixosModules.mediaServerConfiguration
      ];
      specialArgs = {
        inherit pkgs-current;
        inherit pkgs-unstable;
      };
    });
}
