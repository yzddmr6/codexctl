#!/bin/sh
# Symlink codexctl onto PATH.
set -eu

repo=$(cd "$(dirname "$0")" && pwd)
bin_dir=${CODEXCTL_BIN_DIR:-"$HOME/.local/bin"}

mkdir -p "$bin_dir"
chmod +x "$repo/codexctl.py"
ln -sfn "$repo/codexctl.py" "$bin_dir/codexctl"

echo "linked $bin_dir/codexctl"
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) echo "warning: $bin_dir is not on PATH" >&2 ;;
esac
