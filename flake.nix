{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    sops-nix.url = "github:Mic92/sops-nix";
    foundryvtt.url = "github:reckenrode/nix-foundryvtt/f1b401831d796dd94cf5a11b65fd169a199d4ff0";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nixos-hardware,
      sops-nix,
      foundryvtt,
      ...
    }:
    {
      nixosConfigurations = {

        corellia = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
            };
          };
          modules = [
            ./hosts/corellia/configuration.nix
            sops-nix.nixosModules.sops
            nixos-hardware.nixosModules.dell-xps-13-9370
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.matthew = import ./hosts/corellia/home.nix;
            }
          ];
        };

        alderaan = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/alderaan/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.matthew = import ./hosts/alderaan/home.nix;
            }
          ];
        };

        taris = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
            };
          };
          modules = [
            ./hosts/taris/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.matthew = import ./hosts/taris/home.nix;
            }
            foundryvtt.nixosModules.foundryvtt
          ];
        };

        bespin = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit foundryvtt;
          };
          modules = [
            ./hosts/bespin/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.matthew = import ./hosts/bespin/home.nix;
            }
            foundryvtt.nixosModules.foundryvtt
          ];
        };
      };
    };
}
