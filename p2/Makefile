# Part 2 : K3s and Three Simple Applications

.PHONY: help up clean destroy fclean vbox-clean status hostname ip resources k3s pods deployments services ingress apps all check-active-vms

.DEFAULT_GOAL := help

help:
	@echo "\033[1;36m=== Inception of Things - Part 2 ===\033[0m"
	@echo "\033[1;33mAvailable commands:\033[0m"
	@echo "  \033[1;32mmake up\033[0m                	- Creates and starts the VM defined in Vagrantfile"
	@echo "  \033[1;32mmake clean\033[0m             	- Deletes .vagrant"
	@echo "  \033[1;32mmake destroy\033[0m           	- Destroys VM with Vagrant"
	@echo "  \033[1;32mmake vbox-clean\033[0m        	- Removes all VirtualBox VMs (by UUID)"
	@echo "  \033[1;32mmake fclean\033[0m            	- Full clean (destroy VM + remove .vagrant)"
	@echo "  \033[1;32mmake check-vms\033[0m 	- Check if there are active VMs"
	@echo ""
	@echo "\033[1;33mValidation commands:\033[0m"
	@echo "  \033[1;32mmake status\033[0m           	- Check VM status"
	@echo "  \033[1;32mmake hostname\033[0m  		- Verify machine name (lciulloS)"
	@echo "  \033[1;32mmake ip\033[0m        		- Verify IP address (192.168.56.110)"
	@echo "  \033[1;32mmake resources\033[0m 		- Check RAM and CPU"
	@echo "  \033[1;32mmake k3s\033[0m       		- Check K3s server installation"
	@echo "  \033[1;32mmake pods\033[0m     		- Check all pods are running"
	@echo "  \033[1;32mmake deployments\033[0m 		- Check deployments (replicas)"
	@echo "  \033[1;32mmake services\033[0m 		- Check K3s services"
	@echo "  \033[1;32mmake ingress\033[0m  		- Check Ingress configuration"
	@echo "  \033[1;32mmake apps\033[0m     		- Test application access via HTTP"
	@echo "  \033[1;32mmake all\033[0m      		- Run all verifications"
	@echo ""

up: clean
	vagrant up

destroy:
	vagrant destroy -f

clean:
	@if [ -d .vagrant ]; then rm -rf .vagrant; fi
	@if [ -f node-token.txt ]; then rm -f node-token.txt; fi
	@echo "\033[1;32mCleanup completed: .vagrant and node-token.txt removed\033[0m"

vbox-clean:
	@vboxmanage list vms | grep -o '{.*}' | tr -d '{}' | while read vm_id; do \
		echo "Stopping VM: $$vm_id"; \
		vboxmanage controlvm "$$vm_id" poweroff 2>/dev/null || true; \
		sleep 1; \
		echo "Deleting VM: $$vm_id"; \
		vboxmanage unregistervm "$$vm_id" --delete; \
	done
	@echo "\033[1;32mAll VirtualBox VMs deleted!\033[0m"

fclean: destroy clean vbox-clean
	@echo "\033[1;31mFull cleanup completed!\033[0m"

check-vms:
	@echo "\033[1;36m=== Active VMs Check ===\033[0m"
	@active_count=$$(vboxmanage list vms | wc -l); \
	if [ $$active_count -eq 0 ]; then \
		echo "\033[1;32m✓ No active VMs\033[0m"; \
	else \
		echo "\033[1;33m⚠ Active VMs found:\033[0m"; \
		vboxmanage list vms; \
		echo "\033[1;33mRun 'make fclean' to remove them\033[0m"; \
	fi

status:
	@echo "\033[1;36m=== VM Status ===\033[0m"
	@vagrant status

hostname:
	@echo "\033[1;36m=== Verify Hostname ===\033[0m"
	@echo "Machine name:"
	@vagrant ssh lciulloS -c "hostname" 2>/dev/null
	@echo "\033[1;32m✓ Expected: lciulloS\033[0m"

