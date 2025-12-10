#!/bin/bash

GITLAB_URL="http://localhost:8082"
GITLAB_PROJECT_NAME="tgellon_iot_willapp"
USERNAME="root"

# Clone the GitHub repository
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR
git clone https://github.com/tang1304/tgellon_IoT_willApp.git
cd tgellon_IoT_willApp

echo $'\nCreating GitLab personal access token...'

echo $'\nRunning GitLab Rails command...\n'
GITLAB_TOKEN=$(kubectl exec -n gitlab deployment/gitlab-toolbox -- \
  gitlab-rails runner "
    user = User.find_by_username('root')
    
    # Remove old token if exists
    old_token = user.personal_access_tokens.find_by(name: 'automation-token')
    old_token.revoke! if old_token
    
    # Create new token
    token = user.personal_access_tokens.create!(
      name: 'automation-token',
      scopes: [:api, :read_repository, :write_repository],
      expires_at: 30.days.from_now
    )
    
    STDOUT.puts \"TOKEN:#{token.token}\"
  " 2>&1 | grep 'TOKEN:' | cut -d':' -f2 | tr -d '\n\r ')

# Create a new project in GitLab
echo "Creating new GitLab project: $GITLAB_PROJECT_NAME..."
PROJECT_RESPONSE=$(curl -s -X POST "$GITLAB_URL/api/v4/projects" \
  --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  --form "name=$GITLAB_PROJECT_NAME" \
  --form "visibility=public")

PROJECT=$(echo "$PROJECT_RESPONSE" | jq -r '.web_url // empty')

# Configure git and push to GitLab
git remote rename origin github
# Use the token as both username and password for GitLab authentication
git remote add gitlab "http://oauth2:${GITLAB_TOKEN}@localhost:8082/root/${GITLAB_PROJECT_NAME}.git"

git config --global credential.helper store

echo $'\nPushing repository to GitLab...\n'
git push -u gitlab --all # -u to set upstream

echo $'\nRepository successfully uploaded to GitLab!\n'
echo "GitLab project URL: $GITLAB_URL/root/$GITLAB_PROJECT_NAME"

# Add GitLab repository to ArgoCD
echo $'\nAdding GitLab repository to ArgoCD...'
GITLAB_INTERNAL_URL="http://gitlab-webservice-default.gitlab.svc.cluster.local:8181"
REPO_URL="${GITLAB_INTERNAL_URL}/root/${GITLAB_PROJECT_NAME}.git"

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Login to ArgoCD and add repository
kubectl exec -n argocd deployment/argocd-server -- bash -c "
  argocd login argocd-server.argocd.svc.cluster.local:443 \
    --username admin \
    --password '$ARGOCD_PASSWORD' \
    --insecure && \
  argocd repo add '$REPO_URL' \
    --username root \
    --password '$GITLAB_TOKEN' \
    --insecure-skip-server-verification \
    --upsert
"

echo $'\nRepository configured successfully!'

# Clean up
cd -
rm -rf $TEMP_DIR