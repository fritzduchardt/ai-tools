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

prepare_context() {
  local user_data_file="$1"
  local session="$2"
  local -r current_date="$(date +%Y-%m-%d)"
  local output="# CONTEXT\n"
  output+="- The current date is: $current_date\n"

  if [[ "$session" == "auto" ]]; then
    output+="- The topic is: $session\n"
  fi

  cat > "$user_data_file" <<< "$(echo -e "$output")"
}
