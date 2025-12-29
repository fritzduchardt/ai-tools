#!/usr/bin/env bash

set -o pipefail

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"
source "$SCRIPT_DIR/lib/fabric_lib.sh"

FBRC_CONFIG="$HOME/.config/fabric"
FBRC_CONTEXT_FILE="$FBRC_CONFIG/contexts/general_context.md"
OUTPUT_FILTER=(grep -v "Creating new session:")
XCLIP_COPY=(xclip -r -sel clip)

check_pipe_input() {
  if [[ ! -t 0 ]]; then
    return 0
  fi
  return 1
}

function show_help() {
  echo "Usage: fbrc [OPTIONS]"
  echo
  echo "Options:"
  echo "  -s SESSION       Specify a session."
  echo "  -h               Show this help message."
  echo "  -c               Don't reset session."
  echo "  -q               Stream response, good for ai questions from the
  terminal."
}

fbrc() {
  local pattern prompt output stream chat fabric_cmd session

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -h)
        show_help
        exit 0
        ;;
      -p)
        pattern="$2"
        shift 2
        ;;
      -c)
        chat="true"
        shift 1
        ;;
      -q)
        stream="--stream"
        shift 1
        ;;
      *)
        break
        ;;
    esac
  done

  # make sure everything is generated
  "$SCRIPT_DIR"/gomplate.sh

  # Pattern configuration
  session="$(create_session)"
  prepare_context "$FBRC_CONTEXT_FILE"
  if [[ -n "$chat" ]]; then
    log::info "Starting a chat with $MODEL.."
    last_fabric fabric_cmd
    # overwrite pattern if it was provided explicitly
    if [[ -n "$pattern" ]]; then
      fabric_cmd="${fabric_cmd/--pattern */--pattern $pattern}"
    fi
  else
    if [[ -z "$pattern" ]]; then
    # shellcheck disable=SC2012
    pattern="$(ls "$FBRC_CONFIG/patterns" | fzf --ghost "Pick a pattern" --query=private_)"
    fi
  fi

  # Add args to prompt
  if [[ $# -gt 0 ]]; then
    prompt="$*\n"
  fi
  # shellcheck disable=SC2206
  if [[ -z "$fabric_cmd" ]]; then
    fabric_cmd="fabric --context "$(basename "$FBRC_CONTEXT_FILE")" $stream
     --session "$session" --pattern "$pattern" $EXTRA_AI_OPTS"
    # store for posterity
    echo "$fabric_cmd" >> ~/.bash_history
  fi

  # execute fabric
  local context="Current directory: $PWD. Specific User Request: $prompt"
  if check_pipe_input; then
    log::debug "Data was piped into script"
    lib::exec sed "1s#^#$context: #" | lib::exec $fabric_cmd \
      | "${OUTPUT_FILTER[@]}"
  else
    log::debug "No data was piped into script"
    lib::exec echo "$context" | lib::exec $fabric_cmd \
      | "${OUTPUT_FILTER[@]}"
  fi
}

fbrc "$@"
