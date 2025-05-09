#!/usr/bin/env bash

last_fabric() {
  local -n _fabric_cmd=$1
  local cmd_str elem
  cmd_str="$(grep -o -E "^fabric .*" ~/.bash_history | tac | head -n1)"
  for elem in $cmd_str; do
    _fabric_cmd+=("$elem")
  done
}

last_session() {
  local cmd_str session
  cmd_str="$(grep -o -E "^fabric .*" ~/.bash_history | tac | head -n1)"
  if [[ "$cmd_str" =~ --session[[:space:]]+([^[:space:]]+) ]]; then
    session=${BASH_REMATCH[1]}
    echo "$session"
  fi
}

last_result() {
  local session="$1" session_file
  session_file="$HOME/.config/fabric/sessions/$session.json"
  log::info "Session File: $session_file"
  if [[ -e "$session_file" ]]; then
    lib::exec jq -r 'map(select(.role=="assistant")) | last.content' <"$session_file"
  fi
}

create_session() {
  local session
  session="$(date +%Y%m%d%H%M%S)"
  echo "$session"
}

prepare_context() {
  local user_data_file="$1"
  local -r current_date="$(date +%Y-%m-%d\ %H:%M:%S)"
  local output="# CONTEXT\n"
  output+="- The current date is: $current_date\n"
  cat > "$user_data_file" <<< "$(echo -e "$output")"
}
