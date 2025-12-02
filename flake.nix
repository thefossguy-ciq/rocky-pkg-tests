{
  description = "Regression testing for RLC packages";

  inputs = {
    nixpkgs.url = "github:thefossguy/nixpkgs?rev=719c6079319b0490f932d00198e16180be276e03";

    nix-vm-test = {
      url = "github:numtide/nix-vm-test";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-vm-test,
      self,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSupportedSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              localSystem = system;
              overlays = [
                nix-vm-test.overlays.default
              ];
            };
          }
        );

    in
    {
      packages = forAllSupportedSystems (
        { pkgs, ... }:
        (import ./tests/vulns/CVE-2025-58060.nix { inherit pkgs; })
      );

      workflows = forAllSupportedSystems (
        { pkgs, ... }:
        (import ./workflows.nix {
          inherit pkgs;
          allPackages = self.outputs.packages;
        })
      );
    };
}
