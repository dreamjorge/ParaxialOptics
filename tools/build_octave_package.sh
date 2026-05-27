#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 VERSION [OUTPUT_TARBALL]" >&2
  exit 2
fi

version="$1"
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="${2:-${root_dir}/simulation_scripts-${version}.tar.gz}"
work_dir="${root_dir}/build/octave-package"
stage_dir="${work_dir}/release-staging"
package_name="simulation_scripts-${version}"
package_dir="${work_dir}/${package_name}"

rm -rf "$work_dir"
mkdir -p "$package_dir/inst"

bash "${root_dir}/tools/stage_release_package.sh" "$stage_dir" >/dev/null

cp "$stage_dir/DESCRIPTION" "$package_dir/DESCRIPTION"
sed "s/^Version:.*/Version: ${version}/" "$package_dir/DESCRIPTION" > "$package_dir/DESCRIPTION.tmp"
mv "$package_dir/DESCRIPTION.tmp" "$package_dir/DESCRIPTION"
cp "$stage_dir/COPYING" "$package_dir/COPYING"

(
  cd "$stage_dir"
  tar --exclude='./DESCRIPTION' --exclude='./COPYING' -cf - .
) | (
  cd "$package_dir/inst"
  tar -xf -
)

# Octave packages scan installed .m files to build help caches. Keep the
# installable package focused on runtime code and public documentation so
# tests, examples, and vendored legacy demos cannot shadow core functions or
# trip classdef filename checks during `pkg install`.
rm -rf "$package_dir/inst/tests"
rm -rf "$package_dir/inst/examples"
rm -rf "$package_dir/inst/ParaxialBeams/Addons"

mkdir -p "$(dirname "$output")"
(
  cd "$work_dir"
  tar -czf "$output" "$package_name"
)

ls -lh "$output"
