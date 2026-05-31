{{/*
Expand the name of the chart.
*/}}
{{- define "redis.fullname" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

#if define nameOverride in values, our full name will be nameOverride
#be if dont define nameOverride, our full name will be chart.name by default