{
  perSystem =
    {
      config,
      final,
      lib,
      pkgs,
      ...
    }:
    let
      packageOverrides =
        pyFinal: _pyPrev: with pyFinal; {
          torch = torch_2_9_1;
          torchao = torchao_0_15_0;
          torchaudio = torchaudio_2_8_0;
          torchcodec = torchcodec_0_7_0;
          torchvision = torchvision_0_23_0;
        };
    in
    {
      overlayAttrs = {
        pythonPackagesExtensions =
          pkgs.pythonPackagesExtensions ++ config.pythonPackagesExtensions ++ [ packageOverrides ];

        coreai =
          let
            python = final.python313;
          in
          {
            python = {
              self = python;
              inherit (python) pkgs version;
              versionMajor = lib.versions.major python.version;
              versionMajorMinor = lib.versions.major python.version + "." + lib.versions.minor python.version;
              versionMajorMinorCompact = lib.versions.major python.version + lib.versions.minor python.version;
            };
          };
      };
    };
}
