{
  description = "NixOS configuration";

  inputs = {
    # Secret manager for Nix
    sops-nix.url = "github:Mic92/sops-nix";
    # Nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # NixPKGs nixos24.11
    nixpkgs-24-11.url = "github:nixos/nixpkgs/nixos-24.11";
    # NixPKGs nixos25.05
    nixpkgs-25-05.url = "github:nixos/nixpkgs/nixos-25.05";
    # NixPKGs that I am currently using
    nixpkgs-current.url = "github:nixos/nixpkgs/nixos-25.11";
    # NixOS Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Authentik
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
    };
    nix-local-cache.url = "git+ssh://gitlab@git.ikovalev.nl/nix/nix-local-cache.git";
    gpd-fan-driver.url = "github:Cryolitia/gpd-fan-driver/main";
    gpd-fp-driver.url = "github:shokerplz/ft9362-driver/master";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-current";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-current";
    };
  };

  outputs = {
    self,
    nixpkgs-unstable,
    nixpkgs-24-11,
    nixpkgs-25-05,
    nixpkgs-current,
    sops-nix,
    nixos-hardware,
    home-manager,
    authentik-nix,
    nvf,
    noctalia,
    nix-local-cache,
    gpd-fan-driver,
    gpd-fp-driver,
  }: let
    makeDevShell = system: let
      pkgs = import nixpkgs-current {
        inherit system;
      };
    in
      pkgs.mkShell {
        name = "Nix Flake dev env";
        packages = with pkgs; [
          sops
          nixfmt-rfc-style
          nixd
          nixfmt-tree
        ];
      };
  in {
    packages."x86_64-linux" = {
      my-neovim =
        (nvf.lib.neovimConfiguration {
          pkgs = nixpkgs-unstable.legacyPackages."x86_64-linux";
          modules = [./packages/nvf-config.nix];
        }).neovim;
      ssh-toggle = nixpkgs-current.legacyPackages."x86_64-linux".callPackage ./packages/ssh-toggle {};
    };

    nixosConfigurations = {
      pocket4 = nixpkgs-current.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./common/default.nix
          ./common/laptop.nix
          ./common/gui.nix
          ./common/gaming.nix
          ./machines/pocket4/configuration.nix
          nixos-hardware.nixosModules.gpd-pocket-4
          sops-nix.nixosModules.sops
          gpd-fan-driver.nixosModules.default
          gpd-fp-driver.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.ikovalev = import ./users/ikovalev/home.nix;
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              noctalia.homeModules.default
            ];
          }
          (
            {pkgs, ...}: {
              environment.systemPackages = [
                self.packages.${pkgs.stdenv.system}.my-neovim
                self.packages.${pkgs.stdenv.system}.ssh-toggle
              ];
            }
          )
        ];
        specialArgs = {
          nixpkgs-24-11 = import nixpkgs-24-11 {
            inherit system;
            config.allowUnfree = true;
          };
          nixpkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
      rpi5 = nixpkgs-current.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          ./common/default.nix
          ./common/ssh.nix
          ./machines/rpi5/configuration.nix
          sops-nix.nixosModules.sops
          authentik-nix.nixosModules.default
          nix-local-cache.nixosModules.frontend
        ];
        specialArgs = {
          inherit nix-local-cache;
          nixpkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          nixpkgs-old = import nixpkgs-25-05 {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
      media-server = nixpkgs-current.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./common/default.nix
          ./common/ssh.nix
          ./machines/media-server/configuration.nix
          sops-nix.nixosModules.sops
          nix-local-cache.nixosModules.server
        ];
        specialArgs = {
          inherit nix-local-cache;
          nixpkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
      main-pc = nixpkgs-current.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          ./common/default.nix
          ./common/ssh.nix
          ./common/gaming.nix
          ./common/gui.nix
          ./machines/main-pc/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.ikovalev = import ./users/ikovalev/home.nix;
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
              noctalia.homeModules.default
            ];
          }
          (
            {pkgs, ...}: {
              environment.systemPackages = [
                self.packages.${pkgs.stdenv.system}.my-neovim
                self.packages.${pkgs.stdenv.system}.ssh-toggle
              ];
            }
          )
        ];
        specialArgs = {
          nixpkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      };
    };
    devShells = {
      aarch64-darwin.default = makeDevShell "aarch64-darwin";
      x86_64-linux.default = makeDevShell "x86_64-linux";
    };
  };
}
