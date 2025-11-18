#!/usr/bin/env bash
set -xeuo pipefail

rm -rf .github/workflows/
mkdir -p .github/workflows

system="$(uname -m)-linux"
# shellcheck disable=SC2207
workflows=( $(nix eval .#workflows."${system}" --apply 'x: builtins.attrNames x' --json | jq -r '.[]') )

for cve_workflow in "${workflows[@]}"; do
    nix build --no-link .#workflows."${system}"."${cve_workflow}"
    result_path="$(nix eval --raw .#workflows."${system}"."${cve_workflow}".outPath 2>/dev/null)"
    filename="$(echo "${result_path}" | cut -c45-)"
    cp -f "${result_path}" ".github/workflows/${filename}"
done

chmod 644 .github/workflows/*.yaml
