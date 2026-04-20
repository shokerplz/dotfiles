{
  self,
  inputs,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.rpi5 = withSystem "aarch64-linux" ({
    system,
    pkgs-current,
    ...
  }:
    inputs.nixpkgs-current.lib.nixosSystem {
      modules = [
        self.nixosModules.rpi5Configuration
      ];
      specialArgs = {
        inherit pkgs-current;
        pkgs-old = import inputs.nixpkgs-25-05 {
          inherit system;
          config.allowUnfree = true;
        };
      };
    });
}
