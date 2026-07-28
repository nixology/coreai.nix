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

        nativeBuildInputs = [
          cmake
          ninja
          setuptools
          wheel
        ];

        dependencies = [
          numpy # >= 1.14.5
          protobuf # >= 3.1.0
          sympy
          tqdm
          packaging
          attrs # >= 21.3.0
          cattrs
          pyaml
        ];

        optional-dependencies = {
          build = [
            numpy # == 2.1.0
            protobuf
            pytest
            setuptools
            six
            sympy
            tqdm
            wheel
            attrs
            cattrs
            pyaml
          ];

          common_test_packages = [
            boto3 # == 1.39.3

            configparser

            olefile # == 0.44
            pandas
            parameterized # == 0.8.1
            pillow
            pytest # == 7.1.2
            pytest-cov
            #pytest-sugar
            pytest-timeout
            pytest-asyncio
            pytest-xdist

            scikit-learn # == 1.5.1

            six
            sympy # > 1.6
            gast # == 0.4.0

            mock
            wrapt
            tqdm

            transformers # == 4.38.2
            peft # == 0.13.2
          ];

          docs = [
            Babel
            MarkupSafe
            Pygments
            Sphinx # == 7.4.7
            alabaster
            certifi
            chardet
            docutils
            idna
            imagesize
            myst-parser
            numpy
            numpydoc

            protobuf # ==3.19.6

            pytz
            six
            snowballstemmer
            sphinx-rtd-theme
            sphinx-book-theme
            sphinxcontrib-websupport
            sphinx-gallery
            sphinx-code-tabs
            sphinx-copybutton
            sympy
            typing
            urllib3
            torch # >= 1.13.0
            scikit-learn
            pillow
          ];

          pytorch = [
            torch # == 2.8.0
            torchaudio # >= 2.2.0
            torchvision # >= 0.17.0
            #            torchsr # == 1.0.4

            timm # == 0.6.13

            torchao # == 0.12.0
          ];

          test =
            finalAttrs.passthru.optional-dependencies.common_test_packages
            ++ finalAttrs.passthru.optional-dependencies.pytorch
            ++ [
              numpy # >= 2.0.0

              scipy

              lightgbm # == 4.6.0

              filelock # == 3.6.0
              pytest-flake8 # == 1.0.7
              pytest-xdist # == 3.6.1
              pytest-mock # == 3.8.2
            ];

          test_torch =
            finalAttrs.passthru.optional-dependencies.common_test_packages
            ++ finalAttrs.passthru.optional-dependencies.pytorch
            ++ [
              numpy # >= 2.0.0
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

      coremltools-tests = buildPythonPackage (_finalAttrs: {
        pname = "${coremltools.pname}-tests";
        src = coremltools;
        inherit (coremltools) version;
        sourceRoot = "${python.libPrefix}-${coremltools.pname}-${coremltools.version}/${python.sitePackages}/coremltools/test";

        pyproject = false;
        dontBuild = true;

        # pytest # == 7.1.2
        nativeCheckInputs = [
          pytestCheckHook
          swVers
        ]
        ++ coremltools.optional-dependencies.test;

        dependencies = [
          coremltools
        ];

        preCheck = ''
          mkdir -p "$TMPDIR/tmp"
          export TMPDIR="$TMPDIR/tmp"
        '';

        disabledTestPaths = [
          # api
          "api/test_api_examples.py::TestMLComputePlan::test_mlprogram_compute_plan"
          "api/test_api_examples.py::TestMLProgramConverterExamples::test_build_stateful_model"
          "api/test_api_examples.py::TestMLProgramConverterExamples::test_stateful_model_read_write_state"

          # blob
          "blob/test_weights.py::TestWeightIDSharing::test_multi_functions"

          # ml_program
          "ml_program/experimental/test_compute_plan_utils.py::TestComputePlanUtils::test_remote_proxy"
          "ml_program/experimental/test_perf_utils.py::TestMLModelBenchmarker"
          "ml_program/experimental/test_perf_utils.py::TestTorchMLModelBenchmarker"
          "ml_program/experimental/test_torch_debugging_utils.py::TestTorchModelComparator"
          "ml_program/test_utils.py::TestMultiFunctionDescriptor"
          "ml_program/test_utils.py::TestMultiFunctionModelEnd2End"
          "ml_program/test_utils.py::TestMaterializeSymbolicShapeMLModel"

          # modelpackage
          "modelpackage/test_modelpackage.py::TestCompiledMLModel::test_state"

          # neural_network
          "neural_network/test_numpy_nn_layers.py::CoreML3NetworkStressTest::test_power_iteration_cpu"

          # optimize
          "optimize/torch/quantization/test_coreml_quantizer.py"
          "optimize/coreml/test_post_training_quantization.py::TestPyTorchConverterExamples::test_stateful_accumulator"
          "optimize/torch/conversion/joint/test_joint_compression_conversion.py::test_sparsegpt[joint_pruning_palettization]"
          "optimize/torch/conversion/quantization/test_quantization_conversion.py::test_gptq[4bit]"
          "optimize/torch/quantization/test_configure.py::test_conv_act_fusion[False-GLU-config4]"
          "optimize/torch/quantization/test_configure.py::test_conv_act_fusion[False-SELU-config15]"

          # not architecturally compatible with darwin-arm64
          "xgboost_tests"
        ];

        installPhase = ''
          mkdir -p $out
          touch $out/passed
        '';
      });
    in
    {
      packages = {
        inherit coremltools coremltools-tests;
      };
    };
}
