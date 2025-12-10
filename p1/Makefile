# Part 1 : Part 1 (K3s & Vagrant)

.PHONY: help up clean destroy fclean vbox-clean status names ips resources k3s all check-active-vms 

.DEFAULT_GOAL := help

help:
	@echo "\033[1;36m=== Inception of Things - Part 1 ===\033[0m"
	@echo "\033[1;33mAvailable commands:\033[0m"
	@echo "  \033[1;32mmake up\033[0m           	- Creates and starts the VMs defined in the Vagrantfile."
	@echo "  \033[1;32mmake clean\033[0m        	- Deletes .vagrant and node-token.txt"
	@echo "  \033[1;32mmake destroy\033[0m      	- Destroys VMs with Vagrant"
	@echo "  \033[1;32mmake vbox-clean\033[0m   	- Removes all VirtualBox VMs (by UUID)"
	@echo "  \033[1;32mmake fclean\033[0m       	- Full clean (destroy VMs + remove .vagrant)"
	@echo "  \033[1;32mmake check-vms\033[0m	- Check if there are active VMs"
	@echo ""
	@echo "\033[1;33mValidation commands:\033[0m"
	@echo "  \033[1;32mmake status\033[0m  		- Check VM status"
	@echo "  \033[1;32mmake names\033[0m   		- Verify machine names"
	@echo "  \033[1;32mmake ips\033[0m     		- Verify IP addresses"
	@echo "  \033[1;32mmake resources\033[0m 	- Check RAM and CPU"
	@echo "  \033[1;32mmake k3s\033[0m     		- Check K3s installation"
	@echo ""


installation:	
	@echo "\033[1;36m=== Installation Instructions ===\033[0m"
	@echo "1. Install VirtualBox"
	@sudo bash ./scripts/install_virtualbox.sh
	@echo "2. Install Vagrant"
	@sudo bash ./scripts/install_vagrant.sh
	@echo "\033[1;32mInstallation completed!\033[0m"

up: clean 
	vagrant up

destroy:
	vagrant destroy -f

clean :
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

names:
	@echo "\033[1;36m=== Machine Names ===\033[0m"
	@echo "Master: $$(vagrant ssh lciulloS -c 'hostname' 2>/dev/null | tail -1)"
	@echo "Worker: $$(vagrant ssh lciulloSW -c 'hostname' 2>/dev/null | tail -1)"

ips:
	@echo "\033[1;36m=== IP Addresses ===\033[0m"
	@echo "Master IP:"
	@vagrant ssh lciulloS -c "ip addr show eth1 | grep 'inet '"
	@echo "Worker IP:"
	@vagrant ssh lciulloSW -c "ip addr show eth1 | grep 'inet '"

resources:
	@echo "\033[1;36m=== Resources (RAM & CPU) ===\033[0m"
	@echo "Master:"
	@vagrant ssh lciulloS -c "free -h | head -2 && echo 'CPUs:' && nproc"
	@echo "Worker:"
	@vagrant ssh lciulloSW -c "free -h | head -2 && echo 'CPUs:' && nproc"

k3s:
	@echo "\033[1;36m=== K3s Status ===\033[0m"
	@echo "Kubernetes Nodes: on lciulloS"
	@vagrant ssh lciulloS -c "sudo kubectl get nodes -o wide"

verify-all: verify-status verify-names verify-ips verify-resources verify-k3s
	@echo "\033[1;32m✓ All verifications completed!\033[0m"


