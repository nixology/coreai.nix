{ inputs, ... }: {
  perSystem =
    { config, final, ... }:
    let
      _coreai-models_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-models;
      _coreai-models-unstable_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-models-unstable;
    in
    {
      packages.coreai-models = final.python.pkgs.buildPythonPackage (finalAttrs: {
        inherit (_coreai-models_) pname version;

        src = final.fetchFromGitHub {
          owner = "apple";
          repo = "coreai-models";
          inherit (_coreai-models-unstable_) rev;
          sha256 = "sha256-q1fg6AkBny10dvK0Y6OWemcXDAcPwumjFQL6Rm2/Exg=";
        };

        sourceRoot = "${finalAttrs.src.name}/python";

        dependencies = with final.python.pkgs; [
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

        nativeBuildInputs = with final.python.pkgs; [
          hatchling
          pip
          pythonRelaxDepsHook
        ];

        postPatch = ''
          substituteInPlace pyproject.toml \
            --replace-fail 'hatchling==' 'hatchling>='
        '';

        pyproject = true;

        pythonRelaxDeps = true;
      });
    };
}
