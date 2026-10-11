#!/usr/bin/env bash
# Keep test saves and editor settings separate from player/user data.
set -euo pipefail
cd "$(dirname "$0")/.."
godot_bin="${GODOT_BIN:-godot}"
if [[ " $* " == *" --clean "* ]]; then
  rm -rf .godot
fi
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
run_check godot-resources.log timeout 30s "$godot_bin" --headless --path . --script ci/test_resources.gd
run_check godot-content.log timeout 30s "$godot_bin" --headless --path . --script ci/test_content.gd
run_check godot-saves.log timeout 30s "$godot_bin" --headless --path . --script ci/test_saves.gd
run_check godot-foundation.log timeout 30s "$godot_bin" --headless --path . --script ci/test_foundation.gd
run_check godot-resume.log timeout 30s "$godot_bin" --headless --path . --script ci/test_foundation.gd -- --resume
run_check godot-quit.log timeout 10s "$godot_bin" --headless --path . --script ci/test_foundation.gd -- --quit

if [[ " $* " == *" --visual "* ]]; then
  # A fresh isolated save makes captures deterministic; do not reuse player data.
  visual_root="$(mktemp -d)"
  trap 'rm -rf "$test_root" "$visual_root"' EXIT
  export XDG_DATA_HOME="$visual_root/data"
  export XDG_CONFIG_HOME="$visual_root/config"
  export XDG_CACHE_HOME="$visual_root/cache"
  mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
  export LIBGL_ALWAYS_SOFTWARE=1
  mkdir -p ci_artifacts
  run_check godot-visual.log timeout 50s xvfb-run -a "$godot_bin" --path . \
    --rendering-method gl_compatibility --audio-driver Dummy --disable-vsync \
    --script ci/test_foundation.gd -- --capture
  for capture in 01_approved_title 02_adam_intro 03_rock_conversation 04_first_jeff 05_eve_gameplay 06_fall_boxes 07_leaves_used; do
    test -s "ci_artifacts/$capture.png"
  done
fi
