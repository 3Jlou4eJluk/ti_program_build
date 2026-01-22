#!/bin/bash

# Build script for Lua programs

set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/build-lua.sh <lua_file_without_extension>"
    echo "Example: ./scripts/build-lua.sh example"
    echo ""
    echo "Available Lua programs:"
    ls -1 lua/*.lua 2>/dev/null | sed 's/lua\//  - /' | sed 's/\.lua$//' || echo "  (none found)"
    exit 1
fi

LUA_NAME="$1"
LUA_FILE="lua/${LUA_NAME}.lua"
OUTPUT_FILE="build/${LUA_NAME}.tns"

# Check if Lua file exists
if [ ! -f "$LUA_FILE" ]; then
    echo "Error: Lua file not found: $LUA_FILE"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p build

echo "Building Lua program: $LUA_NAME"
echo "Source: $LUA_FILE"
echo "Output: $OUTPUT_FILE"
echo ""

# Build using Luna
../Luna/luna "$LUA_FILE" "$OUTPUT_FILE"

echo ""
echo "✓ Build successful: $OUTPUT_FILE"
