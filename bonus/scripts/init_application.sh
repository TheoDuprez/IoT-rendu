# Register glab
personal_access_tokens=$(kubectl exec -it deployment/gitlab-toolbox -n gitlab -- gitlab-rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: [:api, :read_user, :read_api, :read_repository, :write_repository], name: 'glab-cli-token', expires_at: 365.days.from_now); print token.token")
glab auth login --hostname gitlab.local --api-protocol http --token $personal_access_tokens
glab config set --global host gitlab.local
glab config set skip_tls_verify true

# Create playground repo
yes | glab repo create playground_application
git -C playground_application remote set-url origin "http://gitlab.local/root/playground_application.git"
git -C playground_application add .
git -C playground_application commit -m "Initial commit"
git -C playground_application push --set-upstream origin master

# Port forward argocd
# nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

gitlab_project_access_token=$(glab token create -R root/playground_application argocd-token --access-level reporter --duration 2w)
argocd_admin_password=$(argocd admin initial-password -n argocd | head -n 1)
giltab_root_password=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode)

kubectl apply -f ./confs/ingress.yaml

# argocd login localhost:8080 --insecure --username admin --password $argocd_admin_password
argocd login argocd.local --insecure --username admin --password $argocd_admin_password --grpc-web
argocd repo add http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/root/playground_application.git --username root --password $gitlab_project_access_token --insecure-skip-server-verification --grpc-web
kubectl apply -f ./playground_application/application.yaml

echo "----------------------------------------------------"
echo "ArgoCD admin password: $argocd_admin_password"
echo "Gitlab root password: $giltab_root_password"