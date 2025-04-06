#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

FBRC_BIN="$SCRIPT_DIR/fabric.sh"

# convert stdin to prompt
function fbrc_stdin() {
  local line prompt
  while IFS= read -r line; do
    prompt="$prompt$line\n"
  done
  lib::exec "$FBRC_BIN" "$@" "$prompt"
}

fbrc_stdin "$@"
