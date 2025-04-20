#!/usr/bin/env bash

KUBECTL_BIN="${KUBECTL_BIN:-kubectl}"

# Execute any binary
lib::exec() {
  if [[ -z "$DRY_RUN" ]] || [[ "$DRY_RUN" != "true" ]]; then
    log::trace "$*"
    if ! "$@"; then
      log::error "Failed to execute: $*"
      return 1
    fi
  else
    log::info "DRY-RUN: $*"
  fi
}

fzf::select_from_config() {
  local config_file="$1"
  local header="$2"
  local query="$3"
  local entry
  if ! entry="$(lib::exec fzf --print-query --header "$header" --query "$query" <"$config_file")"; then
    log::debug "No entry found in: $config_file. Going with user input: $entry"
  fi
  lib::exec echo "$entry" | tr -d '\n'
}

k8s::select_namespace() {
  local -r current_namespace="$(k8s::current_namespace)"
  log::debug "Current namespace: $current_namespace"
  lib::exec "$KUBECTL_BIN" get ns -oname | sed "s#namespace/##" | fzf --header "Select namespace" --query "$current_namespace"
}

k8s::current_namespace() {
  if ! lib::exec "$KUBECTL_BIN" cluster-info &>/dev/null; then
    echo "none"
    return 1
  fi
  lib::exec "$KUBECTL_BIN" config view --minify --output 'jsonpath={..namespace}'
}

k8s::current_context() {
  if ! lib::exec "$KUBECTL_BIN" cluster-info &>/dev/null; then
    echo "none"
    return 1
  fi
  local -r context_yaml="$(lib::exec "$KUBECTL_BIN" config view)"
  local -r current_context="$(lib::exec yq '.current-context' <<<"$context_yaml")"
  local -r context_name="$(lib::exec yq '.contexts.[] | select(.name == "'"$current_context"'") | .context.cluster' <<<"$context_yaml")"
  echo "${context_name%:*}"
}

k8s::resource_exists() {
  local resource="$1"
  local name="$2"
  local namespace="$3"
  lib::exec "$KUBECTL_BIN" get "$resource" "$name" -n "$namespace" 2>/dev/null
  return $?
}

k8s::registry_url_from_secret() {
  local secret_name="$1"
  local ns="$2"
  lib::exec "$KUBECTL_BIN" get secret "$secret_name" -n "$ns" -o go-template='{{ index .data ".dockerconfigjson" | base64decode }}' | jq -re '.auths | keys[0]'
}
