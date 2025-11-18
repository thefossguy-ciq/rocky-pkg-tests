{
  description = "Regression testing for RLC packages";

  inputs = {
    nixpkgs.url = "https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";

    #nix-vm-test.url = "https://github.com/numtide/nix-vm-test/archive/refs/heads/main.zip";
    nix-vm-test.url = "https://github.com/thefossguy/nix-vm-test/archive/refs/heads/fix-repo-locking-for-rocky.zip";
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
              inherit system;
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
    };
}
