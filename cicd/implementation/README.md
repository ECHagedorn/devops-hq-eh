# Pipelines can be common as well, parameter overrides are present in the triggerTemplate of the service. This will determine
# which service(and pipelineRun) will use the pipeline.

# *note: build-deploy-microservice-pipeline has the default parameters set

    Tekton is setup to manage installations on the cluster to control rollouts and upgrades. To delineate *platform application 
    services* from *platform infrastructure services* -- cicd components are categorized as:
        -   platform-app
        -   platform-infra
        -   cloud-infra ( if config-connector/crossplane will be used or if terraform will be controlled by tekton )

    These workloads can be removed from the kubernetes cluster if needed, but while it is running on the cluster it will be managed
    in this manner

~/devops-hq-eh/cicd$ tree -L 4
.
├── install
│   └── tekton
│       ├── README.md
│       ├── builder
│       │   └── kaniko-task.yaml
│       ├── install_tekton.sh
│       ├── permissions
│       │   ├── tekton-devops-hq-eh-rbac.yaml
│       │   ├── tekton-registry-config.yaml
│       │   ├── tekton-registry-rbac.yaml
│       │   ├── tekton-sa.yaml
│       │   └── trigger-event-listener-rbac.yaml
│       └── triggers
│           ├── README.md
│           ├── event-listener.yaml
│           ├── sample-payload.json
│           └── trigger-binding.yaml
└── pipelines
    ├── README.md
    ├── common
    │   ├── pipelines
    │   │   ├── platform-app
    │   │   └── platform-infra
    │   └── tasks
    │       ├── platform-app
    │       └── platform-infra
    └── platform-app
        ├── debug-pod
        │   ├── README.md
        │   ├── debug-pod-trigger-template.yaml
        │   ├── tasks
        │   └── tests
        ├── hquarter
        │   ├── README.md
        │   ├── hquarter-trigger-template.yaml
        │   └── tasks
        └── templates
            ├── build-deploy-microservice-pipeline.yaml
            ├── microservice-pipeline-trigger-template.yaml
            └── tasks