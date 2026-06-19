{ inputs, ... }:
{
  perSystem =
    { final, ... }:
    with final.coreai.python.pkgs;
    let
      _coremltools_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coremltools;

      format = "wheel";

      coremltools = buildPythonPackage (finalAttrs: {
        inherit (_coremltools_) pname version;
        inherit format;

        src = fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname;
          inherit (finalAttrs) version;
          inherit format;
          hash = "sha256-cHnotv9aY/DiwI7uuGc+TquMojHUsurk9/sAXg0IqM0=";
          platform = "macosx_11_0_arm64";
          python = "cp${final.coreai.python.versionMajorMinorCompact}";
          dist = "cp${final.coreai.python.versionMajorMinorCompact}";
        };

        propagatedBuildInputs = [
          attrs
          cattrs
          numpy
          protobuf
          pyaml
          sympy
          tqdm
        ];

        dontStrip = true;
        doCheck = false;
      });
    in
    {
      packages = {
        inherit coremltools;
      };
    };
}
