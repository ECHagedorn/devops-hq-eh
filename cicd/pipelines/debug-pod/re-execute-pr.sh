#!/bin/bash
#
kubectl apply -f cd/deploy-debug-pod-task.yaml
kubectl delete pipelinerun build-deploy-debug-pod-run-manual-001 -n tekton-pipelines
kubectl apply -f  build-deploy-debug-pod-pipeline.yaml
kubectl apply -f debug-pod-build-task.yaml
kubectl apply -f build-deploy-debug-pod-pipelinerun.yaml