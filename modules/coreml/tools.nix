{ inputs, ... }:
{
  perSystem =
    { final, ... }:
    with final.coreai.python.pkgs;
    let
      _coremltools_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coremltools;

      coremltools = buildPythonPackage (finalAttrs: {
        inherit (_coremltools_) pname src version;
        pyproject = true;

        buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
          final.apple-sdk_26
          (final.darwinMinVersionHook "15.0")
        ];

        dependencies = [
          numpy # == 2.1.0
          protobuf
          six
          sympy
          tqdm
          packaging
          attrs
          cattrs
          pyaml
        ]
        ++ finalAttrs.passthru.optional-dependencies.torch;

        nativeBuildInputs = [
          cmake
          ninja
          setuptools
          wheel
        ];

        optional-dependencies = {
          sklearn = [
            scikit-learn # <= 1.5.1
          ];

          lightgbm = [
            lightgbm # == 4.6.0
          ];

          torch = [
            torch # == 2.8.0
            torchaudio
            torchvision
            torchao # == 0.12.0
            timm # == 0.6.13
          ];

          transformers = [
            transformers
          ];

          scipy = [
            scipy
          ];

          # Convenience aggregate.
          all = lib.concatLists [
            finalAttrs.passthru.optional-dependencies.sklearn
            finalAttrs.passthru.optional-dependencies.lightgbm
            finalAttrs.passthru.optional-dependencies.torch
            finalAttrs.passthru.optional-dependencies.transformers
            finalAttrs.passthru.optional-dependencies.scipy
          ];
        };

        cmakeFlags = [
          "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
          "-DCMAKE_BUILD_TYPE=Release"
        ];

        configurePhase = ''
          runHook preConfigure

          cmake -S . -B build ${lib.concatStringsSep " " finalAttrs.cmakeFlags}

          runHook postConfigure
        '';

        preBuild = ''
          cmake --build build

          install -Dm755 build/libmilstoragepython.dylib coremltools/libmilstoragepython.so
          install -Dm755 build/libmodelpackage.dylib coremltools/libmodelpackage.so
          install -Dm755 build/libcoremlpython.dylib coremltools/libcoremlpython.so
        '';

        pythonImportsCheck = [
          "coremltools.libmilstoragepython"
          "coremltools.libmodelpackage"
          "coremltools.libcoremlpython"
        ];
      });

      swVers = final.writeShellScriptBin "sw_vers" ''
        exec /usr/bin/sw_vers "$@"
      '';

      coremltools-tests = buildPythonPackage {
        pname = "${coremltools.pname}-tests";
        src = coremltools;
        inherit (coremltools) version;

        pyproject = false;
        dontBuild = true;

        # pytest # == 7.1.2
        nativeCheckInputs = [
          pytestCheckHook
          swVers
        ];

        dependencies = [
          coremltools

          boto3 # == 1.39.3

          configparser

          olefile # == 0.44
          pandas
          parameterized # == 0.8.1
          pillow

          filelock # == 3.6.0

          pytest-cov
          pytest-timeout
          pytest-asyncio
          pytest-xdist # == 3.6.1
          pytest-flake8 # == 1.0.7
          pytest-mock # == 3.8.2

          scikit-learn # == 1.5.1

          six
          sympy
          gast # == 0.4.0

          mock
          wrapt
          tqdm

          transformers # == 4.38.2
          peft # == 0.13.2
        ];

        preCheck = ''
          mkdir -p "$TMPDIR/tmp"
          export TMPDIR="$TMPDIR/tmp"
        '';

        enabledTestPaths = [
          "${python.sitePackages}/coremltools/test"
        ];

        disabledTestPaths = [
          # api
          "${python.sitePackages}/coremltools/test/api/test_api_examples.py::TestMLComputePlan::test_mlprogram_compute_plan"
          "${python.sitePackages}/coremltools/test/api/test_api_examples.py::TestMLProgramConverterExamples::test_build_stateful_model"
          "${python.sitePackages}/coremltools/test/api/test_api_examples.py::TestMLProgramConverterExamples::test_stateful_model_read_write_state"

          # blob
          "${python.sitePackages}/coremltools/test/blob/test_weights.py::TestWeightIDSharing::test_multi_functions"

          # ml_program
          "${python.sitePackages}/coremltools/test/ml_program/experimental/test_compute_plan_utils.py::TestComputePlanUtils::test_remote_proxy"
          "${python.sitePackages}/coremltools/test/ml_program/experimental/test_perf_utils.py::TestMLModelBenchmarker"
          "${python.sitePackages}/coremltools/test/ml_program/experimental/test_perf_utils.py::TestTorchMLModelBenchmarker"
          "${python.sitePackages}/coremltools/test/ml_program/experimental/test_torch_debugging_utils.py::TestTorchModelComparator"
          "${python.sitePackages}/coremltools/test/ml_program/test_utils.py::TestMultiFunctionDescriptor"
          "${python.sitePackages}/coremltools/test/ml_program/test_utils.py::TestMultiFunctionModelEnd2End"
          "${python.sitePackages}/coremltools/test/ml_program/test_utils.py::TestMaterializeSymbolicShapeMLModel"

          # modelpackage
          "${python.sitePackages}/coremltools/test/modelpackage/test_modelpackage.py::TestCompiledMLModel::test_state"

          # neural_network
          "${python.sitePackages}/coremltools/test/neural_network/test_numpy_nn_layers.py::CoreML3NetworkStressTest::test_power_iteration_cpu"

          # optimize
          "${python.sitePackages}/coremltools/test/optimize/torch/quantization/test_coreml_quantizer.py"
          "${python.sitePackages}/coremltools/test/optimize/coreml/test_post_training_quantization.py::TestPyTorchConverterExamples::test_stateful_accumulator"

          # not architecturally compatible with darwin-arm64
          "${python.sitePackages}/coremltools/test/xgboost_tests"
        ];

        installPhase = ''
          mkdir -p $out
          touch $out/passed
        '';
      };
    in
    {
      packages = {
        inherit coremltools coremltools-tests;
      };
    };
}
