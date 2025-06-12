## To test errors on pipelineRuns its better to test the behaviour through the smallest component which would be the TaskRun.
## Verify what you can see through tkn logs, below are commands you can play around with 
## after making changes to different tekton resources:

# tkn tr list
# tkn tr logs test-ssh-clone -f -n tekton-pipelines
# tkn tr delete test-ssh-clone
# tkn tr logs test-ssh-clone -f -n tekton-pipelines
