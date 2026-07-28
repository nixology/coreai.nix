{ ... }@local:
let
  inherit (local.inputs) flake;
  inherit (flake.components) nixology;
  inherit (flake.lib.components) uses;
in
uses {
  components = [
    nixology.core.debug
    nixology.environments.nix
    nixology.extra.easyOverlay
    nixology.flake.apps
    nixology.flake.packages
    nixology.systems.default-darwin
  ];
}
