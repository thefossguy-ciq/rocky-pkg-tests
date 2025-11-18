# Rocky package tests

This repository is made to test all CVEs fixed by CIQ
(non-exhaustively) do not get re-introduced again.

This repository is intended to execute at least once a day.

## Reading/reference material
The `nix-vm-test` project from Numtide is used here because it uses
the excellent NixOS VM test framework to not only create VMs, but to
also provide a uniform method of running commands to check for breakage
of a CVE fixed by CIQ.

Documentation on how to interact with the VM (execute commands, copy
files to and from VM, port forwarding from host to guest, type
characters on console, etc) can be found
[here](https://nixos.org/manual/nixos/stable/#ssec-machine-objects).
