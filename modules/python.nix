{
  perSystem =
    {
      final,
      lib,
      pkgs,
      ...
    }:
    {
      overlayAttrs = {
        pythonPackagesExtensions = pkgs.pythonPackagesExtensions ++ [
          #packageOverrides
        ];

        coreai =
          let
            python = final.python313;
          in
          {
            python = {
              self = python;
              inherit (python) pkgs version;
              versionMajor = lib.versions.major python.version;
              versionMajorMinor = lib.versions.major python.version + "." + lib.versions.minor python.version;
              versionMajorMinorCompact = lib.versions.major python.version + lib.versions.minor python.version;
            };
          };
      };
    };
}
