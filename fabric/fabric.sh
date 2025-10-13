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
  echo "  -i INPUTFILE     Specify an input file."
  echo "  -o               Overwrite the input file with output."
  echo "  -s SESSION       Specify a session."
  echo "  -x               Toggle copy to clipboard (default is enabled)."
  echo "  -h               Show this help message."
  echo "  -c               Don't reset session."
}

fbrc() {
  local pattern prompt inputfile overwrite output copy_to_clipboard chat fabric_cmd session

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
    local -a fabric_cmd=(fabric --context "$(basename "$FBRC_CONTEXT_FILE")" --stream --session "$session" --pattern "$pattern" $EXTRA_AI_OPTS)
    # store for posterity
    echo "${fabric_cmd[*]}" >> ~/.bash_history
  fi

  # execute fabric
  local -a cmd_prefix
  # if the input file was provided, add it to prompt
  if [[ -n "$inputfile" ]]; then
    cmd_prefix=(sed "1i $prompt:" "$inputfile")
  elif check_pipe_input; then
    log::debug "Data was piped into script"
    cmd_prefix=(sed "1s#^#$prompt: #")
  else
    log::debug "No data was piped into script"
    cmd_prefix=(echo "$prompt")
  fi

  log::info "Calling the AI ($MODEL).. (${fabric_cmd[*]})"
  if ! output="$(lib::exec "${cmd_prefix[@]}" | lib::exec "${fabric_cmd[@]}" | "${OUTPUT_FILTER[@]}")"; then
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
