# THREE TIER APP

## OpenStack

### TIER-1

Database (MYSQL)

    docker run -itd --name database --net=host -e MYSQL_ROOT_PASSWORD=secret -e MYSQL_DATABASE=redmine savvythru/three-tier-database

### TIER-2

Web (REDMINE)

    docker run -itd --name web --net=host -e REDMINE_DB_MYSQL=<database-tier-ip-address> -e REDMINE_DB_PASSWORD=secret savvythru/three-tier-frontend

### TIER-3

Proxy (NGINX)

    docker run -itd --name proxy --net=host -e REDMINE_SVC=<web-tier-ip-address> -e REDMINE_SVC_PORT=3000 savvythru/three-tier-proxy
    
    
## Kubernetes/OpenShift

### TIER-1

Database (MYSQL)

    kubectl/oc create -f https://raw.githubusercontent.com/savithruml/cloud-ops/master/aws/examples/three-tier-app/database-tier.yaml

### TIER-2

Web (REDMINE)

    kubectl/oc create -f https://raw.githubusercontent.com/savithruml/cloud-ops/master/aws/examples/three-tier-app/frontend-tier.yaml

### TIER-3

Proxy (NGINX)

    kubectl/oc create -f https://raw.githubusercontent.com/savithruml/cloud-ops/master/aws/examples/three-tier-app/proxy-tier.yaml


## TEST

* **OPTION1:** Login to the Proxy VM/container & issue a `curl/wget (HTTP /GET)` request to `localhost:9090`

* **OPTION2:** Attach a Floating-IP to proxy virtual-machine-interface & enter the `http://<floating-IP-address>:9090` in the web-browser
