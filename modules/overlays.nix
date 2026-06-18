{
  perSystem =
    { final, pkgs, ... }:
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

          python = final.python312;
        };
    };
}
