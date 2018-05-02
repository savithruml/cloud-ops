CONTAINER=$(docker ps | grep -i kube-man | cut -d " " -f1 | head -1)
docker restart "$CONTAINER"
ssh root@${MinionIPv4Address} iptables -I INPUT 4 -j ACCEPT
oadm policy add-cluster-role-to-user cluster-admin admin
htpasswd -bc /etc/origin/master/htpasswd admin contrail123
