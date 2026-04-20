{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.pocket4 = withSystem "x86_64-linux" ({
    pkgs-current,
    pkgs-unstable,
    ...
  }:
    inputs.nixpkgs-current.lib.nixosSystem {
      modules = [
        self.nixosModules.pocket4Configuration
      ];
      specialArgs = {
        inherit pkgs-current;
        inherit pkgs-unstable;
      };
    });
}
