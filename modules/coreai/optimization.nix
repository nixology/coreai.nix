{ inputs, ... }:
{
  perSystem =
    {
      config,
      final,
      lib,
      ...
    }:
    with final.coreai.python.pkgs;
    let
      _coreai-optimization_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-optimization;

      format = "wheel";

      coreai-optimization-wheel = buildPythonPackage (finalAttrs: {
        pname = "coreai-opt";
        inherit (_coreai-optimization_) version;
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

        dependencies = [
          config.packages.coremltools
          numpy
          pydantic
          rich
          torch
          torchao
          tqdm
          safetensors
        ];

        nativeBuildInputs = [
          pythonRelaxDepsHook
        ];

        pythonImportsCheck = [
          "coreai_opt"
        ];

        pythonRelaxDeps = true;
      });

      coreai-optimization = buildPythonPackage (_finalAttrs: {
        inherit (_coreai-optimization_) pname version;
        pyproject = true;

        src = inputs.coreai-optimization;

        build-system = [
          setuptools
          wheel
          pythonRelaxDepsHook
        ];

        dependencies = [
          config.packages.coremltools
          numpy
          pydantic
          rich
          torch
          torchao
          tqdm
          safetensors
        ];

        pythonImportsCheck = [
          "coreai_opt"
        ];

        pythonRelaxDeps = true;

        meta = {
          description = "A library for PyTorch model compression and optimizations for deployment via Core AI on Apple silicon.";
          homepage = "https://github.com/apple/coreai-optimization";
          license = lib.licenses.bsd3;
        };
      });
    in
    {
      packages = {
        inherit coreai-optimization coreai-optimization-wheel;
      };
    };
}
