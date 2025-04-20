#!/usr/bin/env bash

FD_BIN="/usr/local/bin/fd"

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
  "$FD_BIN" . "$@" --max-depth 1 --type f
}

find_for_fabric_recursive() {
  "$FD_BIN" . "$@" --type f
}

internet_for_fabric() {
  local url="$1"
  curl -s "$url" | lynx -dump -stdin
}

find_for_obsidian() {
  local fnd="$1"
  local file
  if ! file="$("$FD_BIN" -t file "$fnd" -1 | rg -v conflict)"; then
    log::info "No file found for $fnd."
    return 2
  fi

  echo -e "
FILENAME: $file
"
  cat "$file"
}
