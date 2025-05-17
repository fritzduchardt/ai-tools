#!/usr/bin/env bash
SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"
source "$SCRIPT_DIR/lib/fabric_lib.sh"
source "$SCRIPT_DIR/../functions.sh"

# Input format: Lines starting with "FILENAME:" indicate new output file
# All subsequent lines are written to that file until next FILENAME: marker
generate_from_filelist() {
  local no_backup="$1"
  local line file_name
  while IFS= read -r line; do
    if [[ $line == FILENAME:* ]]; then
      file_name="${line#*FILENAME: }"
      log::info "Writing $file_name"
      if [[ -e $file_name ]]; then
        if [[ -z "$no_backup" ]]; then
          lib::exec cp "$file_name" "$file_name".backup
        fi
        lib::exec truncate -s 0 "$file_name"
      else
        lib::exec mkdir -p "$(dirname "$file_name")"
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
  local -r file="$(ai_obsidian_path "$@")"
  if [[ -e $file ]]; then
    log::info "$file already exists"
    exit 2
  fi
  lib::exec mkdir -p "$(dirname "$file")"
  lib::exec touch "$file"
  log::info "$file created"
}

store_result() {
  local file_path session
  session="$(last_session)"
  if [[ -z "$session" ]]; then
    log::error "No session found"
    exit 1
  fi
  if ! file_path="$(last_result "$session" | ai_obsidian_path "")"; then
    log::error "Could find path"
    exit 1
  fi
  if [[ -z "$file_path" ]]; then
    log::error "Could not find meaningful file path"
    exit 2
  fi
  log::info "Storing last result away in $file_path"
  lib::exec mkdir -p "$(dirname "$file_path")"
  if ! last_result "$session" > "$file_path"; then
    log::error "Could not recall output"
    exit 1
  fi
}

journaling() {
  local topic="$1"
  shift 1
  log::info "Adding to journal.."
  if ! cfo "$topic" | ai_obsidian "$@"; then
    log::error "Failed to call AI to author Obsidian file"
    exit 1
  fi
  log::info "Giving feedback.."
  if ! cfo "$topic" | ai -p "private_$topic"; then
    log::error "Failed to call AI to evaluate Obsidian file"
    exit 1
  fi
}

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <action> [args]"
  exit 1
fi

case "$1" in
  store_result|create_file|generate_from_filelist|journaling)
    action=$1
    shift
    "$action" "$@"
    ;;
  *)
    echo "Usage: $0 {store_result|create_file|generate_from_filelist} [args...]"
    exit 1
    ;;
esac
