#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"
source "$SCRIPT_DIR/lib/fabric_lib.sh"

FBRC_BIN="$SCRIPT_DIR/fabric.sh"

# fbrcs
function fbrc_improve() {
  local file line
  local -a args
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -i)
        file="$2"
        shift 2
        ;;
      *)
        args+=("$1")
        shift 1
        ;;
    esac
  done

  if [[ -z "$file" ]]; then
    local -a pids
    while IFS= read -r line; do
      log::info "Improving $line"
      {
        local -r session="$(create_session)"
        log::debug "Session: $session"
        lib::exec "$FBRC_BIN" -p devops_improve -i "$line" -o -s "$session" "${args[@]}"
        lib::exec fabric --wipesession="$session"
      } &
      pids+=($!)
    done
    log::info "Waiting for fabric to finish"
    wait "${pids[@]}"
    log::info "Done!"
  else
      log::info "Improving $file"
      lib::exec "$FBRC_BIN" -p devops_improve -i "$file" -o "${args[@]}"
  fi
}

fbrc_improve "$@"
