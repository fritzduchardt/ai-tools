#!/usr/bin/env bash

function concat_for_fabric() {
  local file
  for file in "${1:-.}"/*; do
    if [[ -f "$file" ]]; then
      echo -e "\n=== $file ===\n"
      cat "$file"
    fi
  done
}
function concat_for_fabric_recursive() {
  local file
  for file in "${1:-.}"/*; do
    if [[ -d "$file" ]]; then
      concat_for_fabric_recursive "$file"
    else
      echo -e "\n=== $file ===\n"
      cat "$file"
      echo
      fi
  done
}
function find_for_fabric() {
  local dir="${1:-.}"
  find "$dir" -type f -not -path '*/.*' | grep -v ".*.txt$" | grep -v ".*.md"
}
function internet_for_fabric() {
  local url="$1"
  curl -s "$url" | lynx -dump -stdin
}
