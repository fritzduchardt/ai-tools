#!/usr/bin/env bash

# Input format: Lines starting with "FILENAME: " indicate new output file
# All subsequent lines are written to that file until next FILENAME: marker
function generate_from_filelist() {
  local line file_name
  while IFS= read -r line; do
    if [[ "$line" == "FILENAME:"* ]]; then
      file_name="${line#*FILENAME: }"
      log::info "Writing $file_name"
      if ! lib::exec truncate -s 0 "$file_name"; then
        touch "$file_name"
      fi
    else
      if [[ -n "$file_name" ]]; then
        echo "$line" >> "$file_name"
      else
        log::info "$line"
      fi
    fi
  done

  log::info "Done!"
}
