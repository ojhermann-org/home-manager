{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
      mkConfig =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home.nix ];
        };
    in
    {
      homeConfigurations = {
        "otto@aarch64-darwin" = mkConfig "aarch64-darwin";
        "otto@x86_64-linux" = mkConfig "x86_64-linux";
        "otto@aarch64-linux" = mkConfig "aarch64-linux";
      };
      devShells = forEachSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell { };
      });
    };
}
