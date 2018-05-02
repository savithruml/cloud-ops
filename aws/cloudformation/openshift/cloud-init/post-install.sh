CONTAINER=$(docker ps | grep -i kube-man | cut -d " " -f1 | head -1)
docker restart "$CONTAINER"
