#!/bin/bash

set -e

### Colors ###
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

### Configuration ###
GITLAB_NAMESPACE="gitlab"
GITLAB_HOST="gitlab.local"
GITLAB_PROTOCOL="https"
GITLAB_USER="root"
GITHUB_REPO_URL="https://github.com/lciullo/iot_lciullo"
GITLAB_PROJECT_NAME="iot_lciullo"
TEMP_CLONE_DIR="/tmp/iot_lciullo_mirror"

echo -e "${BLUE}=== GitHub to GitLab Import Script ===${NC}"
echo ""

# Check if cluster is running
echo -e "${BLUE}Checking if K3D cluster is running...${NC}"
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo -e "${RED}✗ Cluster is not running. Please run setup_cluster.sh first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Cluster is running${NC}"

# Check if GitLab is installed
echo -e "${BLUE}Checking if GitLab is installed...${NC}"
if ! kubectl get namespace "$GITLAB_NAMESPACE" >/dev/null 2>&1; then
    echo -e "${RED}✗ GitLab namespace not found. Please run install_gitlab.sh first.${NC}"
    exit 1
fi

if ! kubectl get pod -n "$GITLAB_NAMESPACE" -l app=webservice >/dev/null 2>&1; then
    echo -e "${RED}✗ GitLab webservice not running. Please ensure GitLab installation is complete.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GitLab is installed${NC}"

# Get GitLab root password
echo -e "${BLUE}Retrieving GitLab root password...${NC}"
GITLAB_PASSWORD=$(kubectl get secret -n "$GITLAB_NAMESPACE" gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode 2>/dev/null)
if [ -z "$GITLAB_PASSWORD" ]; then
    echo -e "${RED}✗ Could not retrieve GitLab password${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Password retrieved${NC}"

# Create temporary directory for cloning
echo -e "${BLUE}Setting up temporary clone directory...${NC}"
rm -rf "$TEMP_CLONE_DIR"
mkdir -p "$TEMP_CLONE_DIR"
cd "$TEMP_CLONE_DIR"
echo -e "${GREEN}✓ Temporary directory ready${NC}"

# Clone the GitHub repository as a mirror
echo -e "${BLUE}Cloning GitHub repository (this may take a moment)...${NC}"
git clone --mirror "$GITHUB_REPO_URL" iot_lciullo.git
if [ ! -d "iot_lciullo.git" ]; then
    echo -e "${RED}✗ Failed to clone GitHub repository${NC}"
    exit 1
fi
echo -e "${GREEN}✓ GitHub repository cloned${NC}"

# Configure git to disable SSL verification
export GIT_SSL_NO_VERIFY=1
export GIT_TERMINAL_PROMPT=0

echo -e "${BLUE}Preparing to push to GitLab...${NC}"

# We'll just use the default path
GITLAB_PATH="${GITLAB_USER}/${GITLAB_PROJECT_NAME}"

cd "iot_lciullo.git"

# Build the push URL
GITLAB_PUSH_URL="${GITLAB_PROTOCOL}://${GITLAB_USER}:${GITLAB_PASSWORD}@${GITLAB_HOST}/${GITLAB_PATH}.git"

# Attempt to push
echo -e "${BLUE}Pushing repository to GitLab...${NC}"

if git push --mirror "$GITLAB_PUSH_URL" 2>&1; then
    echo -e "${GREEN}✓ Repository pushed to GitLab successfully${NC}"
else
    PUSH_STATUS=$?
    echo -e "${YELLOW}⚠ Push encountered an error (code: $PUSH_STATUS)${NC}"
    echo -e "${YELLOW}This may be due to authentication or project not existing.${NC}"
    echo ""
    echo -e "${YELLOW}Manual push URL (for reference):${NC}"
    echo -e "${YELLOW}  ${GITLAB_PUSH_URL}${NC}"
fi

# Cleanup
echo -e "${BLUE}Cleaning up...${NC}"
cd /
rm -rf "$TEMP_CLONE_DIR"
echo -e "${GREEN}✓ Cleanup complete${NC}"

# Display summary
echo ""
echo -e "${GREEN}=== Import Summary ===${NC}"
echo -e "${YELLOW}GitHub Repository:${NC} ${GITHUB_REPO_URL}"
echo -e "${YELLOW}GitLab Project:${NC} ${GITLAB_PROTOCOL}://${GITLAB_HOST}/${GITLAB_PATH}"
echo ""
echo -e "${GREEN}✓ Script completed!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Access GitLab at: ${GITLAB_PROTOCOL}://${GITLAB_HOST}"
echo "2. Username: ${GITLAB_USER}"
echo "3. Create a private project named '${GITLAB_PROJECT_NAME}' if not done"
echo "4. Run this script again to push the repository"
echo ""
echo "To clone the GitLab repository:"
echo "  git clone ${GITLAB_PROTOCOL}://${GITLAB_HOST}/${GITLAB_PATH}.git"
echo ""
