{ inputs, ... }:
{
  perSystem =
    { final, ... }:
    with final.coreai.python.pkgs;
    let
      _yuvio_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.yuvio;

      format = "wheel";

      yuvio = buildPythonPackage (finalAttrs: {
        inherit (_yuvio_) pname version;
        inherit format;

        src = fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
          inherit (finalAttrs) version;
          inherit format;
          hash = "sha256-7TFxiiTvP0UQ/QchJizNcVTZ4HUwKgAbxnGrZO23v1U=";
          platform = "any";
          python = "py${final.coreai.python.versionMajor}";
          dist = "py${final.coreai.python.versionMajor}";
        };

        propagatedBuildInputs = [
          numpy
          psutil
        ];

        dontStrip = true;
        doCheck = false;
      });

      coreai-core =
        let
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

          propagatedBuildInputs = [
            ml-dtypes
            numpy
            pillow
            typing-extensions
            yuvio
          ];

          dontStrip = true;
          doCheck = false;
        });
    in
    {
      packages = {
        inherit coreai-core;
      };
    };
}
