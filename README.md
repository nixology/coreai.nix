# coreai.nix

Nix flake that packages Apple's Core AI Python libraries and wires them together with PyTorch into a reproducible development environment.

## Overview

`coreai.nix` bridges PyTorch and Apple's Core AI stack. It lets you convert existing models to the Core AI IR, or author new ones from PyTorch via composite ops, custom op lowerings, and inline Metal GPU kernels — all inside a fully pinned, reproducible Nix environment.

## Packages

| Package | Source | Description |
|---|---|---|
| `coreai-core` | `apple/coreai-models` | Core runtime and IR types (`macosx_26_0_arm64` wheel) |
| `coreai-opt` | `apple/coreai-optimization` | Model optimization passes (quantization, graph transforms) |
| `coreai-torch` | `apple/coreai-torch` | PyTorch → Core AI IR conversion and op lowering |
| `coremltools` | `apple/coremltools` | Core ML model authoring and conversion (`macosx_11_0_arm64` wheel) |

## Requirements

- macOS (Apple Silicon — `arm64`)
- [Nix](https://nixos.org/download) with [flakes enabled](https://nixos.wiki/wiki/Flakes)
- [direnv](https://direnv.net/) (optional, for automatic shell activation)

## Usage

### Enter the dev shell

```bash
nix develop
```

Or, with direnv already installed and hooked into your shell:

```bash
direnv allow
```

The shell provides Python 3.12 with `coreai-opt`, `coreai-torch`, `huggingface-hub`, `jupyterlab`, and `notebook` available, inside an auto-managed `.venv`.

### Build individual packages

```bash
# Core runtime
nix build .#coreai-core

# Optimization passes
nix build .#coreai-opt

# PyTorch conversion bridge
nix build .#coreai-torch

# Core ML tools
nix build .#coremltools
```

## Project Structure

```
flake.nix               # Flake inputs and output wiring
modules/
  imports.nix           # Component imports (overlay, shellEnvs, packages, …)
  overlay.nix           # Python 3.12 override (disables flaky h5py / pyarrow tests)
  shellEnvs.nix         # Default dev shell with venv bootstrapping
  packages/
    coreai-core.nix     # coreai-core + yuvio wheel definitions
    coreai-opt.nix      # coreai-opt wheel definition
    coreai-torch.nix    # coreai-torch wheel definition
    coremltools.nix     # coremltools wheel definition
```

## Dependency Graph

```
coreai-torch  ──► coreai-core
                  ├── ml-dtypes, numpy, pillow, typing-extensions
                  └── yuvio (numpy, psutil)

coreai-opt    ──► coremltools
                  ├── numpy, protobuf, sympy, tqdm, attrs, cattrs, pyaml
              ──► numpy, pydantic, rich, safetensors, torch, torchao, tqdm

coremltools   ──► numpy, protobuf, sympy, tqdm, attrs, cattrs, pyaml
```
