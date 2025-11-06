{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05-small";

  outputs =
    {
      self,
      nixpkgs,
      ...
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
            };
          }
        );
    in
    {
      formatter = forEachSupportedSystem ({ pkgs }: pkgs.alejandra);

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              (maven.override { jdk_headless = jdk11_headless; })
              direnv
              emacsPackages.lsp-java
              git
              jdk11_headless
              nix-direnv
            ];
            shellHook = ''
              echo "Java: " $(java --version)
            '';
          };
        }
      );
    };
}
