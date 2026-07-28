{
  perSystem =
    { final, ... }:
    let
      inherit (final)
        apple-sdk_26
        fetchFromGitHub
        ;

      packageOverrides =
        pyFinal: _pyPrev:
        let
          inherit (pyFinal) callPackage;

          torchvision_0_23_0 = callPackage (fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "01b6809f7f9d1183a2b3e081f0a1e6f8f415cb09";
            rootDir = "pkgs/development/python-modules/torchvision";
            sha256 = "sha256-nJS6Xrpj3CK9K4/wVDQyV9RfUzARL2zRBJQNkyI4wp8=";
          }) { apple-sdk_13 = apple-sdk_26; };
        in
        {
          inherit
            torchvision_0_23_0
            ;
        };
    in
    {
      pythonPackagesExtensions = [
        packageOverrides
      ];
    };
}
