#!/usr/bin/env bash

last_fabric() {
  grep -o -E "^$FBRC_BIN .*" ~/.bash_history | tac | head -n1
}

last_session() {
  local -r cmd="$(last_fabric)"
  echo "$cmd" | grep -o -E "\-\-session \w+" | sed -E "s/--session\s+//"
}

create_session() {
  local session
  session="$(date +%Y%m%d%H%M%S)"
  echo "$session"
}

update_userdata() {
  local user_data_file="$1"
  local current_date="$2"
  local track_line="$3"
  local track_date="${track_line%% *}"
  log::debug "Track date: $track_date"
  if [[ "$track_date" != "$(date +%Y)-"* ]]; then
    log::warn "Line has no date at beginning: $track_line"
  fi
  local pattern_file_content line overwrite
  log::debug "Track data for: $user_data_file and date: $current_date"
  while IFS= read -r line; do
    # updated line
    if [[ "$line" == "$track_date "* ]]; then
      overwrite=true
      pattern_file_content+="$track_line\n"
      log::info "User data updated"
      continue
    # new line
    elif [[ "$line" == "{{- end -}}" && -z "$overwrite" ]]; then
      pattern_file_content+="$track_line\n"
      pattern_file_content+="$line\n"
    # anything else
    else
      pattern_file_content+="$line\n"
    fi
  done <"$user_data_file"
  echo -e "$pattern_file_content" >"$user_data_file"
}
