# Order of use:

1. *./tooling/setup*:         Installation of required tools on workstation includes but not limited to:
    -   k3s
    -   k9s
    -   ansible
    -   terraform
    -   python3
    -   golang



2. *./cicd/install*:          Installation of local cicd tool (Tekton) for local cicd builds.


3. *./cicd/pipelines*:        Source for pPipeline definitions, TaskRuns and other operations.
                              each service for now will have its own pipeline objects for building.

4. *./services*:              Source code directory for each app/service


5. *./manifests*:             Helm charts or kustomize files required for application deployment


6. *./cloudOps*:              Directory for cloud resourcing, and automation scripts

7. *./docs*:                  Feel free to write a journal of lessons learned and experiences you've encountered

