{ pkgs, allPackages }:
let
  lib = pkgs.lib;

  generateWorkflow = packageName: system:
    let
      parts = lib.splitString "_cve_" packageName;
      rlcVersionRaw = lib.toUpper (lib.elemAt parts 0);
      versionParts = lib.splitString "_" rlcVersionRaw;
      rlcVersion = "${lib.elemAt versionParts 0}-${lib.elemAt versionParts 1}.${lib.elemAt versionParts 2}";
      cveId = "${lib.elemAt parts 1}";
    in
    pkgs.writeText "${packageName}.${system}.yaml" ''
      name: ${rlcVersion} CVE-${cveId} ${system}

      on:
        workflow_dispatch:
        schedule:
          - cron: "0 0 * * *"

      jobs:
        ci:
          runs-on: ubuntu-24.04${lib.strings.optionalString (system == "aarch64-linux") "-arm"}
          steps:
            - name: Checkout repository
              uses: actions/checkout@v5

            - name: Install Nix
              uses: cachix/install-nix-action@v31

            - name: Setup magic-nix-cache
              uses: DeterminateSystems/magic-nix-cache-action@main

            - name: Build package
              run: nix build .#packages.${system}.${packageName}

            - name: Run test driver
              env:
                DEPOT_USER: ''${{ secrets.DEPOT_USER }}
                DEPOT_TOKEN: ''${{ secrets.DEPOT_TOKEN }}
              run: ./result/bin/test-driver
    '';

  # Generate workflows for all systems and packages
  workflowList = lib.flatten (
    lib.mapAttrsToList (system: packages:
      map (packageName: {
        name = "${packageName}_${system}";
        value = generateWorkflow packageName system;
      }) (lib.attrNames packages)
    ) allPackages
  );
in

lib.listToAttrs workflowList
