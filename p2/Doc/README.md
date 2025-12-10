# Inception of Things — Part 2 (K3s and Three Simple Applications)

# Objective  
Deploy three simple web applications in a K3s cluster running on a single virtual machine. 
Configure an Ingress controller to route incoming requests to the appropriate application based on the HTTP HOST header.

# Host prerequisites
- VirtualBox (or any Vagrant-supported provider)  
- Vagrant
- K3s (in server/standalone mode)

# p2 structure
- `Vagrantfile` - VM configuration (single machine)
- `install-k3s-master.sh` - K3s server installation script
- `deploy-manifests.sh` - Kubernetes manifests deployment script
- `manifests/` - Kubernetes YAML files
  - `app1.yaml` - Application 1 deployment and service
  - `app2.yaml` - Application 2 deployment (3 replicas) and service
  - `app3.yaml` - Application 3 deployment and service
  - `ingress.yaml` - Ingress rules for host-based routing

# p2 Doc structure
- `README.md` - This file, project overview
- `commands.md` - Useful commands for verification and troubleshooting

# Subject specifications

# Virtual Machine
- **Single Vagrant machine** (no worker node required)
- Machine name: `<login>S` (e.g., `lciulloS`)
- IP address: `192.168.56.110`
- Distribution: Latest stable Linux (e.g., Debian 13, Ubuntu LTS)
- Resources: Minimum 1 CPU and 1024 MB RAM (more recommended for smooth operation)

# K3s Installation
- Install K3s in **server mode** (no agent/worker required)
- K3s is a lightweight Kubernetes distribution, ideal for this scenario

# Web Applications
Three web applications must be deployed and accessible via HTTP HOST-based routing:

1. **Application 1 (app1)**
   - Accessible via HOST: `app1.com`
   - 1 replica
   - Example image: `paulbouwer/hello-kubernetes:1.10`

2. **Application 2 (app2)**
   - Accessible via HOST: `app2.com`
   - 3 replicas (required for load balancing demonstration)
   - Example image: `paulbouwer/hello-kubernetes:1.10`

3. **Application 3 (app3)**
   - Default application (fallback)
   - Displayed when no specific HOST matches
   - 1 replica
   - Example image: `paulbouwer/hello-kubernetes:1.10`

# Ingress Configuration
- Implement Kubernetes Ingress to handle HOST-based routing
- Route requests to the correct service based on the HTTP HOST header
- Default route should direct to Application 3 when no HOST matches
- No TLS/HTTPS required

# Access Requirements
- Applications accessible at `192.168.56.110` via HTTP
- Client browser requests with specific HOST headers:
  - `curl -H "Host: app1.com" http://192.168.56.110` → displays App1
  - `curl -H "Host: app2.com" http://192.168.56.110` → displays App2 (any of 3 replicas)
  - `curl http://192.168.56.110` or other HOST → displays App3

# Validation
To verify the setup is complete, perform these checks:
1. VM is running and accessible
2. K3s server is running and healthy
3. All 3 applications are deployed with correct replicas
4. Services are created and running
5. Ingress routes requests correctly based on HOST header
6. All pods are in Running state

See `Doc/commands.md` for detailed verification commands.
