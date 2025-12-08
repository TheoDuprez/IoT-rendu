#!/bin/bash

set -e

### Configuration ###
GITLAB_USER="root"
GITLAB_PROJECT_NAME="iot_lciullo"
GITLAB_HOST="gitlab.local"
GITLAB_PORT="8181"
GITLAB_INTERNAL_HOST="gitlab-webservice-default.gitlab.svc.cluster.local"
CLONE_DIR="/tmp/iot_lciullo"

# GitLab Personal Access Token
GITLAB_PAT=$(cat /tmp/gitlab_pat.txt 2>/dev/null || echo "")

if [ -z "$GITLAB_PAT" ]; then
    echo "Error: GitLab PAT not found in /tmp/gitlab_pat.txt"
    exit 1
fi

# Check argument
if [ "$#" -ne 1 ] || { [ "$1" != "v1" ] && [ "$1" != "v2" ]; }; then
    echo "Usage: $0 <v1|v2>"
    echo "Example: $0 v1"
    exit 1
fi

VERSION=$1

echo "Switching to version: $VERSION"

# Detect if running inside cluster or locally
if kubectl cluster-info &>/dev/null; then
    # Running locally - need port-forward
    GITLAB_URL="http://root:${GITLAB_PAT}@${GITLAB_HOST}:${GITLAB_PORT}/${GITLAB_USER}/${GITLAB_PROJECT_NAME}.git"
    
    # Check if port-forward is active
    if ! nc -z localhost 8181 2>/dev/null; then
        echo "Error: GitLab port-forward not active!"
        echo "Run in another terminal: kubectl -n gitlab port-forward svc/gitlab-webservice-default 8181:8181"
        exit 1
    fi
else
    # Running inside cluster
    GITLAB_URL="http://root:${GITLAB_PAT}@${GITLAB_INTERNAL_HOST}:${GITLAB_PORT}/${GITLAB_USER}/${GITLAB_PROJECT_NAME}.git"
fi

# Clone or update repository
if [ -d "$CLONE_DIR" ]; then
    echo "Repository already exists, pulling latest changes..."
    cd "$CLONE_DIR"
    git pull
else
    echo "Cloning repository..."
    git clone "$GITLAB_URL" "$CLONE_DIR"
    cd "$CLONE_DIR"
fi

# Configure git
git config user.email "admin@local"
git config user.name "Admin"

# Update deployment file to switch version
if [ -f "deployment/deployment.yaml" ]; then
    echo "Updating deployment to version $VERSION..."
    
    # Replace image tag (assuming format: image: wil42/playground:v1 or v2)
    sed -i "s|image: wil42/playground:v[12]|image: wil42/playground:${VERSION}|g" deployment/deployment.yaml
    
    # Commit and push
    git add deployment/deployment.yaml
    git commit -m "Switch to version ${VERSION}" || echo "No changes to commit"
    git push "$GITLAB_URL" main
    
    echo "Version switched to $VERSION successfully!"
    echo "ArgoCD will automatically sync the changes."
else
    echo "Error: deployment/deployment.yaml not found"
    exit 1
fi
