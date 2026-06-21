{ inputs, ... }:
{
  perSystem =
    { final, lib, ... }:
    with final.coreai.python.pkgs;
    let
      _yuvio_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.yuvio;

      yuvio = buildPythonPackage (_finalAttrs: {
        inherit (_yuvio_) pname version;
        pyproject = true;

        src = inputs.yuvio;

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
          version = "1.0.0b1";
        in
        buildPythonPackage (finalAttrs: {
          inherit pname version;
          inherit format;

          src = fetchPypi {
            pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
            inherit (finalAttrs) version;
            inherit format;
            hash = "sha256-ZJvZjMwgJP4bFz8hMC3VM+D+97Uxiadl/DWFjHArc0g=";
            platform = "macosx_26_0_arm64";
            python = "cp${final.coreai.python.versionMajorMinorCompact}";
            dist = "cp${final.coreai.python.versionMajorMinorCompact}";
            abi = "cp${final.coreai.python.versionMajorMinorCompact}";
          };

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
