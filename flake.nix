{
  description = ''
    Bridges PyTorch and Core AI. Convert existing models to Core AI IR,
    or author new ones from PyTorch via composite ops, custom op lowerings,
    and inline Metal GPU kernels.
  '';

  inputs.flake.url = "github:nixology/flake.nix";

  inputs.coreai-models.url = "github:apple/coreai-models/0.1.0";
  inputs.coreai-models.flake = false;

  inputs.coreai-models-unstable.url = "github:apple/coreai-models";
  inputs.coreai-models-unstable.flake = false;

  inputs.coreai-optimization.url = "github:apple/coreai-optimization/v0.2.0";
  inputs.coreai-optimization.flake = false;

  inputs.coreai-torch.url = "github:apple/coreai-torch/v0.4.0";
  inputs.coreai-torch.flake = false;

  inputs.coremltools.url = "github:apple/coremltools/9.0";
  inputs.coremltools.flake = false;

  inputs.mlx.url = "github:nixology/mlx.nix";
  inputs.mlx.inputs.flake.follows = "flake";
  inputs.mlx.inputs.models.follows = "models";

  inputs.models.url = "github:nixology/models.nix";
  inputs.models.inputs.flake.follows = "flake";

  inputs.yuvio.url = "github:labradon/yuvio/v1.6";
  inputs.yuvio.flake = false;

  outputs =
    inputs: with inputs.flake.lib; mkFlake { inherit inputs; } { imports = modulesIn ./modules; };
}
