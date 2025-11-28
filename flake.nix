{
  description = "NixOS configuration";

  inputs = {
    # Secret manager for Nix
    sops-nix.url = "github:Mic92/sops-nix";
    # Nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # NixPKGs nixos24.11
    nixpkgs-24-11.url = "github:nixos/nixpkgs/nixos-24.11";
    # NixPKGs that I am currently using
    nixpkgs-current.url = "github:nixos/nixpkgs/nixos-25.05";
    # NixOS Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Authentik
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
    };

    # Home Manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-current";
    nvf = {
      url = "github:notashelf/nvf/v0.8";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-unstable,
    nixpkgs-24-11,
    nixpkgs-current,
    sops-nix,
    nixos-hardware,
    home-manager,
    authentik-nix,
    nvf,
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
    packages."x86_64-linux".my-neovim =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs-unstable.legacyPackages."x86_64-linux";
        modules = [./packages/nvf-config.nix];
      }).neovim;

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
          home-manager.nixosModules.home-manager
          "${nixpkgs-unstable}/nixos/modules/services/misc/ringboard.nix"
          {
            home-manager.useUserPackages = true;
            home-manager.users.ikovalev = import ./users/ikovalev/home.nix;
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
          }
          (
            {pkgs, ...}: {
              environment.systemPackages = [self.packages.${pkgs.stdenv.system}.my-neovim];
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
          nixos-hardware.nixosModules.raspberry-pi-5
          sops-nix.nixosModules.sops
          authentik-nix.nixosModules.default
        ];
        specialArgs = {
          nixpkgs-unstable = import nixpkgs-unstable {
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
        ];
        specialArgs = {
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
          "${nixpkgs-unstable}/nixos/modules/services/misc/ringboard.nix"
          {
            home-manager.useUserPackages = true;
            home-manager.users.ikovalev = import ./users/ikovalev/home.nix;
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
          }
          (
            {pkgs, ...}: {
              environment.systemPackages = [self.packages.${pkgs.stdenv.system}.my-neovim];
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
