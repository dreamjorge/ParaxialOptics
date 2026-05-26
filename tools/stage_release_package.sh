#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage_dir="${1:-${root_dir}/build/release-staging}"

rm -rf "$stage_dir"
mkdir -p "$stage_dir"

copy_path() {
  local path="$1"
  if [ -e "$root_dir/$path" ]; then
    mkdir -p "$stage_dir/$(dirname "$path")"
    cp -R "$root_dir/$path" "$stage_dir/$path"
  fi
}

copy_path "+paraxial"
copy_path "ParaxialBeams"
copy_path "tests"
copy_path "examples/canonical"
copy_path "docs/ARCHITECTURE.md"
copy_path "docs/ROADMAP.md"
copy_path "docs/COMPATIBILITY_REDUCTION.md"
copy_path "README.md"
copy_path "CHANGELOG.md"
copy_path "DESCRIPTION"
copy_path "install.m"
copy_path "uninstall.m"
copy_path "setpaths.m"

if [ -f "$root_dir/LICENSE" ]; then
  copy_path "LICENSE"
fi

find "$stage_dir" -type d \( -name .git -o -name .atl -o -name .opencode -o -name openspec \) -prune -exec rm -rf {} +
find "$stage_dir" -type f \( -name '*.asv' -o -name '*~' -o -name '.DS_Store' \) -delete

echo "Release staging directory: $stage_dir"
find "$stage_dir" -maxdepth 2 -type f | sort
