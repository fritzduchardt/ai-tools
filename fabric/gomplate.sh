#!/bin/bash

SCRIPT_DIR="$(dirname -- "$0")"

OUTPUT_DIR="$HOME/.config/fabric/patterns"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

find "$SCRIPT_DIR/patterns" -type f -name "*.md" | while read -r file; do
  output="$OUTPUT_DIR/${file#fabric/patterns/}"
  gomplate -f "$file" -t "$SCRIPT_DIR/patterns/templates" -o "$output"
done
