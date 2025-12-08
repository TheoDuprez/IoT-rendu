#!/bin/bash

set -e

### Configuration ###
GITLAB_NAMESPACE="gitlab"
GITLAB_USER="root"
TOKEN_NAME="api-token-$(date +%s)"
TOKEN_SCOPES="api"
TOKEN_EXPIRY_DAYS=30

echo "Creating GitLab Personal Access Token..."

# Find GitLab pod (toolbox or webservice)
TOOLBOX_POD=$(kubectl get pods -n "$GITLAB_NAMESPACE" -l app=toolbox -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$TOOLBOX_POD" ]; then
    TOOLBOX_POD=$(kubectl get pods -n "$GITLAB_NAMESPACE" -l app=webservice -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
fi

if [ -z "$TOOLBOX_POD" ]; then
    echo "Error: No suitable GitLab pod found"
    exit 1
fi

echo "Using pod: ${TOOLBOX_POD}"

# Create PAT via Rails Console
RAILS_COMMAND="
user = User.find_by_username('${GITLAB_USER}')
token = user.personal_access_tokens.create(
  name: '${TOKEN_NAME}',
  scopes: ['${TOKEN_SCOPES}'],
  expires_at: ${TOKEN_EXPIRY_DAYS}.days.from_now
)
if token.persisted?
  puts 'SUCCESS'
  puts token.token
else
  puts 'ERROR'
end
"

OUTPUT=$(kubectl exec -n "$GITLAB_NAMESPACE" "$TOOLBOX_POD" -- gitlab-rails runner "$RAILS_COMMAND" 2>&1)

if echo "$OUTPUT" | grep -q "SUCCESS"; then
    GITLAB_PAT=$(echo "$OUTPUT" | grep -A 1 "SUCCESS" | tail -n 1 | tr -d '[:space:]')
    
    echo "Personal Access Token created successfully!"
    echo "Token: ${GITLAB_PAT}"
    echo ""
    
    # Save to file
    echo "$GITLAB_PAT" > /tmp/gitlab_pat.txt
    echo "Token saved to: /tmp/gitlab_pat.txt"
else
    echo "Failed to create Personal Access Token"
    echo "$OUTPUT"
    exit 1
fi
