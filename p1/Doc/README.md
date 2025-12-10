# Inception of Things — Part 1 (K3s & Vagrant)

# Objective  
Recreate a minimal K3s environment on 2 virtual machines managed by Vagrant. 
Install K3s in server (controller) mode on the first machine and in agent (worker) mode on the second. 
Ensure kubectl is available and enable SSH access without passwords.

# Host prerequisites
- VirtualBox (or any Vagrant-supported provider)  
- Vagrant
- K3s 

# p1 structure
  - install_vagrant.sh
  - install_virtualbox.sh
  - install_k3s_server.sh
  - install_k3s_agent.sh
  - vagrantfile

# p1 Doc structure
    - README.md
    - commands.txt : useful commands

# Subject specifications
- Two Vagrant machines.
- Machine names must use your team login:
  - Machine 1 (controller): hostname `<login>S` (e.g. `wilS`), IP `192.168.56.110`
  - Machine 2 (agent): hostname `<login>SW` (e.g. `wilSW`), IP `192.168.56.111`
- Minimal resources recommended: 1 CPU and 512 MB (1024 MB recommended if 512 causes issues).
- Install K3s:
  - Server (controller) on the first VM.
  - Agent on the second VM.
- Install kubectl (on the host or at least on the controller).




