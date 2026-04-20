{inputs, ...}: {
  perSystem = {system, ...}: let
    pkgs = import inputs.nixpkgs-current {
      inherit system;
      overlays = [];
      config.allowUnfree = true;
    };
  in {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        nixfmt-rfc-style
        sops
        ssh-to-age
      ];
    };
  };
}
