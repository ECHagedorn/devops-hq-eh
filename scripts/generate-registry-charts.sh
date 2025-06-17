#!/bin/bash

set -e

CHART_NAME="registry"
CHART_DIR="./$CHART_NAME"
TEMPLATES_DIR="$CHART_DIR/templates"

mkdir -p "$TEMPLATES_DIR"

# Chart.yaml
cat > "$CHART_DIR/Chart.yaml" <<EOF
apiVersion: v2
name: $CHART_NAME
description: A Helm chart for deploying a Docker registry
type: application
version: 0.1.0
appVersion: "2"
EOF

# values.yaml
cat > "$CHART_DIR/values.yaml" <<EOF
namespace: default

image:
  repository: registry
  tag: "2"
  pullPolicy: IfNotPresent

persistence:
  enabled: true
  storageClass: ""
  accessModes:
    - ReadWriteOnce
  size: 5Gi
  existingClaim: ""
  mountPath: /var/lib/registry

service:
  type: ClusterIP
  port: 5000

nodePortService:
  enabled: true
  name: registry-np
  type: NodePort
  port: 5000
  nodePort: 32594
EOF

# namespace.yaml
cat > "$TEMPLATES_DIR/namespace.yaml" <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .Values.namespace }}
EOF

# pv.yaml
cat > "$TEMPLATES_DIR/pv.yaml" <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-pv
  namespace: {{ .Values.namespace }}
spec:
  capacity:
    storage: {{ .Values.persistence.size }}
  accessModes: {{ toYaml .Values.persistence.accessModes | nindent 4 }}
  hostPath:
    path: /opt/registry-data
EOF

# pvc.yaml
cat > "$TEMPLATES_DIR/pvc.yaml" <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: registry-pvc
  namespace: {{ .Values.namespace }}
spec:
  accessModes: {{ toYaml .Values.persistence.accessModes | nindent 4 }}
  resources:
    requests:
      storage: {{ .Values.persistence.size }}
  storageClassName: {{ .Values.persistence.storageClass | quote }}
EOF

# deployment.yaml
cat > "$TEMPLATES_DIR/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: registry
  namespace: {{ .Values.namespace }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: registry
  template:
    metadata:
      labels:
        app: registry
    spec:
      containers:
        - name: registry
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.port }}
          volumeMounts:
            - name: registry-storage
              mountPath: {{ .Values.persistence.mountPath }}
      volumes:
        - name: registry-storage
          persistentVolumeClaim:
            claimName: {{ .Values.persistence.existingClaim | default "registry-pvc" }}
EOF

# ClusterIP service.yaml
cat > "$TEMPLATES_DIR/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: registry
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: registry
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.port }}
EOF

# NodePort service-nodeport.yaml (conditionally created)
cat > "$TEMPLATES_DIR/service-nodeport.yaml" <<EOF
{{- if .Values.nodePortService.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.nodePortService.name }}
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.nodePortService.type }}
  selector:
    app: registry
  ports:
    - protocol: TCP
      port: {{ .Values.nodePortService.port }}
      targetPort: {{ .Values.nodePortService.port }}
      nodePort: {{ .Values.nodePortService.nodePort }}
{{- end }}
EOF

echo "Helm chart files created in $CHART_DIR"
echo ""
echo "To migrate without losing images:"
echo "1. Ensure your PVC name and namespace match your current deployment."
echo "2. Delete the old Deployment and Service (but NOT the PVC/PV):"
echo "   kubectl delete deployment registry -n <namespace>"
echo "   kubectl delete service registry -n <namespace>"
echo "   kubectl delete service registry-np -n <namespace>"
echo "3. Install the Helm chart:"
echo "   helm upgrade --install registry $CHART_DIR --namespace <namespace> --create-namespace"
