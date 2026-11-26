#!/usr/bin/env bash
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/luna.sh"

if [[ $# != 1 ]]; then
    echo "Usage: $0 <Lua source name from lua/, without extension>" >&2
    exit 1
fi
source_file="$ROOT/lua/$1.lua"
if [[ ! -f "$source_file" ]]; then
    echo "Missing Lua source: $source_file" >&2
    exit 1
fi
luna=$(find_luna)
mkdir -p "$ROOT/build"
"$luna" "$source_file" "$ROOT/build/$1.tns"
