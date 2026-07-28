{ lib, ... }:
let
  inherit (lib.parts) mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption {
    options.pythonPackagesExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [ ];
      description = ''
        Extensions applied to Python package sets.
      '';
    };
  };
}
