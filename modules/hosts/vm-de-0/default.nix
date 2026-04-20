{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.vm-de-0 = withSystem "x86_64-linux" ({
    pkgs-current,
    ...
  }:
    inputs.nixpkgs-current.lib.nixosSystem {
      modules = [
        self.nixosModules.vmDe0Configuration
      ];
      specialArgs = {
        inherit pkgs-current;
      };
    });
}
