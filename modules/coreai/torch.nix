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
      _coreai-torch_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-torch;

      format = "wheel";

      coreai-torch-wheel = buildPythonPackage (finalAttrs: {
        inherit (_coreai-torch_) pname version;
        inherit format;

        src = fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
          inherit (finalAttrs) version;
          inherit format;
          hash = "sha256-sQnACQ2DsKjrcwL+ojFM88uNqVdHf3sxuOw2SAqUokc=";
          platform = "any";
          python = "py${final.coreai.python.versionMajor}";
          dist = "py${final.coreai.python.versionMajor}";
        };

        build-system = [
          setuptools
          wheel
        ];

        dependencies = [
          config.packages.coreai-core
          ml-dtypes
          networkx
          numpy
          rich
          scipy
          strenum
          sympy
          torch
          typing-extensions
        ];

        nativeBuildInputs = [
          pythonRelaxDepsHook
        ];

        pythonImportsCheck = [
          "coreai_torch"
        ];

        pythonRelaxDeps = true;
      });

      coreai-torch = buildPythonPackage (_finalAttrs: {
        inherit (_coreai-torch_) pname version;
        pyproject = true;

        src = inputs.coreai-torch;

        build-system = [
          setuptools
          wheel
        ];

        dependencies = [
          config.packages.coreai-core
          ml-dtypes
          networkx
          numpy
          rich
          scipy
          strenum
          sympy
          torch
          typing-extensions
        ];

        nativeBuildInputs = [
          pythonRelaxDepsHook
        ];

        optional-dependencies = {
          test = [
            config.packages.coremltools
            filecheck
            mlx
            mlx-lm
            pytest
            pytest-asyncio
            pytest-randomly
            pytest-rerunfailures
            pytest-sugar
            pytest-xdist
            torchaudio
            torchvision
            transformers
          ];
          docs = [
            sphinx
            #            shibuya
            myst-nb
            nbmake
            ghp-import
            nest-asyncio
          ];
          dev = [
            deptry
            nbstripout
            pre-commit
            ruff
          ];
        };

        pythonImportsCheck = [
          "coreai_torch"
        ];

        pythonRelaxDeps = true;

        meta = {
          description = "Convert PyTorch models to CoreAI format";
          homepage = "https://github.com/apple/coreai-torch";
          license = lib.licenses.bsd3;
        };
      });

      coreai-torch-tests = buildPythonPackage {
        pname = "${coreai-torch.pname}-test";
        inherit (coreai-torch) version;
        src = inputs.coreai-torch;

        pyproject = false;
        dontBuild = true;

        dependencies = [
          coreai-torch
        ]
        ++ coreai-torch.optional-dependencies.test;

        nativeCheckInputs = [
          pytestCheckHook
        ];

        preCheck = ''
          export CFFIXED_USER_HOME=$TMPDIR
        '';

        pytestFlags = [
          "-n auto"
        ];

        enabledTestPaths = [
          "tests"
        ];

        disabledTestPaths = [
          "tests/ops/test_ops.py::TestBmm::test_mixed_dtypes"
          "tests/composite_ops/test_rope.py::TestTorchRoPEHuggingFace::test_gemma3"
          "tests/composite_ops/test_gather_mm.py::TestTorchGatherMM"
        ];

        installPhase = ''
          mkdir -p $out
          touch $out/passed
        '';
      };

      coreai-torch-notebook-tests = buildPythonPackage {
        pname = "${coreai-torch.pname}-test-docs";
        inherit (coreai-torch) version;
        src = inputs.coreai-torch;

        pyproject = false;
        dontBuild = true;

        dependencies = [
          coreai-torch
        ]
        ++ coreai-torch.optional-dependencies.test
        ++ coreai-torch.optional-dependencies.docs;

        nativeCheckInputs = [
          pytestCheckHook
        ];

        preCheck = ''
          export CFFIXED_USER_HOME=$TMPDIR
        '';

        pytestFlags = [
          "--nbmake -v"
        ];

        enabledTestPaths = [
          "docs"
        ];

        disabledTestPaths = [
        ];

        installPhase = ''
          mkdir -p $out
          touch $out/passed
        '';
      };
    in
    {
      checks = {
        inherit coreai-torch-tests coreai-torch-notebook-tests;
      };

      overlayAttrs = {
        inherit (inputs'.mlx.packages) mlx mlx-lm;
      };

      packages = {
        inherit coreai-torch coreai-torch-wheel;
      };
    };
}
