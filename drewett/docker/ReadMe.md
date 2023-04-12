# Using terrafrom to spin up docker containers and Kubernetes

# For kubernetes, make sure kubernetes is enabled in the docker desktop and the command line tool Kubectl.exe is installed.
# curl.exe -LO "https://dl.k8s.io/release/v1.26.0/bin/windows/amd64/kubectl.exe"
# curl.exe -LO "https://dl.k8s.io/v1.26.0/bin/windows/amd64/kubectl.exe.sha256"
# validate the download in powershell  "CertUtil -hashfile kubectl.exe SHA256" "type kubectl.exe.sha256"
#  $(Get-FileHash -Algorithm SHA256 .\kubectl.exe).Hash -eq $(Get-Content .\kubectl.exe.sha256)
# Append to system path to access

# After apply run: curl http://localhost

# You can also run: "kubectl get deployments"  to see deployments