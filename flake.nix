{
  inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-24-11.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-25-05.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-current.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-local-cache.url = "git+ssh://gitlab@git.ikovalev.nl/nix/nix-local-cache.git";

    gpd-fan-driver.url = "github:Cryolitia/gpd-fan-driver/main";

    gpd-fp-driver.url = "github:shokerplz/ft9362-driver/master";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
    } (inputs.import-tree [./modules]);
}
