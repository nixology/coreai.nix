{
  perSystem =
    { final, pkgs, ... }:
    {
      overlayAttrs = {
        python = final.python312;

        python312 = pkgs.python312.override {
          packageOverrides = _pythonFinal: pythonPrev: {
            h5py = pythonPrev.h5py.overrideAttrs (_oldAttrs: {
              doCheck = false;
              doInstallCheck = false;
            });
            pyarrow = pythonPrev.pyarrow.overrideAttrs (_oldAttrs: {
              doCheck = false;
              doInstallCheck = false;
            });
          };
        };

        # Update python3Packages to use the newly overridden python3
        python312Packages = final.python312.pkgs;
      };
    };
}
