{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.vm-ru-0 = withSystem "x86_64-linux" ({
    pkgs-current,
    ...
  }:
    inputs.nixpkgs-current.lib.nixosSystem {
      modules = [
        self.nixosModules.vmRu0Configuration
      ];
      specialArgs = {
        inherit pkgs-current;
      };
    });
}
