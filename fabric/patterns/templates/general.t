{{- define "general" -}}
- If Input file was provided and contains a FILENAME information, ensure that output also contains FILENAME information.
- Make sure not to add trailing white spaces to lines
- Always return entire changed file, including the parts that have not changed.
- FILENAME information always is first line, e.g.
FILENAME: path/to/file.md

Actual file content goes here
- Follow the Specific User Request if provided
{{- end -}}
