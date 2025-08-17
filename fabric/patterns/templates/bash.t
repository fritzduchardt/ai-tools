{{- define "bash" -}}
- If it is bash:
  - Use $variable instead of ${variable} where possible.
  - Quote all variables, parameters and command substitutions
  - Ensure variables within functions are local
  - Ensure shebang is first line in script
  - Use parameter expansion to set variable default values
  - Use if [[]]; then rather than [[]] &&
  - Use while; do rather than while; then
  - Check exit codes directly where possible
  - Dont add dry run options
  - Leave multi line strings in place
  - Leave if statements in place. Make the shorter if needed but never replace them with direct output.
  - Use functions where possible including "main" function to bootstrap script.
  - Dont check for presence of binaries. Assume they are installed.
  - For logging use log::info, log::debug, log::error and log::warning functions
  - Use comments in the spirit of Clean Code: only comment if not already obvious due to method or variable names.
  - Start all scripts with:
  #!/usr/bin/env bash

  set -eo pipefail

  SCRIPT_DIR="$(dirname -- "$0")"
  source "$SCRIPT_DIR/../lib/log.sh"
  source "$SCRIPT_DIR/../lib/utils.sh"
{{- end -}}
