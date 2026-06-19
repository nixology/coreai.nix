{ inputs, ... }:
{
  perSystem =
    {
      config,
      final,
      ...
    }:
    with final.coreai.python.pkgs;
    let
      _coreai-torch_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-torch;

      format = "wheel";

      coreai-torch = buildPythonPackage (finalAttrs: {
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

        dontStrip = true;
        doCheck = false;
      });
    in
    {
      packages = {
        inherit coreai-torch;
      };
    };
}
