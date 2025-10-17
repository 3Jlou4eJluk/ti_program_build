#!/bin/bash
# Build all TI-Nspire libraries and Lua programs

set -e

LIBS_DIR="libs"
LUA_DIR="lua"
BUILD_SCRIPT="scripts/build.sh"
BUILD_LUA_SCRIPT="scripts/build-lua.sh"

echo "=== Building all TI-Nspire programs ==="
echo ""

# Clean build directory
echo "Cleaning build directory..."
rm -f build/*.tns
echo "✓ Build directory cleaned"
echo ""

# Get list of libraries
LIBRARIES=$(ls -1 "$LIBS_DIR")

if [ -z "$LIBRARIES" ]; then
    echo "No libraries found in $LIBS_DIR"
    exit 1
fi

# Build each library
for lib in $LIBRARIES; do
    echo "────────────────────────────────────────"
    $BUILD_SCRIPT "$lib"
    echo ""
done

echo "════════════════════════════════════════"
echo "✓ All libraries built successfully"
echo ""

# Build Lua programs
echo "=== Building Lua programs ==="
echo ""

for lua_file in "$LUA_DIR"/*.lua; do
    if [ -f "$lua_file" ]; then
        lua_name=$(basename "$lua_file" .lua)
        echo "────────────────────────────────────────"
        $BUILD_LUA_SCRIPT "$lua_name"
        echo ""
    fi
done

echo "════════════════════════════════════════"
echo "✓ All programs built successfully"
echo ""
echo "Built files:"
ls -lh build/*.tns
