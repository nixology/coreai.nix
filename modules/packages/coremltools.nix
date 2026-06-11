{ inputs, ... }:
{
  perSystem =
    { final, lib, ... }:
    let
      _coremltools_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coremltools;

      python = final.python;
      pythonVersionMajorMinorCompact =
        lib.versions.major python.version + lib.versions.minor python.version;

      format = "wheel";

      coremltools = python.pkgs.buildPythonPackage {
        inherit (_coremltools_) pname version;
        inherit format;

        src = python.pkgs.fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] _coremltools_.pname;
          inherit (_coremltools_) version;
          inherit format;
          hash = "sha256-cHnotv9aY/DiwI7uuGc+TquMojHUsurk9/sAXg0IqM0=";
          platform = "macosx_11_0_arm64";
          python = "cp${pythonVersionMajorMinorCompact}";
          dist = "cp${pythonVersionMajorMinorCompact}";
        };

        propagatedBuildInputs = with python.pkgs; [
          attrs
          cattrs
          numpy
          protobuf
          pyaml
          sympy
          tqdm
        ];

        dontBuild = true;
        dontStrip = true;
        doCheck = false;
      };
    in
    {
      packages = {
        inherit coremltools;
      };
    };
}
