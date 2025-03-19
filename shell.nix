let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
in

pkgs.mkShell {
  name = "Nix Flake dev env";
  packages = with pkgs; [
    sops
    nixfmt-rfc-style
    nil
    nixfmt-tree
  ];
}
