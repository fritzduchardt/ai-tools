#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(dirname -- "$0")"
source "$SCRIPT_DIR/../lib/log.sh"
source "$SCRIPT_DIR/../lib/utils.sh"

usage() {
  lib::exec echo """Usage: $0 [options]

Options:
  -t, --term       Search term to query Weaviate (required)
  -e, --endpoint   Weaviate endpoint URL (default: http://localhost:8080)
  -c, --class      Weaviate class to search (default: Document)
  -l, --limit      Number of results to return (default: 5)
  -s, --certainty  Certainty threshold for nearText (default: 0.7)
  -h, --help       Show this help message

Examples:
  $0 -t 'climate change'
  $0 --term 'error handling' --endpoint 'http://weaviate.local:8080' --class Article --limit 10
"""
}

weaviate::build_graphql() {
  local term="$1"
  local class="$2"
  local limit="$3"
  local certainty="$4"
  local gql
  gql=
  echo "$gql"
}

weaviate::search() {
  local term="$1"
  local endpoint="$2"
  local class="$3"
  local limit="$4"
  local certainty="$5"

  local payload='{"query":"{ Get { '$class'(hybrid: { query: \"'$term'\", alpha: '$certainty'}, limit: '$limit' )  { path content } } }"}'

  # Perform HTTP POST to Weaviate GraphQL endpoint.
  # This sends the GraphQL query in the request body to endpoint/v1/graphql and captures the response.
  # The network request is executed via curl. If curl fails, we log an error and return non-zero.
  local response
  if ! response="$(lib::exec curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$endpoint/v1/graphql")"; then
    log::error "Failed to query Weaviate at $endpoint"
    return 1
  fi
  log::debug "Response: $response"
  # Empty result
  if [[ "$response" == '{"data":{"Get":{"ObsidianFile":[]}}}' ]]; then
    log::info "Found nothing"
    return 0
  fi
  # Parse the response with jq and print relevant fields.
  if ! lib::exec jq -r ".data.Get.$class[].path" \
    <<<"$response"; then
    log::warn "No results or unexpected response structure from Weaviate"
    return 0
  fi
  if ! lib::exec jq -r ".data.Get.$class[].content" \
    <<<"$response"; then
    log::warn "No results or unexpected response structure from Weaviate"
    return 0
  fi
}

main() {
  local term=""
  local endpoint=""
  local class=""
  local limit=""
  local certainty=""

  endpoint="${endpoint:-http://localhost:8082}"
  class="${class:-ObsidianFile}"
  limit="${limit:-1}"
  certainty="${certainty:-0.5}"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -t|--term)
        term="$2"
        shift 2
        ;;
      -e|--endpoint)
        endpoint="$2"
        shift 2
        ;;
      -c|--class)
        class="$2"
        shift 2
        ;;
      -l|--limit)
        limit="$2"
        shift 2
        ;;
      -s|--certainty)
        certainty="$2"
        shift 2
        ;;
      *)
        log::warn "Unknown argument: $1"
        usage
        exit 2
        ;;
    esac
  done

  if [[ -z "$term" ]]; then
    log::error "Missing required --term argument"
    usage
    exit 2
  fi

  log::info "Searching Weaviate at $endpoint for term: $term (class: $class, limit: $limit, certainty: $certainty)"
  weaviate::search "$term" "$endpoint" "$class" "$limit" "$certainty"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