ip:
	@echo "\033[1;36m=== Verify IP Address ===\033[0m"
	@echo "IP Address:"
	@vagrant ssh lciulloS -c "ip addr show eth1 | grep 'inet '" 2>/dev/null
	@echo "\033[1;32m✓ Expected: 192.168.56.110\033[0m"

resources:
	@echo "\033[1;36m=== Resources (RAM & CPU) ===\033[0m"
	@vagrant ssh lciulloS -c "echo 'Memory:' && free -h | head -2 && echo 'CPUs:' && nproc" 2>/dev/null
	@echo "\033[1;32m✓ Expected: 1024+ MB RAM, 1+ CPU\033[0m"

k3s:
	@echo "\033[1;36m=== K3s Server Status ===\033[0m"
	@vagrant ssh lciulloS -c "sudo systemctl status k3s" 2>/dev/null | grep -E "Active|running|k3s" || echo "\033[1;31m✗ K3s not running\033[0m"
	@echo ""
	@echo "\033[1;36m=== Kubernetes Nodes ===\033[0m"
	@vagrant ssh lciulloS -c "sudo kubectl get nodes -o wide" 2>/dev/null
	@echo "\033[1;32m✓ Expected: lciulloS node in Ready state\033[0m"

pods:
	@echo "\033[1;36m=== Kubernetes Pods ===\033[0m"
	@vagrant ssh lciulloS -c "sudo kubectl get pods -o wide" 2>/dev/null
	@echo "\033[1;32m✓ Expected: app1 (1), app2 (3 replicas), app3 (1) - all Running\033[0m"

deployments:
	@echo "\033[1;36m=== Kubernetes Deployments ===\033[0m"
	@vagrant ssh lciulloS -c "sudo kubectl get deployments" 2>/dev/null
	@echo "\033[1;32m✓ Expected: app1 (1/1), app2 (3/3), app3 (1/1)\033[0m"

services:
	@echo "\033[1;36m=== Kubernetes Services ===\033[0m"
	@vagrant ssh lciulloS -c "sudo kubectl get services" 2>/dev/null
	@echo "\033[1;32m✓ Expected: app1-service, app2-service, app3-service with ClusterIP\033[0m"

ingress:
	@echo "\033[1;36m=== Kubernetes Ingress ===\033[0m"
	@vagrant ssh lciulloS -c "sudo kubectl get ingress" 2>/dev/null
	@echo ""
	@echo "\033[1;36m=== Ingress Details ===\033[0m"
	@vagrant ssh lciulloS -c "sudo kubectl describe ingress app-ingress" 2>/dev/null | grep -E "Host|Path|Backend" || echo "\033[1;31m✗ Ingress not found\033[0m"
	@echo "\033[1;32m✓ Expected: Rules for app1.com, app2.com, and default backend\033[0m"

apps:
	@echo "\033[1;36m=== Testing Application Access ===\033[0m"
	@echo "\033[1;33m[1] Testing App1 (app1.com):\033[0m"
	@vagrant ssh lciulloS -c "curl -s -H 'Host: app1.com' http://localhost | head -5" 2>/dev/null || echo "\033[1;31m✗ Connection failed\033[0m"
	@echo ""
	@echo "\033[1;33m[2] Testing App2 (app2.com):\033[0m"
	@vagrant ssh lciulloS -c "curl -s -H 'Host: app2.com' http://localhost | head -5" 2>/dev/null || echo "\033[1;31m✗ Connection failed\033[0m"
	@echo ""
	@echo "\033[1;33m[3] Testing App3 (default):\033[0m"
	@vagrant ssh lciulloS -c "curl -s http://localhost | head -5" 2>/dev/null || echo "\033[1;31m✗ Connection failed\033[0m"
	@echo ""
	@echo "\033[1;32m✓ All applications should return HTML content\033[0m"

all: hostname ip resources k3s pods deployments services ingress apps
	@echo ""
	@echo "\033[1;32m✓ All verifications completed!\033[0m"
