{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.main-pc = withSystem "x86_64-linux" ({
    pkgs-current,
    pkgs-unstable,
    ...
  }:
    inputs.nixpkgs-current.lib.nixosSystem {
      modules = [
        self.nixosModules.mainPCConfiguration
        inputs.mt7927.nixosModules.default
      ];
      specialArgs = {
        inherit pkgs-unstable;
        inherit pkgs-current;
      };
    });
}
