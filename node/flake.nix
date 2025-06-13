{
  description = "Node.js 20 development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    perSystem = system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShell = pkgs.mkShell {
        buildInputs = [
          pkgs.nodejs_20
          pkgs.corepack_20
          pkgs.docker_28
          pkgs.bash
        ];

        shellHook = ''
          echo "Node development environment"
          node --version
          npm --version
        '';
      };
    };

    allSystemsOutputs = forAllSystems perSystem;
  in {
    devShells = forAllSystems (system: {
      default = allSystemsOutputs.${system}.devShell;
    });

    apps = forAllSystems (system: {
      server = allSystemsOutputs.${system}.app;
    });
  };
}
