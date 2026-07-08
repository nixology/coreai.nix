{ inputs, ... }:
{
  perSystem =
    { final, ... }:
    with final.coreai.python.pkgs;
    let
      _coremltools_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coremltools;

      format = "wheel";

      pythonVersion = final.coreai.python.versionMajorMinor;

      coremltools = buildPythonPackage (finalAttrs: {
        inherit (_coremltools_) pname version;
        inherit format;

        src = fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
          inherit (finalAttrs) version;
          inherit format;
          hash =
            if pythonVersion == "3.13" then
              "sha256-ny+Fi+7H9dSGzRpZrvtFLVk0fiNmcLZ9syV5W/aS9IA="
            else if pythonVersion == "3.12" then
              "sha256-cHnotv9aY/DiwI7uuGc+TquMojHUsurk9/sAXg0IqM0="
            else
              throw "coremltools: unsupported Python version ${pythonVersion}";
          platform = "macosx_11_0_arm64";
          python = "cp${final.coreai.python.versionMajorMinorCompact}";
          dist = "cp${final.coreai.python.versionMajorMinorCompact}";
        };

        dependencies = [
          attrs
          cattrs
          numpy
          protobuf
          pyaml
          sympy
          tqdm
        ];

        pythonImportsCheck = [
          "coremltools"
        ];
      });
    in
    {
      packages = {
        inherit coremltools;
      };
    };
}
