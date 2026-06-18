{ inputs, ... }:
{
  perSystem =
    {
      config,
      final,
      lib,
      ...
    }:
    let
      _coreai-opt_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-opt;

      python = final.python;
      pythonVersionMajor = lib.versions.major python.version;

      format = "wheel";

      coreai-opt = python.pkgs.buildPythonPackage {
        inherit (_coreai-opt_) pname version;
        inherit format;

        src = python.pkgs.fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] _coreai-opt_.pname;
          inherit (_coreai-opt_) version;
          inherit format;
          hash = "sha256-ZG3IEKOfF0LN0YcFLlnNUm+pCT+pmP0OTnxg6iugpiI=";
          platform = "any";
          python = "py${pythonVersionMajor}";
          dist = "py${pythonVersionMajor}";
        };

        propagatedBuildInputs = with python.pkgs; [
          config.packages.coremltools
          numpy
          pydantic
          rich
          torch
          torchao
          tqdm
          safetensors
        ];

        dontCheckRuntimeDeps = true;
        dontStrip = true;
        doCheck = false;
      };
    in
    {
      packages = {
        inherit coreai-opt;
      };
    };
}
