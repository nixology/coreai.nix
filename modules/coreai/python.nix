{
  perSystem =
    {
      final,
      lib,
      pkgs,
      ...
    }:
    {
      overlayAttrs =
        let
          packageOverrides = _pythonFinal: pythonPrev: {
            h5py = pythonPrev.h5py.overrideAttrs (_: {
              doInstallCheck = false;
            });
            pyarrow = pythonPrev.pyarrow.overrideAttrs (_: {
              doInstallCheck = false;
            });
          };
        in
        {
          pythonPackagesExtensions = pkgs.pythonPackagesExtensions ++ [
            packageOverrides
          ];

          coreai =
            let
              python = final.python312;
            in
            {
              python = {
                self = python;
                inherit (python) pkgs version;
                versionMajor = lib.versions.major python.version;
                versionMajorMinorCompact = lib.versions.major python.version + lib.versions.minor python.version;
              };
            };
        };
    };
}
