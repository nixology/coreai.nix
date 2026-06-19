{ inputs, ... }:
{
  perSystem =
    {
      config,
      final,
      ...
    }:
    with final.coreai.python.pkgs;
    let
      _coreai-opt_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-opt;

      format = "wheel";

      coreai-opt = buildPythonPackage (finalAttrs: {
        inherit (_coreai-opt_) pname version;
        inherit format;

        src = fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
          inherit (finalAttrs) version;
          inherit format;
          hash = "sha256-ZG3IEKOfF0LN0YcFLlnNUm+pCT+pmP0OTnxg6iugpiI=";
          platform = "any";
          python = "py${final.coreai.python.versionMajor}";
          dist = "py${final.coreai.python.versionMajor}";
        };

        propagatedBuildInputs = [
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
      });
    in
    {
      packages = {
        inherit coreai-opt;
      };
    };
}
