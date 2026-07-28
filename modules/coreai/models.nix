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
      inputs',
      ...
    }:
    with final.coreai.python.pkgs;
    let
      _coreai-models_ = metadataForFlakeInput self local.inputs.coreai-models;

      coreai-models = buildPythonPackage (_finalAttrs: {
        inherit (_coreai-models_) pname src version;
        pyproject = true;

        postUnpack = ''
          sourceRoot=$sourceRoot/python
        '';

        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail 'hatchling==' 'hatchling>='
        '';

        build-system = [
          hatchling
          pip
          pythonRelaxDepsHook
        ];

        dependencies = [
          accelerate
          config.packages.coreai-core
          config.packages.coreai-torch
          config.packages.coreai-optimization
          torch
          diffusers
          huggingface-hub
          numpy
          rich
          safetensors
          sentencepiece
          tokenizers
          tqdm
          transformers
        ];

        pythonImportsCheck = [
          "coreai_models"
        ];

        pythonRelaxDeps = true;

        meta = {
          description = "Core AI model export, evaluation, and building blocks for on-device ML";
          homepage = "https://github.com/apple/coreai-models";
          license = licenses.bsd3;
        };
      });

      coreai-models-tests = buildPythonPackage (_finalAttrs: {
        pname = "${coreai-models.pname}-tests";
        inherit (coreai-models) src version;

        pyproject = false;
        dontBuild = true;

        postUnpack = ''
          export CFFIXED_USER_HOME=$TMPDIR
          sourceRoot=$sourceRoot/python
        '';

        dependencies = [
          coreai-models
        ];

        nativeCheckInputs = [
          pytestCheckHook
        ];

        HF_HUB_CACHE = inputs'.models.packages.cache;
        TRANSFORMERS_OFFLINE = 1;

        pytestFlags = [
        ];

        enabledTestPaths = [
          #"tests"
          "tests/test_model_conversion/test_macos_models.py::TestQwen2EndtoEnd::test_coreai"
        ];

        disabledTests = [
        ];

        disabledTestPaths = [
          #"tests/test_model_conversion/test_macos_models.py::TestQwen2EndtoEnd::test_coreai"
          #"tests/test_model_conversion/test_macos_models.py::TestQwen3EndtoEnd::test_coreai"
          "tests/test_model_conversion/test_macos_models.py::TestGemma3EndtoEnd"
          "tests/test_model_conversion/test_macos_models.py::TestGptOssEndtoEnd"
          "tests/test_model_conversion/test_macos_models.py::TestQwen3MoeEndtoEnd"
          "tests/test_model_conversion/test_macos_models.py::TestMixtralEndtoEnd"
        ];

        installPhase = ''
          mkdir -p $out
          touch $out/passed
        '';
      });
    in
    {
      apps = {
        coreai-diffusion-export = {
          type = "app";
          program = "${coreai-models}/bin/coreai.diffusion.export";
        };
        coreai-llm-eval = {
          type = "app";
          program = "${coreai-models}/bin/coreai.llm.eval";
        };
        coreai-llm-export = {
          type = "app";
          program = "${coreai-models}/bin/coreai.llm.export";
        };
        coreai-model-registry = {
          type = "app";
          program = "${coreai-models}/bin/coreai.model.registry";
        };
      };

      checks = {
        #inherit coreai-models-tests;
      };

      packages = {
        inherit coreai-models coreai-models-tests;
      };
    };
}
