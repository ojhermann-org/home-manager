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
      codeQualityTools =
        pkgs:
        let
          dir = ./packages/code-quality-tools;
          files = nixpkgs.lib.filesystem.listFilesRecursive dir;
          nixFiles = builtins.filter (f: nixpkgs.lib.hasSuffix ".nix" f) files;
        in
        builtins.concatMap (f: import f { inherit pkgs; }) nixFiles;
    in
    {
      homeConfigurations = {
        "otto@aarch64-darwin" = mkConfig "aarch64-darwin";
        "otto@x86_64-linux" = mkConfig "x86_64-linux";
        "otto@aarch64-linux" = mkConfig "aarch64-linux";
      };
      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [ pkgs.prek ] ++ codeQualityTools pkgs;
            shellHook = ''
              if [ -d .git ] && [ ! -f .git/hooks/pre-commit ]; then
                prek install >/dev/null 2>&1 || true
              fi
            '';
          };
        }
      );
    };
}
