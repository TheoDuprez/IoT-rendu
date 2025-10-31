#!/bin/bash
echo "=== Vagrant VMs running ==="
vagrant global-status --prune | grep running
echo ""
echo "=== Consommation CPU/RAM des VMs ==="
ps -eo pid,cmd,%cpu,%mem --sort=-%cpu | grep VBox
