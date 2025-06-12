# 1. PAT Personal Access Token on github
# 2. Create generic secret using PAT and your username:

# kubectl create secret generic git-credentials \
#  --from-literal=username="{username}" \
#  --from-literal=password="${PAT}" \
#  -n tekton-pipelines

