#!/usr/bin/env bash
SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"
source "$SCRIPT_DIR/lib/fabric_lib.sh"
source "$SCRIPT_DIR/../functions.sh"

# Input format: Lines starting with "FILENAME:" indicate new output file
# All subsequent lines are written to that file until next FILENAME: marker
generate_from_filelist() {
  local line file_name first_line_written
  while IFS= read -r line; do
    if [[ $line == FILENAME:* ]]; then
      if [[ $first_line_written -eq 1 ]]; then
        # stip empty line from last file written
        file::strip_trailing_empty_lines "$file_name"
      fi
      file_name="${line#*FILENAME: }"
      log::info "Writing $file_name"
      if [[ -e $file_name ]]; then
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

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <action> [args]"
  exit 1
fi

case "$1" in
  generate_from_filelist)
    action=$1
    shift
    "$action" "$@"
    ;;
  *)
    echo "Usage: $0 {generate_from_filelist} [args...]"
    exit 1
    ;;
esac
