{ inputs, ... }:
{
  perSystem =
    { final, lib, ... }:
    let
      _yuvio_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.yuvio;

      python = final.python;
      pythonVersionMajor = lib.versions.major python.version;
      pythonVersionMajorMinorCompact =
        lib.versions.major python.version + lib.versions.minor python.version;

      format = "wheel";

      yuvio = python.pkgs.buildPythonPackage {
        inherit (_yuvio_) pname version;
        inherit format;

        src = python.pkgs.fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] _yuvio_.pname;
          inherit (_yuvio_) version;
          inherit format;
          hash = "sha256-7TFxiiTvP0UQ/QchJizNcVTZ4HUwKgAbxnGrZO23v1U=";
          platform = "any";
          python = "py${pythonVersionMajor}";
          dist = "py${pythonVersionMajor}";
        };

        propagatedBuildInputs = with python.pkgs; [
          numpy
          psutil
        ];

        dontStrip = true;
        doCheck = false;
      };

      coreai-core =
        let
          pname = "coreai-core";
          version = "1.0.0b1";
        in
        python.pkgs.buildPythonPackage {
          inherit pname version;
          inherit format;
          src = python.pkgs.fetchPypi {
            pname = builtins.replaceStrings [ "-" ] [ "_" ] pname;
            inherit version;
            inherit format;
            hash = "sha256-ZJvZjMwgJP4bFz8hMC3VM+D+97Uxiadl/DWFjHArc0g=";
            platform = "macosx_26_0_arm64";
            python = "cp${pythonVersionMajorMinorCompact}";
            dist = "cp${pythonVersionMajorMinorCompact}";
            abi = "cp${pythonVersionMajorMinorCompact}";
          };

          propagatedBuildInputs = with python.pkgs; [
            ml-dtypes
            numpy
            pillow
            typing-extensions
            yuvio
          ];

          dontStrip = true;
          doCheck = false;
        };
    in
    {
      packages = {
        inherit coreai-core;
      };
    };
}
