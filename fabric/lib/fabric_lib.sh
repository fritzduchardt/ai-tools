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
