#!/usr/bin/env bash
# Keep test saves and editor settings separate from player/user data.
set -euo pipefail
cd "$(dirname "$0")/.."
godot_bin="${GODOT_BIN:-godot}"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT
export XDG_DATA_HOME="$test_root/data"
export XDG_CONFIG_HOME="$test_root/config"
export XDG_CACHE_HOME="$test_root/cache"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"

run_check() {
  local log="$1"
  shift
  "$@" 2>&1 | tee "$log"
  if rg -n 'SCRIPT ERROR|Parse Error|ERROR:|FAIL:' "$log"; then
    return 1
  fi
}

run_check godot-import.log timeout 120s "$godot_bin" --headless --editor --path . --quit
run_check godot-foundation.log timeout 30s "$godot_bin" --headless --path . --script ci/test_foundation.gd
run_check godot-resume.log timeout 30s "$godot_bin" --headless --path . --script ci/test_foundation.gd -- --resume
run_check godot-quit.log timeout 10s "$godot_bin" --headless --path . --script ci/test_foundation.gd -- --quit

if [[ "${1:-}" == "--visual" ]]; then
  # A fresh isolated save makes captures deterministic; do not reuse player data.
  export XDG_DATA_HOME="$test_root/visual-data"
  mkdir -p "$XDG_DATA_HOME"
  export LIBGL_ALWAYS_SOFTWARE=1
  mkdir -p ci_artifacts
  run_check godot-visual.log timeout 50s xvfb-run -a "$godot_bin" --path . \
    --rendering-method gl_compatibility --audio-driver Dummy --disable-vsync \
    --script ci/test_foundation.gd -- --capture
  for capture in 01_title_native 02_episode_native 03_dialogue_native 04_continued_native 05_continued_3x 06_replace_save_native; do
    test -s "ci_artifacts/$capture.png"
  done
fi
