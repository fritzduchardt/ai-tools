#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

usage() {
  echo """Usage: $0 [options]

Options:
  -d, --dir DIR         Directory to import (default: current directory)
  -e, --endpoint URL    Weaviate endpoint URL (default: http://localhost:8080)
  -c, --class NAME      Weaviate class name to import into (default: Document)
  -h, --help            Show this help

Examples:
  $0 --dir ./docs --endpoint http://weaviate.local:8080 --class Document
  $0 -d /data/texts -e http://127.0.0.1:8080 -c MyTextClass
"""
}

weaviate::import_file() {
  local endpoint="$1"
  local class="$2"
  local file="$3"
  local payload
  log::info "Preparing import for file: $file"
  payload="$(lib::exec jq -Rs --arg class "$class" --arg path "$file" '{class: $class, properties: {path: $path, content: .}}' <"$file")"
  log::debug "Payload for $file: $payload"
  lib::exec curl -sS -X POST -H "Content-Type: application/json" -d "$payload" "$endpoint/v1/objects"
}

weaviate::import_dir() {
  local dir="$1"
  local endpoint="$2"
  local class="$3"
  if [[ ! -d "$dir" ]]; then
    log::error "Directory not found: $dir"
    return 1
  fi
  lib::exec find "$dir" -name "*.md" -type f | grep -v ".trash" \
    | while IFS= read -r file; do
    weaviate::import_file "$endpoint" "$class" "$file"
  done
}

main() {
  local dir
  local endpoint
  local class
  dir="${DIR:-.}"
  endpoint="${ENDPOINT:-http://localhost:8082}"
  class="${CLASS:-ObsidianFile}"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dir)
        dir="$2"
        shift 2
        ;;
      -e|--endpoint)
        endpoint="$2"
        shift 2
        ;;
      -c|--class)
        class="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log::error "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done
  weaviate::import_dir "$dir" "$endpoint" "$class"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
