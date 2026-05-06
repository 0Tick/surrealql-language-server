{
  description = "SurrealQL language server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    surrealql-tree-sitter = {
      url = "github:surrealdb/surrealql-tree-sitter";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      surrealql-tree-sitter,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "surrealql-language-server";
          version = cargoToml.package.version;

          src = self;
          cargoLock.lockFile = ./Cargo.lock;

          nativeBuildInputs = [
            pkgs.pkg-config
            pkgs.clang
          ];

          TREE_SITTER_SURREALQL_DIR = surrealql-tree-sitter;
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/surrealql-language-server";
        };
      }
    );
}
