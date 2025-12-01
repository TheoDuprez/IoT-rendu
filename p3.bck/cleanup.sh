#!/bin/bash

# Clean up everything
echo "Cleaning up..."
kubectl delete -f https://raw.githubusercontent.com/lciullo/iot_lciullo/main/application.yaml 2>/dev/null || true
kubectl delete namespace argocd 2>/dev/null || true
kubectl delete namespace dev 2>/dev/null || true

echo "Cleanup complete!"
