{ inputs, ... }:
{
  perSystem =
    {
      config,
      final,
      lib,
      ...
    }:
    let
      _coreai-torch_ = inputs.flake.lib.metadataForFlakeInput inputs.self inputs.coreai-torch;

      python = final.python;
      pythonVersionMajor = lib.versions.major python.version;

      format = "wheel";

      coreai-torch = python.pkgs.buildPythonPackage {
        inherit (_coreai-torch_) pname version;
        inherit format;

        src = python.pkgs.fetchPypi {
          pname = builtins.replaceStrings [ "-" ] [ "_" ] _coreai-torch_.pname;
          inherit (_coreai-torch_) version;
          inherit format;
          hash = "sha256-sQnACQ2DsKjrcwL+ojFM88uNqVdHf3sxuOw2SAqUokc=";
          platform = "any";
          python = "py${pythonVersionMajor}";
          dist = "py${pythonVersionMajor}";
        };

        dependencies = with python.pkgs; [
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

        nativeBuildInputs = with python.pkgs; [
          pythonRelaxDepsHook
        ];

        pythonImportsCheck = [
          "coreai_torch"
        ];

        pythonRelaxDeps = true;

        dontStrip = true;
        doCheck = false;
      };
    in
    {
      packages = {
        inherit coreai-torch;
      };
    };
}
