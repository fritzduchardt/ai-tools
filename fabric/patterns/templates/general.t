{{- define "general" -}}
- If Input file was provided and contains a FILENAME information, ensure that output also contains FILENAME information.
- Dont add trailing blank line.
- FILENAME information always is first line, e.g.
FILENAME: path/to/file.md

Actual file content goes here
{{- end -}}
