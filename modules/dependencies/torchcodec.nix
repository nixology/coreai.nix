{
  perSystem =
    { final, ... }:
    let
      inherit (final)
        applyPatches
        fetchFromGitHub
        ffmpeg_7
        ;

      packageOverrides =
        pyFinal: _pyPrev:
        let
          inherit (pyFinal) callPackage;

          torchcodec_0_7_0 = callPackage (applyPatches {
            src = fetchFromGitHub {
              owner = "NixOS";
              repo = "nixpkgs";
              rev = "40856f9ca8682d20508c382d8e948aad557747da";
              rootDir = "pkgs/development/python-modules/torchcodec";
              sha256 = "sha256-ixbgFF8RLQELl1vds3fWWSId7c86fWoZW88jC4uurfc=";
            };

            postPatch = ''
              substituteInPlace default.nix \
                --replace-fail \
                  'version = "0.8.1";' \
                  'version = "0.7.0";' \
                --replace-fail \
                  'hash = "sha256-trYS4sRPSNmQLHZZS174zxbu74LT+39N23zOJdWwN6Q=";' \
                  'hash = "sha256-zPPyBY/SHyJBFm/KRJFrlli4kswfSkEgLqR+/n6cFBk=";' \
                --replace-fail \
                  'I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION = true;' \
                  'I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION = true;
                  TORCHCODEC_DISABLE_COMPILE_WARNING_AS_ERROR = true;'

              sed -i \
                '/substituteInPlace test\/test_transform_ops.py \\/,+3d' \
                default.nix
            '';
          }) { ffmpeg = ffmpeg_7; };
        in
        {
          inherit
            torchcodec_0_7_0
            ;
        };
    in
    {
      pythonPackagesExtensions = [
        packageOverrides
      ];
    };
}
