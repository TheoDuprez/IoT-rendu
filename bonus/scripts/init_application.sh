# Register glab
personal_access_tokens=$(kubectl exec -it deployment/gitlab-toolbox -n gitlab -- gitlab-rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api, :read_user, :read_api, :read_repository, :write_repository], name: 'glab-cli-token', expires_at: 365.days.from_now); print token.token")
glab auth login --hostname gitlab.local --api-protocol http --token $personal_access_tokens
glab config set --global host gitlab.local
glab config set skip_tls_verify true

# Create playground repo
yes | glab repo create playground_application --public
git -C playground_application remote set-url origin "http://gitlab.local/root/playground_application.git"
git -C playground_application add .
git -C playground_application commit -m "Initial commit"
git -C playground_application push --set-upstream origin master

kubectl apply -f ./confs/ingress.yaml
kubectl apply -f ./playground_application/application.yaml