{ ... }@local:
let
  inherit (local.inputs) flake self;

  inherit (flake.lib) metadataForFlakeInput;

  inherit (local.lib) licenses;
in
{
  perSystem =
    {
      config,
      final,
      ...
    }:
    with final.coreai.python.pkgs;
    let
      _coreai-optimization_ = metadataForFlakeInput self local.inputs.coreai-optimization;

      format = "wheel";

      coreai-optimization-wheel = buildPythonPackage (finalAttrs: {
        pname = "coreai-opt";
        inherit (_coreai-optimization_) version;
        inherit format;

        src = fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
          inherit (finalAttrs) version;
          inherit format;
          hash = "sha256-v53C1LVgTtpCA6CdoRup8AUbmtCE1lNNCeGs7JXiwlU=";
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
        inherit (_coreai-optimization_) pname src version;
        pyproject = true;

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
          license = licenses.bsd3;
        };
      });
    in
    {
      packages = {
        inherit coreai-optimization coreai-optimization-wheel;
      };
    };
}
