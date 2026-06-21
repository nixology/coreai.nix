{
  perSystem =
    {
      config,
      final,
      lib,
      ...
    }:
    with final.coreai.python.pkgs;
    let
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
              ${python.interpreter} -m venv "${venvDir}"
            fi

            source "${venvDir}/bin/activate"
          '';
        packages = [
          config.packages.coreai-optimization
          config.packages.coreai-torch
          (final.coreai.python.self.withPackages (
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
