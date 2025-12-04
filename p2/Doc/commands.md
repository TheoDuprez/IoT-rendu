# ====================================================================== #
#                Commands part 2 cheat sheet
# ====================================================================== #

# -------------------------------------- #
#   Vagrant commands cheat sheet
# -------------------------------------- #

# Create and start VM
- vagrant up
Output example:
Bringing machine 'lciulloS' up with 'virtualbox' provider...


# Check state of VM
- vagrant status
Example output:
Current machine states:
lciulloS                  running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

# SSH into VM
- vagrant ssh lciulloS

# Destroy VM
- vagrant destroy -f

# Clean up local files
- rm -rf .vagrant/
- rm -f node-token.txt

# ====================================================================== #
# -------------------------------------- #
#   vboxManage commands cheat sheet
# -------------------------------------- #

# List existing VirtualBox VMs
- vboxmanage list vms
Example output:
"p2_lciulloS_1764601868044_55090" {a2d583e7-1d11-4768-b9e7-e7b6e1dcccba}

# Stop a VM
- vboxmanage controlvm a2d583e7-1d11-4768-b9e7-e7b6e1dcccba poweroff

# Delete a VM
- vboxmanage unregistervm a2d583e7-1d11-4768-b9e7-e7b6e1dcccba --delete

# ====================================================================== #
# -------------------------------------- #
#   Part 2 Subject verification commands
# -------------------------------------- #

# Verify VM is created and running
- vagrant status
- vagrant global-status

Expected: VM status should be "running"

# Verify machine name and IP
- vagrant ssh lciulloS -c "hostname"
- vagrant ssh lciulloS -c "ip addr show eth1 | grep 'inet '"
Expected: hostname = lciulloS, IP = 192.168.56.110

# Verify resources (RAM and CPU)
- vagrant ssh lciulloS -c "free -h | head -2 && echo 'CPUs:' && nproc"

Expected: 1024 MB RAM (or more) and at least 1 CPU

# Verify SSH connection without password
- vagrant ssh lciulloS

Expected: No password prompt

# Verify K3s is installed and running (server mode)
- vagrant ssh lciulloS -c "sudo systemctl status k3s"

Expected: active (running)

# Verify kubectl access
- vagrant ssh lciulloS -c "sudo kubectl version"

Expected: kubectl version output with client and server info

# Verify K3s cluster is ready
- vagrant ssh lciulloS -c "sudo kubectl get nodes"
Expected: lciulloS node in Ready state

# ====================================================================== #
# -------------------------------------- #
#   Kubernetes verification commands
# -------------------------------------- #

# List all pods in default namespace
- vagrant ssh lciulloS -c "sudo kubectl get pods"
Expected: app1, app2 (3 replicas), and app3 pods should be Running

# Check pod details and status
- vagrant ssh lciulloS -c "sudo kubectl describe pods"
Expected: All pods should show Running status with no errors

# List all deployments
- vagrant ssh lciulloS -c "sudo kubectl get deployments"

Expected: 
- app1: 1 replica
- app2: 3 replicas
- app3: 1 replica

# Check deployment status
- vagrant ssh lciulloS -c "sudo kubectl describe deployment app1"
- vagrant ssh lciulloS -c "sudo kubectl describe deployment app2"
- vagrant ssh lciulloS -c "sudo kubectl describe deployment app3"
Expected: All replicas should be ready and available

# List all services
- vagrant ssh lciulloS -c "sudo kubectl get services"
Expected: app1-service, app2-service, app3-service listed with ClusterIP

# Check service details
- vagrant ssh lciulloS -c "sudo kubectl describe service app1-service"
Expected: Service should have endpoints pointing to pods

# List Ingress resources
- vagrant ssh lciulloS -c "sudo kubectl get ingress"
Expected: app-ingress resource listed

# Check Ingress details
- vagrant ssh lciulloS -c "sudo kubectl describe ingress app-ingress"
Expected: Ingress rules should show:
- app1.com → app1-service:80
- app2.com → app2-service:80
- default backend → app3-service:80

# View logs from a pod
- vagrant ssh lciulloS -c "sudo kubectl logs <pod-name>"
Example:
- vagrant ssh lciulloS -c "sudo kubectl logs app1-6d8b4f9c5d-xyz"


# Port forward to test locally
- vagrant ssh lciulloS -c "sudo kubectl port-forward service/app1-service 8080:80"

Then access on : 
- http://app1.com
- http://app2.com
- http://192.168.56.110

# ====================================================================== #
# -------------------------------------- #
#   Testing Application Access (from host)
# -------------------------------------- #

# Direct HTTP requests to test Ingress routing
- curl -H "Host: app1.com" http://192.168.56.110
- curl -H "Host: app1.com" http://192.168.56.110
- curl -H "Host: app2.com" http://192.168.56.110
- curl http://192.168.56.110

# Go on browser and test:
- http://app1.com
- http://app2.com
- http://192.168.56.110

# Test with multiple requests to app2 (to see different replicas)
- for i in {1..10}; do curl -H "Host: app2.com" http://192.168.56.110; done
Expected: Different pod names should appear (3 replicas)

# Add hosts entry (on host machine) for easier testing
- echo "192.168.56.110 app1.com app2.com" | sudo tee -a /etc/hosts

Then:
- curl http://app1.com
- curl http://app2.com

# Test from inside the VM
- vagrant ssh lciulloS
- curl -H "Host: app1.com" http://localhost
- curl -H "Host: app2.com" http://localhost
- curl http://localhost

# ====================================================================== #
# -------------------------------------- #
#   Useful K3s troubleshooting commands
# -------------------------------------- #

# Check K3s logs
- vagrant ssh lciulloS -c "sudo journalctl -u k3s -f"

# Check if all K3s components are running
- vagrant ssh lciulloS -c "sudo kubectl get all -A"

# Check API server status
- vagrant ssh lciulloS -c "sudo systemctl status k3s"

# Restart K3s if needed
- vagrant ssh lciulloS -c "sudo systemctl restart k3s"

# Delete and redeploy manifests
- vagrant ssh lciulloS -c "sudo kubectl delete -f /vagrant/manifests/"
- vagrant ssh lciulloS -c "sudo kubectl apply -f /vagrant/manifests/"

# Check events for troubleshooting
- vagrant ssh lciulloS -c "sudo kubectl get events"

# Get detailed cluster info
- vagrant ssh lciulloS -c "sudo kubectl cluster-info dump"

