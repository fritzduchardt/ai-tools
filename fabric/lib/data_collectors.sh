#!/usr/bin/env bash

concat_for_fabric() {
  local file
  for file in "${1:-.}"/*; do
    if [[ -f "$file" ]]; then
      echo -e "
FILENAME: $file
"
      cat "$file"
    fi
  done
}

concat_for_fabric_recursive() {
  local file
  for file in "${1:-.}"/*; do
    if [[ -d "$file" ]]; then
      concat_for_fabric_recursive "$file"
    else
      echo -e "
FILENAME: $file
"
      cat "$file"
      echo
    fi
  done
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
  if ! file="$(lib::exec find "$search_path" -type f -iname "*$fnd*")"; then
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
