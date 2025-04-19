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
  local dir="${1:-.}"
  find "$dir" -type f -not -path '*/.*' | grep -v ".*.txt$" | grep -v ".*.md"
}

internet_for_fabric() {
  local url="$1"
  curl -s "$url" | lynx -dump -stdin
}

find_for_obsidian() {
  local fnd="$1"
  local file
  if ! file="$(fd -t file "$fnd" | rg -v conflict)"; then
    log::error "No file found for $fnd"
    exit 2
  fi

  echo -e "
FILENAME: $file
"
  cat "$file"
}
