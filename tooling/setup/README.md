# WORKSTATION PREPARATION
# -----------------------

# WINDOWS NOTES:
# --------------
#   For this setup on windows workstations you will have to include some network port-mapping between wsl and your windows via powershell:

#   This will allow you to access the services through the ports on your workstation for more convenient work

#   Open powershell and execute the following after replacing the approppriate parameters:
#   you can retrieve the wsl_ip after running ifconfig from `wsl`


#       $ netsh interface portproxy show all
#       $ netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=${nodePort} connectaddress=${wsl_ip} connectport=${nodePort}


# UBUNTU NOTES:
# -------------
#   Executing ./install_devops_tools_wsl.sh kicks off workstation preparation, mind you all versions are defined on the script if there are 
#   upgrades or changes to be done do so after careful review of what impact it may bring

# K3S
# ---
#   Mindful reminder, that after installing k3s there may be some permission changes you have to tweak to be able to use your local-cluster
#   mind the ownership and permissions allowed on these files

#       emmanuel: /home/emmanuel/.kube$ ls -ltrh
#          total 8.0K
#          drwxr-x--- 4 emmanuel emmanuel 4.0K Jun 12 00:13 cache
#          -rw------- 1 emmanuel emmanuel 3.0K Jun 12 15:23 config

#       emmanuel:/etc/rancher/k3s$ sudo ls -ltrh
#          total 8.0K
#          -rw-r--r-- 1 root root  166 Jun 12 14:51 registries.yaml
#          -rw------- 1 root root 2.9K Jun 12 14:51 k3s.yaml


#   To install kubectx, kubens and fzf do the following

#   git clone https://github.com/ahmetb/kubectx.git
#   mv kubectx/ /opt/kubectx/
#   sudo mv kubectx/ /opt/kubectx/
#   sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
#   sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
#   sudo apt install fzf


## CONTAINERS, IMAGES AND REGISTRIES
#  ---------------------------------
# 
# CONTAINERS
# ----------
#   This installation does not rely on docker, it is straight out of the box k3s which operates with containerd.
#   A tool you can use to test local builds would be podman, which gives you the exact same feel as docker-cli:

#       $ apt install podman

# IMAGES and REGISTRIES
# ---------------------
#   This setup gives you an internal registry to push and pull local images to, however it needs to be adjusted to allow access.
#   the local registry will require you to add this to a file named: 
#       emmanuel: /etc/rancher/k3s/registries.yaml
#         configs:
#          "registry.default.svc.cluster.local:5000": # <-- This is your registry's FQDN
#            tls:
#              insecure_skip_verify: true
# 
#   k3s needs to be restarted and the registry service needs to be exposed after

#       $ kubectl expose svc registry -n default --type=NodePort --name=registry-np --port=5000 --target-port=5000

