{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05-small";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default =
        final: prev:
        let
          python = final.python312;
          pythonPackages = python.pkgs;

          developmentPackages = with pythonPackages; [
            pip
            python-lsp-server
            ruff
          ];

          packages = with pythonPackages; [
          ];
        in
        {
          pythonEnv = python.withPackages (ps: developmentPackages ++ packages);
        };

      formatter = forEachSupportedSystem ({ pkgs }: pkgs.alejandra);

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              aws-sam-cli
              awscli2
              direnv
              git
              just
              nix-direnv
              pythonEnv
            ];
            shellHook = ''
              echo "AWS CLI: $(aws --version)"
              echo "Just: $(just --version)"
              echo "PIP: $(pip --version)"
              echo "Python: $(python --version)"
              echo "SAM: $(sam --version)"
            '';
          };
        }
      );
    };
}
