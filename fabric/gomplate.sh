#!/bin/bash

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

OUTPUT_DIR="$HOME/.config/fabric"
rm -rf "$OUTPUT_DIR/patterns"
mkdir -p "$OUTPUT_DIR/patterns"
mkdir -p "$OUTPUT_DIR/user-data"

# copy user data
find "$SCRIPT_DIR/patterns/templates/user-data" -type f -name "*.t" -printf "%P\n" | while read -r file; do
  if [[ ! -f "$OUTPUT_DIR/user-data/$file" ]]; then
    lib::exec cp "$SCRIPT_DIR/patterns/templates/user-data/$file" "$OUTPUT_DIR/user-data/"
  fi
done

# generate patterns
find "$SCRIPT_DIR/patterns" -type f -name "*.md" -printf "%P\n" | while read -r file; do
  output="$OUTPUT_DIR/patterns/$file"
  lib::exec mkdir -p "$(dirname "$output")"
  lib::exec gomplate -f "$SCRIPT_DIR/patterns/$file" -t "$OUTPUT_DIR/user-data/" -t "$SCRIPT_DIR/patterns/templates" -o "$output"
done
