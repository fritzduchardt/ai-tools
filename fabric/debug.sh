#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

usage() {
  echo """
Usage: $0 [options]

Options:
  -h, --help           Show this help message and exit
  -d, --dir DIR        Directory to search (default: /home/fritz/.config/fabric/sessions)

Examples:
  $0
  $0 -d /home/fritz/.config/fabric/sessions
"""
}

find_most_recent_file() {
  local dir="$1"
  local latest_file=""

  if [[ ! -d "$dir" ]]; then
    log::error "Directory not found: $dir"
    return 2
  fi

  latest_file="$(lib::exec ls -1t -- "$dir"/* 2>/dev/null | lib::exec head -n1 || true)"
  printf "%s" "$latest_file"
}

main() {
  local dir

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -d|--dir)
        shift
        dir="$1"
        shift
        ;;
      *)
        log::error "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  dir=${dir:-/home/fritz/.config/fabric/sessions}

  log::debug "Searching directory: $dir"
  local latest_file
  latest_file="$(find_most_recent_file "$dir")"

  if [[ -z "$latest_file" ]]; then
    log::warn "No files found in directory: $dir"
    exit 3
  fi

  log::info "Most recent file: $latest_file"
  if lib::exec jq -C '.' "$latest_file"; then
    log::info "Displayed file"
  else
    log::error "Failed to parse file with jq: $latest_file"
    exit 4
  fi
}

main "$@"
