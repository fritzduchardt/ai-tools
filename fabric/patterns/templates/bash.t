{{- define "bash" -}}
- If it is bash:
  - Use $variable instead of ${variable} where possible.
  - Always quote variables including parameters, e.g. $1, as well as inline commands, e.g. $(echo hi)
  - Ensure variables within functions are local
  - Ensure shebang is first line in script
  - Use parameter substitution to set variable default values
  - Use if [[]]; then rather than [[]] &&
  - Use while; do rather than while; then
  - Don't add dry run options
  - Leave multi line strings in place
  - Leave if statements in place. Make the shorter if needed but never replace them with direct output.
{{- end -}}
