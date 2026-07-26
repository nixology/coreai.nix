# Auto-detect system architecture
system := `nix eval --impure --raw --expr 'builtins.currentSystem'`

coreai-model-registry:
  nix run .#coreai-model-registry -- --list-models

test-models:
  nix build .#checks.{{system}}.coreai-models-tests --option sandbox false -L

test-torch:
  nix build .#checks.{{system}}.coreai-torch-tests --option sandbox false -L

test:
  HF_HUB_CACHE=~/.cache/huggingface/hub uv run pytest python/tests -v
