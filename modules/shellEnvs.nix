{
  perSystem =
    {
      config,
      final,
      lib,
      ...
    }:
    let
      python = final.python;

      default = {
        mkShellOverrides = {
          stdenv = final.stdenvNoCC;
        };
        shellHook =
          let
            venvDir = "./.venv";
          in
          ''
            if [ -d ${venvDir} ]; then
              echo "Skipping venv creation, ${venvDir} already exists."
            else
              echo "Creating new venv environment in path: '${venvDir}'"
              ${python.pkgs.python.interpreter} -m venv "${venvDir}"
            fi

            source "${venvDir}/bin/activate"
          '';
        packages = [
          config.packages.coreai-opt
          config.packages.coreai-torch
          (python.withPackages (
            ps: with ps; [
              huggingface-hub
              jupyterlab
              notebook
              pip
              setuptools
            ]
          ))
        ];
      };
    in
    {
      shellEnvs.default =
        with config.shellEnvs;
        lib.mkMerge [
          default
          nix
        ];
    };
}
