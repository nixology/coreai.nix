{
  perSystem =
    { final, ... }:
    let
      inherit (final)
        lib
        stdenv
        fetchFromGitHub
        replaceVars

        # nativeBuildInputs
        cmake

        # buildInputs
        cpuinfo
        llvmPackages
        ;

      packageOverrides =
        pyFinal: _pyPrev:
        let
          inherit (pyFinal)
            buildPythonPackage
            callPackage

            # build-system
            setuptools

            # dependencies
            torch
            torchvision

            # tests
            bitsandbytes
            expecttest
            fire
            pytest-xdist
            pytestCheckHook
            parameterized
            tabulate
            transformers
            unittest-xml-reporting
            ;

          torchao_0_12_0 = buildPythonPackage (_finalAttrs: rec {
            pname = "ao";
            version = "0.12.0";
            pyproject = true;

            src = fetchFromGitHub {
              owner = "pytorch";
              repo = "ao";
              tag = "v${version}";
              hash = "sha256-J0aUce9Bu03Ff0ZjDKt39ZAX/UAif1S96SI7Gk4Hppw=";
            };

            patches = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
              ./use-system-cpuinfo.patch
              (replaceVars ./use-llvm-openmp.patch {
                inherit (llvmPackages) openmp;
              })
            ];

            build-system = [
              setuptools
            ];

            nativeBuildInputs = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
              cmake
            ];
            dontUseCmakeConfigure = true;

            buildInputs = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
              cpuinfo
            ];

            propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
              # Otherwise, torch will fail to include `omp.h`:
              # torch._inductor.exc.InductorError: CppCompileError: C++ compile error
              # OpenMP support not found.
              llvmPackages.openmp
            ];

            dependencies = [
              torch
              torchvision
            ];

            env = {
              USE_SYSTEM_LIBS = true;
            };

            # Otherwise, the tests are loading the python module from the source instead of the installed one
            preCheck = ''
              rm -rf torchao
            '';

            pythonImportsCheck = [
              "torchao"
            ];

            nativeCheckInputs = [
              bitsandbytes
              expecttest
              fire
              parameterized
              pytest-xdist
              pytestCheckHook
              tabulate
              transformers
              unittest-xml-reporting
            ];

            disabledTests = [
              # Requires internet access
              "test_on_dummy_distilbert"

              # FileNotFoundError: [Errno 2] No such file or directory: 'checkpoints/meta-llama/Llama-2-7b-chat-hf/model.pth'
              "test_gptq_mt"
            ]
            ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
              # AssertionError: tensor(False) is not true
              "test_quantize_per_token_cpu"

              # RuntimeError: failed to initialize QNNPACK
              "test_smooth_linear_cpu"

              # torch._inductor.exc.InductorError: LoweringException: AssertionError: Expect L1_cache_size > 0 but got 0
              "test_int8_weight_only_quant_with_freeze_0_cpu"
              "test_int8_weight_only_quant_with_freeze_1_cpu"
              "test_int8_weight_only_quant_with_freeze_2_cpu"

              # FileNotFoundError: [Errno 2] No such file or directory: 'test.pth'
              "test_save_load_int4woqtensors_2_cpu"
              "test_save_load_int8woqtensors_0_cpu"
              "test_save_load_int8woqtensors_1_cpu"
            ]
            ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
              # AssertionError: Scalars are not equal!
              "test_comm"
              "test_fsdp2"
              "test_fsdp2_correctness"
              "test_precompute_bitnet_scale"
              "test_qlora_fsdp2"
              "test_uneven_shard"
            ]
            ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
              # RuntimeError: No packed_weights_format was selected
              "TestIntxOpaqueTensor"
              "test_accuracy_kleidiai"
            ]
            ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
              # Flaky: [gw0] node down: keyboard-interrupt
              "test_int8_weight_only_quant_with_freeze_0_cpu"
              "test_int8_weight_only_quant_with_freeze_1_cpu"
              "test_int8_weight_only_quant_with_freeze_2_cpu"
            ];

            disabledTestPaths = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
              # Require unpackaged 'coremltools'
              #"test/prototype/test_groupwise_lowbit_weight_lut_quantizer.py"

              # AttributeError: '_OpNamespace' 'mkldnn' object has no attribute '_is_mkldnn_acl_supported'
              "test/quantization/pt2e/test_arm_inductor_quantizer.py"
              "test/quantization/pt2e/test_x86inductor_fusion.py"
              "test/quantization/pt2e/test_x86inductor_quantizer.py"
            ];

            meta = {
              description = "PyTorch native quantization and sparsity for training and inference";
              homepage = "https://github.com/pytorch/ao";
              changelog = "https://github.com/pytorch/ao/releases/tag/v${version}";
              license = lib.licenses.bsd3;
              maintainers = with lib.maintainers; [ GaetanLepage ];
            };
          });

          torchao_0_15_0 =
            (callPackage (fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "f3d401a14d202af6ef16fa1657dfc9ef56c87692";
              rootDir = "pkgs/development/python-modules/torchao";
              sha256 = "sha256-F/F7TtN11Z4BJWm8OaUTne6SzhbZFebJL/+z3sCu/eY=";
            }) { }).overridePythonAttrs
              (oldAttrs: {
                dependencies = oldAttrs.dependencies ++ [
                  torchvision
                ];
                disabledTestPaths = oldAttrs.disabledTestPaths ++ [
                  # RuntimeError: quantized engine NoQEngine is not supported
                  "test/quantization/pt2e/test_quantize_pt2e_qat.py::TestQuantizePT2EQATModels"
                ];
              });
        in
        {
          inherit
            torchao_0_12_0
            torchao_0_15_0
            ;
        };
    in
    {
      pythonPackagesExtensions = [
        packageOverrides
      ];
    };
}
