#!/usr/bin/env bash

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

# Input format: Lines starting with "FILENAME:" indicate new output file
# All subsequent lines are written to that file until next FILENAME: marker
generate_from_filelist() {
  local line file_name
  while IFS= read -r line; do
    if [[ $line == FILENAME:* ]]; then
      file_name="${line#*FILENAME: }"
      log::info "Writing $file_name"
      if [[ -e $file_name ]]; then
        lib::exec cp "$file_name" "$file_name".backup
        lib::exec truncate -s 0 "$file_name"
      else
        lib::exec touch "$file_name"
      fi
    else
      if [[ -n $file_name ]]; then
        echo "$line" >> "$file_name"
      else
        log::info "$line"
      fi
    fi
  done

  log::info "Done!"
}

create_file() {
  local -r file="$(aiop "$@")"
  if [[ -e $file ]]; then
    log::info "$file already exists"
    exit 2
  fi
  lib::exec mkdir -p "$(dirname "$file")"
  lib::exec touch "$file"
  log::info "$file created"
}

store_result() {
  local last_result file_name file_path
  log::info "Getting last AI result"
  if ! last_result="$(aic print last result again)"; then
    log::error "Could not recall output"
    exit 1
  fi
  log::info "Figuring out file name..."
  if ! file_name="$(echo "$last_result" | ai-filename)"; then
    exit 1
  fi
  log::info "Figuring out path.."
  if ! file_path="$(fffr "$OBSIDIAN_PATH" | aiop figure out path for "$file_name")"; then
    log::error "Could find path"
    exit 1
  fi
  if [[ ! $file_path =~ ^(/|/([^/]+)(/[^/]+)*/?)$ ]]; then
    log::error "No file path found: $file_path"
    exit 2
  fi
  log::info "Storing last result away in $file_path"
  lib::exec mkdir -p "$(dirname "$file_path")"
  cat > "$file_path" <<<"$last_result"
}

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <action> [args]"
  exit 1
fi

case "$1" in
  store_result|create_file|generate_from_filelist)
    action=$1
    shift
    "$action" "$@"
    ;;
  *)
    echo "Usage: $0 {store_result|create_file|generate_from_filelist} [args...]"
    exit 1
    ;;
esac
