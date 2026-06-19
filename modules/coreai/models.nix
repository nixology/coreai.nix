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
      _coreai-models_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-models;
      _coreai-models-unstable_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-models-unstable;

      coreai-models = buildPythonPackage (finalAttrs: {
        inherit (_coreai-models_) pname version;

        src = final.fetchFromGitHub {
          owner = "apple";
          repo = finalAttrs.pname;
          inherit (_coreai-models-unstable_) rev;
          sha256 = "sha256-q1fg6AkBny10dvK0Y6OWemcXDAcPwumjFQL6Rm2/Exg=";
        };

        sourceRoot = "${finalAttrs.src.name}/python";

        dependencies = [
          accelerate
          config.packages.coreai-core
          config.packages.coreai-opt
          config.packages.coreai-torch
          diffusers
          huggingface-hub
          numpy
          rich
          safetensors
          sentencepiece
          tokenizers
          torch
          tqdm
          transformers
        ];

        nativeBuildInputs = [
          hatchling
          pip
          pythonRelaxDepsHook
        ];

        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail 'hatchling==' 'hatchling>='
        '';

        pyproject = true;

        pythonImportsCheck = [
          "coreai_models"
        ];

        pythonRelaxDeps = true;
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

      packages = { inherit coreai-models; };
    };
}
