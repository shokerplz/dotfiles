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
    # NixOS Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    {
      self,
      nixpkgs,
      sops-nix,
      nixos-hardware,
      auto-cpufreq,
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
          ];
        };
        rpi5 = nixpkgs.lib.nixosSystem rec {
          system = "aarch64-linux";
          modules = [
            ./common/default.nix
            ./common/ssh.nix
            ./machines/rpi5/configuration.nix
            nixos-hardware.nixosModules.raspberry-pi-5
            sops-nix.nixosModules.sops
            {
              nixpkgs.overlays = [ (final: prev: { cloudflare-ddns = final.callPackage ./packages/cloudflare-ddns.nix { }; }) ];
            }
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
            ./machines/main-pc/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
      devShells = {
        aarch64-darwin.default = makeDevShell "aarch64-darwin";
        x86_64-linux.default = makeDevShell "x86_64-linux";
      };
    };
}
