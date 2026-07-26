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
      pkgs,
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

      coreai-optimization = buildPythonPackage (finalAttrs: rec {
        inherit (_coreai-optimization_) pname src version;
        pyproject = true;

        build-system = [
          setuptools
          wheel
          pythonRelaxDepsHook
        ];

        dependencies = [
          # Required at runtime by torch.utils.cpp_extension to JIT-compile the vendored
          # kmeans1d C++ core (a C++ toolchain must also be present on the host).
          ninja # >=1.11

          numpy # >=2
          pydantic # >=2.0.0
          pyyaml # >=6.0
          rich # >=13.0.0
          safetensors # >=0.5.3,<=0.7.0

          # Required at runtime by torch.utils.cpp_extension
          setuptools # >=42

          # PyTorch >= 2.9.0 requires torchao >= 0.15.0
          # Python's standard dependency specification (PEP 508) doesn't support conditional dependencies
          # based on other package versions. We can either 1) add a stricter check to require the newer torchao
          # version for everyone, or 2) add a runtime check in src/coreai_opt/init.py to ensure torchao
          # version >= 0.15.0 for torch version >= 2.9.0. Opting option 1.
          # These torch versions must be in bounds of torch_2_8, torch_2_9, torch_2_10, and torch_2_11
          torch # >=2.8.0,<=2.11.0
          torchao # >=0.15.0,<=0.17.0
          tqdm # >=4.65
        ]
        ++ optional-dependencies.coreai
        ++ optional-dependencies.coreml
        ++ passthru.dependency-groups.torchvision;

        optional-dependencies = {
          coreai = [
            config.packages.coreai-core # ==1.0.0b2
            config.packages.coreai-torch # ==0.4.1
            scikit-learn # >=1.7.2
          ];

          coreml = [
            config.packages.coremltools # >=8.3
          ];
        };

        passthru.dependency-groups = {
          dev = [
            build
            mypy
            nox
            #nox-uv
            packaging
            #py-repo-root
            setuptools
            towncrier
            types-setuptools
          ]
          ++ (with finalAttrs.passthru.dependency-groups; pre-commit ++ test ++ torchvision);

          test = coreai-optimization-tests.dependency-groups.test;

          docs = [
            #autodoc-pydantic
            ipython
            myst-parser
            nbsphinx
            #shibuya
            sphinx
            sphinx-copybutton
            #sphinx-llm
            sphinxcontrib-mermaid
          ]
          ++ (with finalAttrs.passthru.dependency-groups; coreai);

          coreai = optional-dependencies.coreai;

          coreml = optional-dependencies.coreml;

          pre-commit = [
            pkgs.bashate
            #darker
            jinja2
            pkgs.mbake
            mdformat
            #mdformat-black
            mdformat-frontmatter
            mdformat-gfm
            pkgs.pre-commit
            pre-commit-hooks
            #pymarkdownlnt
            #pyproject-fmt
            #python-kacl
            ruff
            pkgs.taplo
          ];

          torchvision = [
            torchvision
          ];

          tutorial = [
            ipykernel
            jupyter
            nbconvert
            papermill
            torchinfo
          ]
          ++ (with finalAttrs.passthru.dependency-groups; coreai ++ coreml ++ torchvision);
        };

        passthru.tests.validate-dependency-groups =
          let
            groups = finalAttrs.passthru.dependency-groups;

            valid =
              lib.isAttrs groups
              && lib.all lib.isList (lib.attrValues groups)
              && lib.all lib.isDerivation (lib.concatLists (lib.attrValues groups));
          in
          assert lib.assertMsg valid
            "coreai-optimization: every dependency-group member must be a derivation";
          pkgs.runCommand "validate-dependency-groups" { } ''
            touch "$out"
          '';

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

      coreai-optimization-tests = buildPythonPackage (finalAttrs: {
        pname = "${coreai-optimization.pname}-tests";
        inherit (coreai-optimization) src version;

        pyproject = false;
        dontBuild = true;

        postUnpack = ''
          export CFFIXED_USER_HOME=$TMPDIR
          export HOME=$CFFIXED_USER_HOME
          export PATH=$PATH:/usr/bin
        '';

        dependencies = [
          coreai-optimization
        ]
        ++ coreai-optimization.dependency-groups.dev;

        nativeCheckInputs = finalAttrs.passthru.dependency-groups.test;

        passthru.dependency-groups = {
          test = [
            junitparser
            pytest-cov
            pytest-xdist
            pytestCheckHook
          ];
        };

        pytestFlags = [
        ];

        enabledTestPaths = [
          "tests"
        ];

        disabledTests = [
        ];

        disabledTestPaths = [
          # missing pyreporoot module
          "tests/test_nox_utils.py"

          # git does not work
          "tests/devtools/test_add_license_header.py"

          # coremltools problems?
          "tests/export/export_utils.py"
          "tests/export/test_eager_mil_export.py"
          "tests/export/test_kmeans_export.py"
          "tests/export/test_pruning_export.py"
        ];

        installPhase = ''
          mkdir -p $out
          touch $out/passed
        '';

        __noChroot = true;
      });
    in
    {
      checks = {
        inherit (coreai-optimization.tests) validate-dependency-groups;
        inherit coreai-optimization-tests;
      };

      packages = {
        inherit coreai-optimization coreai-optimization-wheel;
      };
    };
}
