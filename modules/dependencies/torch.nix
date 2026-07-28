{
  perSystem =
    { final, ... }:
    let
      inherit (final)
        fetchFromGitHub
        ;

      packageOverrides =
        pyFinal: _pyPrev:
        let
          inherit (pyFinal) callPackage;

          torch_2_8_0 =
            (callPackage (fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "6a088f5b69ecf8359cd033b22507afc316009e1c";
              rootDir = "pkgs/development/python-modules/torch/source";
              sha256 = "sha256-INhjw06vuzng4+xwlvDxU/c/kvSrJE9NgmUJULP3Gh0=";
            }) { }).overrideAttrs
              (_: {
                USE_SYSTEM_PYBIND11 = false;
              });

          torch_2_9_1 =
            (callPackage (fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "fd14d2094fe3612bdfc02180306ca4e9d937f08f";
              rootDir = "pkgs/development/python-modules/torch/source";
              sha256 = "sha256-XsyiMhXneiiZJ5VlHU/gcMdPhwpThz6/xxNuHqqSmJw=";
            }) { }).overrideAttrs
              (oldAttrs: {
                env = oldAttrs.env or { } // {
                  USE_SYSTEM_PYBIND11 = false;
                };
              });
        in
        {
          inherit
            torch_2_8_0
            torch_2_9_1
            ;
        };
    in
    {
      pythonPackagesExtensions = [
        packageOverrides
      ];
    };
}
