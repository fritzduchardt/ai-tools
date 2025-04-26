#!/usr/bin/env bash

last_fabric() {
  local -n _fabric_cmd=$1
  local cmd_str elem
  cmd_str="$(grep -o -E "^fabric .*" ~/.bash_history | tac | head -n1)"
  for elem in $cmd_str; do
    _fabric_cmd+=("$elem")
  done
}

create_session() {
  local session
  session="$(date +%Y%m%d%H%M%S)"
  echo "$session"
}

prepare_context() {
  local user_data_file="$1"
  local -r current_date="$(date +%Y-%m-%d)"
  local output="# CONTEXT\n"
  output+="- The current date is: $current_date\n"
  cat > "$user_data_file" <<< "$(echo -e "$output")"
}
