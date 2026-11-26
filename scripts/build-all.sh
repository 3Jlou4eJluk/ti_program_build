#!/usr/bin/env bash
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/luna.sh"
LUNA=$(find_luna)
export LUNA
for source_dir in "$ROOT"/libs/*/Document.xml; do
    dir=${source_dir%/Document.xml}
    "$ROOT/scripts/build.sh" "${dir##*/}"
done
for source_file in "$ROOT"/lua/*.lua; do
    name=${source_file##*/}
    "$ROOT/scripts/build-lua.sh" "${name%.lua}"
done
python3 "$ROOT/examples/econometrics/build.py" --luna "$LUNA"
