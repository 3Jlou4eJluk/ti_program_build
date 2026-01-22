#!/bin/bash
# Build a single TI-Nspire library

set -e

# Check if library name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <library_name>"
    echo "Example: $0 econ"
    echo ""
    echo "Available libraries:"
    ls -1 libs/
    exit 1
fi

LIB_NAME=$1
LIB_DIR="libs/$LIB_NAME"
BUILD_DIR="build"
LUNA="../Luna/luna"

# Check if library exists
if [ ! -d "$LIB_DIR" ]; then
    echo "Error: Library '$LIB_NAME' not found in libs/"
    echo "Available libraries:"
    ls -1 libs/
    exit 1
fi

# Check if required files exist
if [ ! -f "$LIB_DIR/Document.xml" ]; then
    echo "Error: $LIB_DIR/Document.xml not found"
    exit 1
fi

if [ ! -f "$LIB_DIR/Problem1.xml" ]; then
    echo "Error: $LIB_DIR/Problem1.xml not found"
    exit 1
fi

# Check if Luna exists
if [ ! -f "$LUNA" ]; then
    echo "Error: Luna not found at $LUNA"
    echo "Please build Luna first: cd ../Luna && make"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Build the library
echo "Building library: $LIB_NAME"
echo "Source: $LIB_DIR"
echo "Output: $BUILD_DIR/$LIB_NAME.tns"
echo ""

$LUNA "$LIB_DIR/Document.xml" "$LIB_DIR/Problem1.xml" "$BUILD_DIR/$LIB_NAME.tns"

echo ""
echo "✓ Build successful: $BUILD_DIR/$LIB_NAME.tns"
