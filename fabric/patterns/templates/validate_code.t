{{- define "validate_code" -}}
- Check code changes for possible errors.
- Issue a warning if:
  - Code contains possible errors
  - Code includes passwords or tokens
  - Code includes references to localhost
- If you issue a warning prefix it with WARNING.
{{- end -}}
