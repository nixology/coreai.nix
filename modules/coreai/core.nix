{ ... }@local:
let
  inherit (local.inputs) flake self;

  inherit (flake.lib) metadataForFlakeInput;
in
{
  perSystem =
    { final, lib, ... }:
    with final.coreai.python.pkgs;
    let
      _yuvio_ = metadataForFlakeInput self local.inputs.yuvio;

      yuvio = buildPythonPackage (_finalAttrs: {
        inherit (_yuvio_) pname src version;
        pyproject = true;

        build-system = [
          setuptools
          wheel
        ];

        dependencies = [
          numpy
          psutil
        ];

        pythonImportsCheck = [
          "yuvio"
          "yuvio.core"
          "yuvio.formats"
        ];

        meta = {
          description = "Read and write uncompressed yuv/ycbcr image and video files";
          homepage = "https://github.com/labradon/yuvio";
          license = lib.licenses.mit;
        };
      });

      coreai-core =
        let
          format = "wheel";
          pname = "coreai-core";
          version = "1.0.0b2";

          pythonVersion = final.coreai.python.versionMajorMinorCompact;

          hashes = {
            "312" = "sha256-q+qSBCbBQv+7bZFrRjx33Ii2FDkHDU1kT6wa3Fuvu/0=";
            "313" = "sha256-a5qS09buBEfNUmXXtS2r21chWqhwH3qUHvg94uzUdOo=";
          };
        in
        buildPythonPackage (finalAttrs: {
          inherit pname version;
          inherit format;

          src = fetchPypi {
            pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
            inherit (finalAttrs) version;
            inherit format;

            hash =
              hashes.${pythonVersion} or (throw "coreai-core: unsupported Python version cp${pythonVersion}");

            platform = "macosx_26_0_arm64";
            python = "cp${pythonVersion}";
            dist = "cp${pythonVersion}";
            abi = "cp${pythonVersion}";
          };

          dontStrip = true;

          dependencies = [
            ml-dtypes
            numpy
            pillow
            typing-extensions
            yuvio
          ];

          pythonImportsCheck = [
            "coreai"
          ];
        });
    in
    {
      packages = {
        inherit coreai-core;
      };
    };
}
