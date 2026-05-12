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
      # Users supported by this flake. Add a name here to enable
      # `home-manager switch --flake .#<name>@<system>` for that user.
      # Future-you forking this repo: drop "otto" and add yourself.
      users = [ "otto" ];
      # Import nixpkgs with allowUnfree so unfree packages (e.g. vscode) are
      # usable from any of the flake outputs. legacyPackages.${system} would
      # ignore home.nix's nixpkgs.config because pkgs is built before HM's
      # module system sees it.
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      forEachSystem =
        f:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = f system;
          }) systems
        );
      mkConfig =
        user: system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          extraSpecialArgs = { inherit user; };
          modules = [ ./home.nix ];
        };
      codeQualityTools =
        pkgs:
        let
          dir = ./packages/code-quality-tools;
          files = nixpkgs.lib.filesystem.listFilesRecursive dir;
          nixFiles = builtins.filter (f: nixpkgs.lib.hasSuffix ".nix" f) files;
        in
        builtins.concatMap (f: (import f { inherit pkgs; }).packages) nixFiles;
    in
    {
      homeConfigurations = builtins.listToAttrs (
        nixpkgs.lib.concatMap (
          user:
          map (system: {
            name = "${user}@${system}";
            value = mkConfig user system;
          }) systems
        ) users
      );
      devShells = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;
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
      packages = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          prek-toml = import ./nix/prek-toml.nix { inherit pkgs; };
        }
      );
      apps = forEachSystem (
        system:
        let
          pkgs = pkgsFor system;
          prekToml = import ./nix/prek-toml.nix { inherit pkgs; };
        in
        {
          sync-prek = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "sync-prek" ''
                set -euo pipefail
                repo_root="$(git rev-parse --show-toplevel)"
                install -m 644 ${prekToml} "$repo_root/prek.toml"
                echo "Wrote $repo_root/prek.toml"
              ''
            );
          };
        }
      );
    };
}
