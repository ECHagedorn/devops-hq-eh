#!/bin/bash

set -e

CHART_NAME="ai-agent"
CHART_DIR="./$CHART_NAME"
TEMPLATES_DIR="$CHART_DIR/templates"

mkdir -p "$TEMPLATES_DIR"

# Chart.yaml
cat > "$CHART_DIR/Chart.yaml" <<EOF
apiVersion: v2
name: $CHART_NAME
description: A Helm chart for deploying the ai-agent job
type: application
version: 0.1.0
appVersion: "1.0.0"
EOF

# values.yaml
cat > "$CHART_DIR/values.yaml" <<EOF
jobName: ai-agent-job

image:
  repository: your-dockerhub-username/ai-agent
  tag: latest
  pullPolicy: IfNotPresent

backoffLimit: 1
EOF

# job.yaml
cat > "$TEMPLATES_DIR/job.yaml" <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Values.jobName }}
spec:
  template:
    spec:
      containers:
      - name: ai-agent
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
      restartPolicy: Never
  backoffLimit: {{ .Values.backoffLimit }}
EOF

echo "Helm chart files created in $CHART_DIR"
echo ""
echo "To use:"
echo "1. Edit values.yaml to set your image repository and tag."
echo "2. Install the chart:"
echo "   helm upgrade --install ai-agent
