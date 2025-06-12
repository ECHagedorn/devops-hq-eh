#!/bin/bash
#
kubectl delete pipelinerun build-debug-pod-run-001 -n tekton-pipelines
kubectl apply -f  build-debug-pod-pipeline.yaml
kubectl apply -f debug-pod-build-task.yaml
kubectl apply -f build-debug-pod-pipelinerun.yaml
