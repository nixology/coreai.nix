{
  perSystem =
    { final, ... }:
    let
      inherit (final)
        fetchFromGitHub
        ;

      packageOverrides =
        pyFinal: _pyPrev:
        let
          inherit (pyFinal) callPackage;

          torchaudio_2_8_0 = callPackage (fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "01b6809f7f9d1183a2b3e081f0a1e6f8f415cb09";
            rootDir = "pkgs/development/python-modules/torchaudio";
            sha256 = "sha256-925ytIZgOJ4J1LhJWewFY8rjH5KX5bgV2zP77oFyVO8=";
          }) { };
        in
        {
          inherit
            torchaudio_2_8_0
            ;
        };
    in
    {
      pythonPackagesExtensions = [
        packageOverrides
      ];
    };
}
