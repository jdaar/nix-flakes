{
  description = "aider";

  inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/c2a03962b8e2";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    perSystem = system: let pkgs = import nixpkgs {inherit system;};
    in {
      devShell = pkgs.mkShell {
        buildInputs = [
					(pkgs.aider-chat.withOptional {
						withPlaywright = true;
						withBrowser = true;
						withHelp = true;
						withBedrock = true;
						withAll = true;
					})
        ];
        shellHook = ''
          echo "Aider environment"
          echo "Make sure that .venv has been initialized in the flake directory"
					if [[ -d "./.venv" ]]; then
						echo "Loading venv"
						source ./.venv/bin/activate
						export AIDER_MODEL=o3-mini
						export AIDER_OPENAI_API_KEY=GETYOUROWNKEY
					fi	
					if [[ ! -d "./.venv" ]]; then
						echo "Couldn't load venv"
					fi	
        '';
      };
    };
    allSystemsOutputs = forAllSystems perSystem;
  in {
    devShells = forAllSystems (system: {
      default = allSystemsOutputs.${system}.devShell;
    });
  };
}
