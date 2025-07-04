{
  description = "Python313/manim development environment";

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
          pkgs.python313
          pkgs.python313Packages.pip
          pkgs.python313Packages.manim
          pkgs.python313Packages.manim-slides
          pkgs.bash
        ];
        shellHook = ''
          echo "Manim development environment"
					mkdir -p slides
        '';
      };
			execute_manim = {
				type = "app";
				program = "${pkgs.writeShellScriptBin "execute_manim" ''
					#!${pkgs.bash}/bin/bash
					manim-slides render $1 $2
					manim-slides convert $2 output.html
				''}/bin/execute_manim";
			};
    };

    allSystemsOutputs = forAllSystems perSystem;
  in {
    devShells = forAllSystems (system: {
      default = allSystemsOutputs.${system}.devShell;
    });
		apps = forAllSystems (system: {
			default = allSystemsOutputs.${system}.execute_manim;
			execute_manim = allSystemsOutputs.${system}.execute_manim;
		});
  };
}
