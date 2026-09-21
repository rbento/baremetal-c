#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning up..."
make clean
rm -rf .cache .clangd .gdb_history compile_commands.json tags

echo "Building & generating compile_commands.json..."
# Build the debug target so bear captures -DDEBUG and -g for clangd
bear -- make debug

echo "Generating Ctags..."
ctags -R .

# Fetch target after building just to be safe
TARGET=$(make print-target)

echo ""
echo "Generated:"
echo "- $TARGET"
echo "- build/"
echo "- compile_commands.json"
echo "- tags"

echo "Done"
