# IoT-rendu
=======
# Inception of Things

A comprehensive hands-on project from the 42 school curriculum focused on containerization, orchestration, and continuous deployment technologies.

## Project Overview

**Inception of Things** is a 42 school project designed to teach students practical skills in modern DevOps and infrastructure management. The project progresses through three parts, each building upon the previous one, introducing increasingly complex technologies and concepts.

### Project Goals

- Master **containerization** with Docker
- Learn **Kubernetes** orchestration (K3s and K3d variants)
- Implement **Continuous Deployment** pipelines with Argo CD
- Understand **Infrastructure as Code** principles
- Gain practical experience with DevOps workflows

## Project Structure

The project is divided into three parts, each with specific learning objectives:

### Part 1: K3s & Vagrant
- Set up a Kubernetes cluster using **K3s** (lightweight Kubernetes)
- Use **Vagrant** to provision virtual machines
- Deploy applications across master and worker nodes
- Learn basic Kubernetes concepts and networking

**Skills**: Vagrant, K3s, kubectl, multi-node clustering

### Part 2: K3s with Ingress & Service Mesh
- Deploy multiple applications in the same K3s cluster
- Configure **Ingress** for routing external traffic
- Implement **Services** and networking policies
- Learn advanced deployment strategies

**Skills**: Kubernetes Ingress, Services, DNS, routing, multi-app deployments

### Part 3: K3d and Argo CD
- Work with **K3d** (Kubernetes in Docker) for lightweight local development
- Implement **Argo CD** for continuous deployment
- Set up GitOps workflows with automated deployments
- Manage multiple namespaces and applications

**Skills**: K3d, Argo CD, GitOps, continuous deployment, Docker

## Quick Start

### Prerequisites

- Docker (for K3d)
- kubectl
- Make

### Installation

```bash
# Clean all environments
make fclean

# Clean individual parts
make clean-p1
make clean-p2
make clean-p3
```

### Running Each Part

```bash
# Part 1: K3s & Vagrant
cd p1
make install-tools
make config-cluster

# Part 2: K3s with Ingress
cd p2
make install-tools
make config-cluster

# Part 3: K3d and Argo CD
cd p3
make install-tools
make config-cluster
```

## Technologies Used

- **Docker**: Container runtime and image management
- **Kubernetes (K3s/K3d)**: Container orchestration
- **Vagrant**: Infrastructure provisioning
- **kubectl**: Kubernetes CLI
- **Argo CD**: Continuous deployment and GitOps
- **Ingress Controller**: HTTP routing
- **GitHub**: Repository management and GitOps source

## Project Documentation

Each part contains detailed documentation:

- `p1/Doc/README.md` - Part 1 specification and commands
- `p2/Doc/README.md` - Part 2 specification and commands
- `p3/Doc/README.md` - Part 3 specification and commands

## Key Concepts

### Containerization
Understanding how Docker packages applications and their dependencies into containers for consistent deployment.

### Orchestration
Learning how Kubernetes manages, scales, and deploys containerized applications across clusters.

### GitOps
Implementing infrastructure and application deployments declaratively through Git repositories with automated synchronization.

### Continuous Deployment
Automating the deployment process to ensure changes in the repository are automatically deployed to the cluster.

## Repository Structure

```
Inception-of-things/
├── Makefile              # Root cleanup commands
├── README.md             # This file
├── p1/                   # Part 1: K3s & Vagrant
│   ├── Makefile
│   ├── Vagrantfile
│   └── Doc/
├── p2/                   # Part 2: K3s with Ingress
│   ├── Makefile
│   ├── Vagrantfile
│   ├── manifests/
│   └── Doc/
└── p3/                   # Part 3: K3d and Argo CD
    ├── Makefile
    ├── installation.sh
    ├── config_cluster.sh
    └── Doc/
```

## Learning Outcomes

Upon completing this project, students will:

✓ Understand containerization and Docker best practices  
✓ Deploy and manage Kubernetes clusters  
✓ Implement service discovery and networking  
✓ Configure continuous deployment pipelines  
✓ Use GitOps for infrastructure management  
✓ Troubleshoot and monitor containerized applications  

## Notes

- Each part is self-contained and can be worked on independently
- Proper cleanup between parts is important to avoid resource conflicts
- Use the provided Makefiles for consistent and automated workflows

## Author

Created as part of the 42 school curriculum.

---

**Status**: Project in progress | **Last Updated**: December 2024
>>>>>>> upstream/main
