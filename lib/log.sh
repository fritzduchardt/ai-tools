#!/usr/bin/env bash

# MINOR: Added readonly for constants
declare -A LOG_LEVELS
readonly LOG_LEVELS=([trace]=0 [debug]=1 [info]=2 [warn]=3 [error]=4 [fatal]=5)
LOG_LEVEL="${LOG_LEVEL:-info}"
LOG_CONTEXT=""

# MINOR: Simplified lowercase conversion
log::_lowercase() {
  local str="$1"
  tr '[:upper:]' '[:lower:]' <<< "$str"
}

log::_islevel() {
    local level="$1"
    local level_lc="$(log::_lowercase "$level")"
    local global_lc="$(log::_lowercase "$LOG_LEVEL")"
    local global_level_int=${LOG_LEVELS[$global_lc]}
    local current_level_int=${LOG_LEVELS[$level_lc]}
    ((global_level_int <= current_level_int))
}

log::_logincolor() {
    local paint="$1"
    local level="$2"
    shift 2

    if log::_islevel "$level"; then
        if [[ -n "$LOG_CONTEXT" ]]; then
            echo -e "\033[0;${paint}m$level\033[0m \033[1m[$LOG_CONTEXT]\033[0m $1" >&2
        else
            echo -e "\033[0;${paint}m$level\033[0m $1" >&2
        fi
    fi
}

log::trace() {
    log::_logincolor 35 TRACE "$@"
}

log::debug() {
    log::_logincolor 34 DEBUG "$@"
}

log::info() {
    log::_logincolor 32 INFO "$@"
}

log::warn() {
    log::_logincolor 33 WARN "$@"
}

log::error() {
    log::_logincolor 31 ERROR "$@"
}

log::fatal() {
    log::_logincolor 35 FATAL "$@"
}
