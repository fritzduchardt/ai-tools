{{- define "improve" -}}
- If it is bash:
	- use $variable instead of ${variable} where possible. Always quote variables
	- use if [[]]; then rather than [[]] &&
  - Don't add dry run options
  - Leave multi line strings in place
{{- end -}}
