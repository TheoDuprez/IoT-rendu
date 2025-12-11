sed -i 's/wil42\/playground\:v2/wil42\/playground\:v1/g' playground_application/deployment/deployment.yaml
git -C playground_application add .
git -C playground_application commit -m "Downgrade playground to v2"
git -C playground_application push