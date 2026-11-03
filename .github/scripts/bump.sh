#!/usr/bin/env bash
# Point the add-on at a new Famlin version: config.yaml, Dockerfile, CHANGELOG.
# Usage: bump.sh X.Y.Z   (env: BREAKING=true adds a warning line, ROOT=repo root)
set -euo pipefail

version="${1:?usage: bump.sh X.Y.Z}"
if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "'$version' is not an X.Y.Z version" >&2
  exit 1
fi
root="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$root"

sed -i -E "s#^version: .*#version: \"${version}\"#" famlin/config.yaml
sed -i -E "s#^(ARG FAMLIN_VERSION=).*#\1${version}#" famlin/Dockerfile
grep -qx "version: \"${version}\"" famlin/config.yaml
grep -qx "ARG FAMLIN_VERSION=${version}" famlin/Dockerfile

if ! grep -qx "## ${version}" famlin/CHANGELOG.md; then
  {
    echo "# Changelog"
    echo
    echo "## ${version}"
    echo
    echo "- Based on Famlin ${version}, see the [release notes](https://github.com/TimVanOnckelen/famlin/releases/tag/v${version})."
    if [[ "${BREAKING:-false}" == true ]]; then
      echo "- This release contains breaking changes: read the release notes before updating."
    fi
    tail -n +2 famlin/CHANGELOG.md
  } >CHANGELOG.new
  mv CHANGELOG.new famlin/CHANGELOG.md
fi
