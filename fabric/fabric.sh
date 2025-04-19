#!/usr/bin/env bash

set -o pipefail

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"
source "$SCRIPT_DIR/lib/fabric_lib.sh"

FBRC_CONFIG="$HOME/.config/fabric"
FBRC_BIN="fabric"
FBRC_CONTEXT_FILE="$FBRC_CONFIG/contexts/general_context.md"
OUTPUT_FILTER=(grep -v "Creating new session:")
XCLIP_COPY=(xclip -r -sel clip)


function show_help() {
  echo "Usage: fbrc [OPTIONS]"
  echo
  echo "Options:"
  echo "  -i INPUTFILE     Specify an input file."
  echo "  -o               Overwrite the input file with output."
  echo "  -s SESSION       Specify a session."
  echo "  -x               Toggle copy to clipboard (default is enabled)."
  echo "  -h               Show this help message."
  echo "  -c               Don't reset session."
}

fbrc() {
  local pattern session prompt inputfile overwrite output copy_to_clipboard chat fabric_cmd keep_session

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -h)
        show_help
        exit 0
        ;;
      -i)
        inputfile="$2"
        shift 2
        ;;
      -o)
        overwrite="true"
        shift
        ;;
      -s)
        session="$2"
        shift 2
        ;;
      -x)
        copy_to_clipboard=true
        shift
        ;;
      -p)
        pattern="$2"
        shift 2
        ;;
      -c)
        chat="true"
        shift 1
        ;;
      -k)
        keep_session="true"
        shift 1
        ;;
      *)
        break
        ;;
    esac
  done

  # make sure everything is generated
  "$SCRIPT_DIR"/gomplate.sh

  # validate input options
  if [[ -n "$inputfile" && ! -f "$inputfile" ]]; then
    log::error "Input file does not exist: $inputfile"
    exit 2
  fi
  if [[ "$overwrite" == "true" && -z "$inputfile" ]]; then
    log::error "Input file is required if overwrite option is set."
    exit 2
  fi

  # Pattern and session configuration
  if [[ -n "$chat" ]]; then
    log::info "Starting a chat.."
    fabric_cmd="$(last_fabric)"
    # overwrite pattern if it was provided explicitely
    if [[ -n "$pattern" ]]; then
      fabric_cmd="${fabric_cmd/--pattern */--pattern $pattern}"
    fi
  else
    if [[ -z "$pattern" ]]; then
    # shellcheck disable=SC2012
    pattern="$(ls "$FBRC_CONFIG/patterns" | grep -v "_track" | fzf --ghost "Pick a pattern" --query=private_)"
    fi
    # If session is empty, pick one
    if [[ -z "$session" ]]; then
      if session="$(fabric --listsessions | fzf --ghost "Pick a session" --print-query -e --bind "f2:execute($FBRC_BIN --wipesession {})")"; then
        # pick session and clear it to start with a clean slate
        session="$(tail -n1 <<<"$session")"
        if [[ -z "$keep_session" ]]; then
          lib::exec "$FBRC_BIN" --wipesession "$session"
        fi
      fi
    # If session is auto, generate one
    elif [[ "$session" == "auto" ]]; then
      session="$(create_session)"
      log::debug "Session: $session"
      lib::exec trap "$FBRC_BIN --wipesession=$session" EXIT
    fi
  fi
  prepare_context "$FBRC_CONTEXT_FILE" "$session"

  # Add args to prompt
  if [[ $# -gt 0 ]]; then
    prompt="$*\n"
  # Allow user to input prompt
  else
    local prompt_tmp
    read -r -p "Prompt: " prompt_tmp
    prompt="$prompt_tmp\n"
  fi

  # shellcheck disable=SC2206
  if [[ -z "$fabric_cmd" ]]; then

    local -a fabric_cmd=("$FBRC_BIN" --context "$(basename "$FBRC_CONTEXT_FILE")" --stream --session "$session" --pattern "$pattern$track" $EXTRA_AI_OPTS)
    # store for posterity
    echo "${fabric_cmd[*]}" >> ~/.bash_history
  fi

  # if input file was provided, add it to prompt
  if [[ -n "$inputfile" ]]; then
    prompt="$prompt: $(cat "$inputfile")"
  fi

  # execute fabric
  log::debug "Prompt: $prompt"
  log::info "Calling the AI.."
  # shellcheck disable=SC2068
  if ! output="$(lib::exec ${fabric_cmd[@]} <<<"$prompt" | "${OUTPUT_FILTER[@]}")"; then
    log::error "Failed to call fabric"
    log::error "$output"
    exit 1
  fi

  # output the output
  if [[ "$overwrite" == "true" ]]; then
    echo "$output" > "$inputfile"
  else
    echo "$output"
  fi
  if [[ "$copy_to_clipboard" == "true" ]]; then
    lib::exec "${XCLIP_COPY[@]}" <<<"$output"; echo
  fi
}

fbrc "$@"
