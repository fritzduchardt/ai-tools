{{- define "bash" -}}
- If it is bash:
  _ Always add usage function with a couple of run examples which can be called with -h.
    - Reference function name within usage function with $0.
    - Use echo triple-quote notation to write the usage instructions.
  - Use $variable instead of ${variable} where possible.
  - Quote all variables, parameters and command substitutions
  - Local variables:
    - Ensure variables within functions are local.
    - Write local variables in lowercase.
    - Declare and assign variable in one line, but each variable on a separate line, unless variables not require initialization, in which case they can be declared on the same line.
  - Ensure shebang is first line in script
  - If using variables at global scope, capitalize them and declare them at beginning of script
  - Use parameter expansion to set variable default values
  - Use if [[]]; then rather than [[]] &&
  - Use while; do rather than while; then
  - For parsing of input parameters, use while [[ $# -gt 0 ]] notation in combination with shift and a case statement.
  - Check exit codes directly where possible
  - Dont add dry run options
  - Leave multi line strings in place
  - Leave if statements in place. Make the shorter if needed but never replace them with direct output.
  - Use functions where possible including "main" function to bootstrap script.
  - Dont check for presence of binaries. Assume they are installed.
  - For logging use log::info, log::debug, log::error and log::warn functions. Start log messages with capital letter.
  - Prefix all linux commands executed by the script with lib::exec. No need to use bash -c in that case.
  - In the spirit of Clean Code, try to show function purpose in naming, dont add comments at function level.
  - On code doing networking, add comments explaining in detail what it does.
  - when writing negative iptables rules, use the notation: "!" -i/-o "name-of-interface"
  - when added iptables rules, always just add them and disregard the return code.
  - Dont add prerequisites function
  - Start all scripts with the following block. If block was missing use ../lib as path-to-lib. If block is already in place, leave path as is.
  #!/usr/bin/bash

  set -eo pipefail

  SCRIPT_DIR="$(dirname -- "$0")"
  source "$SCRIPT_DIR/<path-to-lib>/log.sh"
  source "$SCRIPT_DIR/<path-to-lib>/utils.sh"
{{- end -}}
