#!/bin/bash

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"
PRIVATE_PATTERN_DIR="${PRIVATE_PATTERN_DIR:-$HOME/Sync/FritzSync/patterns}"

OUTPUT_DIR="$HOME/.config/fabric"
rm -rf "$OUTPUT_DIR/patterns"
mkdir -p "$OUTPUT_DIR/patterns"

# generate devops patterns
find "$SCRIPT_DIR/patterns" -type f -name "*.md" -printf "%P\n" | while read -r file; do
  output="$OUTPUT_DIR/patterns/$file"
  lib::exec mkdir -p "$(dirname "$output")"
  lib::exec gomplate -f "$SCRIPT_DIR/patterns/$file" -t "$SCRIPT_DIR/patterns/templates" -o "$output"
done

# generate private patterns
find "$PRIVATE_PATTERN_DIR" -type f -name "*.md" -printf "%P\n" | while read -r file; do
  output="$OUTPUT_DIR/patterns/$file"
  lib::exec mkdir -p "$(dirname "$output")"
  lib::exec gomplate -f "$PRIVATE_PATTERN_DIR/$file" -t "$PRIVATE_PATTERN_DIR/templates" -o "$output"
done
