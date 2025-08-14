{{- define "obsidian_files" -}}
{{- $root := "/home/fritz/Sync/FritzSync/private" -}}
{{- range file.Walk $root -}}
{{- if not (file.IsDir .) -}}
  {{- if strings.HasSuffix ".md" . -}}
    {{.}}{{"\n"}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
