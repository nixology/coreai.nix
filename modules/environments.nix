{
  perSystem =
    {
      config,
      final,
      inputs',
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

            export HF_HUB_CACHE="${inputs'.models.packages.cache}";
          '';
        packages = [
          uv
          config.packages.coreai-optimization
          config.packages.coreai-torch
          (final.coreai.python.self.withPackages (
            ps: with ps; [
              huggingface-hub
              jupyterlab
              notebook
              pip
              pytest
              setuptools
              transformers
            ]
          ))
        ];
      };
    in
    {
      shellEnvironments = {
        default =
          with config.shellEnvironments;
          lib.mkMerge [
            default
            nix
          ];
        uv = default;
      };
    };
}
