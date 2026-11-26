#!/usr/bin/env bash
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/luna.sh"

if [[ $# != 1 ]]; then
    echo "Usage: $0 <library name from libs/>" >&2
    exit 1
fi
source_dir="$ROOT/libs/$1"
for file in Document.xml Problem1.xml; do
    if [[ ! -f "$source_dir/$file" ]]; then
        echo "Missing library source: $source_dir/$file" >&2
        exit 1
    fi
done
luna=$(find_luna)
mkdir -p "$ROOT/build"
"$luna" "$source_dir/Document.xml" "$source_dir/Problem1.xml" "$ROOT/build/$1.tns"
