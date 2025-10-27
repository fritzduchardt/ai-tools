#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

usage() {
  echo """Usage: $0 [options]

Options:
  -d, --dir DIR         Directory to import (default: current directory)
  -b, --base BASE       Base path to strip from file paths (default: "")
  -e, --endpoint URL    Weaviate endpoint URL (default: http://localhost:8080)
  -c, --class NAME      Weaviate class name to import into (default: ObsidianFile)
  -h, --help            Show this help

Examples:
  $0 --dir ./docs --base ./docs --endpoint http://weaviate.local:8080 --class Document
  $0 -d /data/texts -b /data -e http://127.0.0.1:8080 -c MyTextClass
"""
}

weaviate::import_file() {
  local endpoint="$1"
  local class="$2"
  local base="$3"
  local file="$4"
  local base_abs
  local file_abs
  local base_path
  local rel
  local payload
  local rc

  log::info "Preparing import for file: $file"

  base_abs="$(lib::exec realpath -- "$base")"
  file_abs="$(lib::exec realpath -- "$file")"

  base_path="${base_abs%/}"
  if [[ -n "$base_path" ]] && [[ "$file_abs" == "$base_path"* ]]; then
    rel="${file_abs#$base_path/}"
  else
    rel="$file"
  fi

  payload="$(lib::exec jq -Rs --arg class "$class" --arg path "$rel" '{class: $class, properties: {path: $path, content: .}}' <"$file_abs")"
  log::debug "Payload for $file_abs: $payload"

  if ! lib::exec curl -sS -X POST -H "Content-Type: application/json" -d "$payload" "$endpoint/v1/objects"; then
    rc=$?
    log::error "Failed to POST object for $file_abs (exit $rc)"
    return 1
  fi
}

weaviate::import_dir() {
  local dir="$1"
  local endpoint="$2"
  local class="$3"
  local base="$4"
  local files

  if [[ ! -d "$dir" ]]; then
    log::error "Directory not found: $dir"
    return 1
  fi

  mapfile -t files < <(lib::exec fd -E "*trash*" -t file \
    "(journal|protocol)\.md" "$dir")

  for file in "${files[@]}"; do
    weaviate::import_file "$endpoint" "$class" "$base" "$file"
  done
}

main() {
  local dir
  local base
  local endpoint
  local class

  dir="${DIR:-.}"
  endpoint="${ENDPOINT:-http://localhost:8082}"
  class="${CLASS:-ObsidianFile}"
  base="${BASE:-}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--dir)
        dir="$2"
        shift 2
        ;;
      -b|--base)
        base="$2"
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

  if [[ -z "$base" ]]; then
    base="$dir"
  fi

  weaviate::import_dir "$dir" "$endpoint" "$class" "$base"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
