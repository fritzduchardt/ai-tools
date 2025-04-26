#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"
concat_for_fabric() {
  local pattern="${1:-.}"
  local file
  while IFS='' read -r file; do
      echo -e "
FILENAME: $file
"
      cat "$file"
      echo
  done < <(fd -d 1 -t file "$pattern")
}

concat_for_fabric_recursive() {
  local pattern="${1:-.}"
  local file
  while IFS='' read -r file; do
      echo -e "
FILENAME: $file
"
      cat "$file"
      echo
  done < <(fd -t file "$pattern")
}

find_for_fabric() {
  fd . "$@" --max-depth 1 --type f
}

find_for_fabric_recursive() {
  fd . "$@" --type f
}

internet_for_fabric() {
  local url="$1"
  curl -s "$url" | lynx -dump -stdin
}

find_for_obsidian() {
  local search_path="${1:-.}"
  local fnd="$2"
  local file
  if ! file="$(lib::exec find "$search_path" -type f -iname "*$fnd*.md")"; then
    log::error "No file found for: $fnd"
    return 2
  fi
  if [[ -z "$file" ]]; then
    log::error "No file found for: $fnd"
    return 2
  fi
  echo -e "
FILENAME: $file
"
  lib::exec cat "$file"
}

case "$1" in
  concat_for_fabric|concat_for_fabric_recursive|find_for_fabric|find_for_fabric_recursive|internet_for_fabric|find_for_obsidian)
    action=$1
    shift
    "$action" "$@"
    ;;
  *)
    echo "Usage: $0 {concat_for_fabric|concat_for_fabric_recursive|find_for_fabric|find_for_fabric_recursive|internet_for_fabric|find_for_obsidian} [args...]"
    exit 1
    ;;
esac
