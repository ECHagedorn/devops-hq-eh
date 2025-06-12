# 1. PAT Personal Access Token on github
# 2. Create generic secret using PAT and your username:

# kubectl create secret generic git-credentials \
#  --type=kubernetes.io/basic-auth \
#  --from-literal=username="{username}" \
#  --from-literal=password="${PAT}" \
#  -n tekton-pipelines

# OR Create an ssh keypair
# Upload the public-key to your git settings
# Create a k8s secret through:

# kubectl create secret generic tekton-ssh-key  \
# --from-file=ssh-privatekey=${KEYPATH} \
# --type=kubernetes.io/ssh-auth \
# -n tekton-pipelines

# kubectl annotate secret tekton-ssh-key \
# tekton.dev/git-0=github.com
# -n tekton-pipelines

# Make sure that the secret is ANNOTATED immediately and the SA uses the appropriate creds accordingly
