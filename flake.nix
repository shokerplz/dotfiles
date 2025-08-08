{
  description = "NixOS configuration";

  inputs = {
    # AutoCPUFreq
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Secret manager for Nix
    sops-nix.url = "github:Mic92/sops-nix";
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # NixPKGs nixos24.11
    nixpkgs-24-11.url = "github:nixos/nixpkgs/nixos-24.11";
    # NixOS Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-24-11,
      sops-nix,
      nixos-hardware,
      auto-cpufreq,
      home-manager,
      nvf,
    }:
    let
      makeDevShell =
        system:
        let
          pkgs = import nixpkgs {
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
    in
    {
      packages."x86_64-linux".my-neovim =
        (nvf.lib.neovimConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          modules = [ ./packages/nvf-config.nix ];
        }).neovim;

      nixosConfigurations = {
        pocket4 = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./common/laptop.nix
            ./common/gui.nix
            ./common/gaming.nix
            ./machines/pocket4/configuration.nix
            nixos-hardware.nixosModules.gpd-pocket-4
            auto-cpufreq.nixosModules.default
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.users.ikovalev = import ./users/ikovalev/home.nix;
              home-manager.sharedModules = [
              ];
            }
          ];
          specialArgs = {
            nixpkgs-24-11 = import nixpkgs-24-11 {
              inherit system;
              config.allowUnfree = true;
            };
          };
        };
        rpi5 = nixpkgs.lib.nixosSystem rec {
          system = "aarch64-linux";
          modules = [
            ./common/default.nix
            ./common/ssh.nix
            ./machines/rpi5/configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-5
            sops-nix.nixosModules.sops
          ];
        };
        media-server = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            ./common/default.nix
            ./common/ssh.nix
            ./machines/media-server/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
        main-pc = nixpkgs.lib.nixosSystem rec {
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
              ];
            }
            (
              { pkgs, ... }:
              {
                environment.systemPackages = [ self.packages.${pkgs.stdenv.system}.my-neovim ];
              }
            )
          ];
        };
      };
      devShells = {
        aarch64-darwin.default = makeDevShell "aarch64-darwin";
        x86_64-linux.default = makeDevShell "x86_64-linux";
      };
    };
}
