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
  local line file_name first_line_written
  while IFS= read -r line; do
    if [[ $line == FILENAME:* ]]; then
      file_name="${line#*FILENAME: }"
      # strip slashes
      file_name="${file_name%% *}"
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
      first_line_written=0
    else
      if [[ -n $file_name ]]; then
        # skip empty first line
        if [[ $first_line_written -eq 0 ]]; then
          if [[ -z $line ]]; then
            continue
          fi
          first_line_written=1
        fi
        echo "$line" >> "$file_name"
      else
        log::info "$line"
      fi
    fi
  done

  log::info "Done!"
}

store_result() {
  local file_path session result
  # find session
  session="$(last_session)"
  if [[ -z "$session" ]]; then
    log::error "No session found"
    exit 1
  fi
  log::info "Found session: $session"

  # extract last result
  result="$(last_result "$session")"
  if [[ -z "$result" ]]; then
    log::error "No result found"
    exit 1
  fi
  log::info "Found last result"

  # find file path
  local -r result_file="$(mktemp)"
  echo "$result" > "$result_file"
  local -r file_path="$(grep -o -P "(?<=^FILENAME: )\S+(?=\s*$)" "$result_file")"
  if [[ -z "$file_path" ]]; then
    log::error "Result does not contain FILENAME. No idea where to store it."
    exit 1
  fi
  log::info "Found file path: $file_path"

  # write results
  lib::exec mkdir -p "$(dirname "$file_path")"
  if ! sed "/FILENAME:/d" "$result_file" > "$file_path"; then
    log::error "Could write result"
    exit 1
  fi
  log::info "Stored file successfully"
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
