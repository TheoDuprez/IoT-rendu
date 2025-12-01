# ====================================================================== #
# -------------------------------------- #
#   Vagrant commands cheat sheet
# -------------------------------------- #

# Create and start VMs
- vagrant up
Output example :
Bringing machine 'lciulloS' up with 'virtualbox' provider...
Bringing machine 'lciulloSW' up with 'virtualbox' provider...


# Check state of VMs
-  vagrant status

Example output :
Current machine states:

lciulloS                  not created (virtualbox)
lciulloSW                 not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.

# Delete a specific VM
- vagrant destroy -f lciulloS
- vagrant destroy -f lciulloSW

# Delete both VMs
- vagrant destroy -f 

# Clean up 
- rm -rf .vagrant/

# ====================================================================== #
# -------------------------------------- #
#   vboxmanage commands cheat sheet
# -------------------------------------- #

# List existing VirtualBox VMs
- vboxmanage list vms
Example output :
 vboxmanage list vms
"p1_lciulloS_1764601868044_55090" {a2d583e7-1d11-4768-b9e7-e7b6e1dcccba}
"p1_lciulloSW_1764601956041_65988" {771701b6-e98b-4879-b164-8dba10a42d35}

# stop VMs
- vboxmanage controlvm a2d583e7-1d11-4768-b9e7-e7b6e1dcccba poweroff
- vboxmanage controlvm 771701b6-e98b-4879-b164
Example output :
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

# Delete VMs
- vboxmanage unregistervm a2d583e7-1d11-4768-b9e7-e7b6e1dcccba --delete
Example output :
0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%

# ====================================================================== #
# -------------------------------------- #
#   Part 1  Subject verifycation commands
# -------------------------------------- #

# Verify VMs are created and running
- vagrant status
- vagrant global-status

# Verify machine names
- vagrant ssh lciulloS -c "hostname"
- vagrant ssh lciulloSW -c "hostname"
Expected: lciulloS and lciulloSW

# Verify IP addresses
- vagrant ssh lciulloS -c "ip addr show eth1"
- vagrant ssh lciulloSW -c "ip addr show eth1"
Expected: 192.168.56.110 and 192.168.56.111

# Verify resources (RAM and CPU)
- vagrant ssh lciulloS -c "free -h && nproc"
- vagrant ssh lciulloSW -c "free -h && nproc"
Expected: 1024 MB RAM and 1 CPU

# Verify SSH connection without password
- vagrant ssh lciulloS
- vagrant ssh lciulloSW
Expected: No password prompt

# Verify K3s installed in Controller mode (Master)
- vagrant ssh lciulloS -c "sudo kubectl get nodes -o wide"
Expected: lciulloS node in Ready state

# Verify K3s installed in Agent mode (Worker)
- vagrant ssh lciulloSW -c "sudo systemctl status k3s-agent"
Expected: active (running)

# Verify both nodes are connected
- vagrant ssh lciulloS -c "sudo kubectl get nodes"
Expected: Both lciulloS and lciulloSW nodes listed

# Verify kubectl is installed
- vagrant ssh lciulloS -c "kubectl version --client"
- vagrant ssh lciulloSW -c "kubectl version --client"
Expected: kubectl version output

# Complete validation (all in one)
- vagrant status && vagrant ssh lciulloS -c "hostname && ip addr show eth1 | grep 'inet ' && free -h | head -2 && nproc && sudo kubectl get nodes"
