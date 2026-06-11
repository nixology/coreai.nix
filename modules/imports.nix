{ inputs, ... }:
with inputs.flake.components;
{
  imports = map (component: component.module) [
    nixology.environments.nix
    nixology.extra.easyOverlay
    nixology.flake.packages
    nixology.systems.default-darwin
  ];
}
