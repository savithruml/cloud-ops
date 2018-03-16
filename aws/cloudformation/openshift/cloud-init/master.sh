cat > run.sh <<EOF
subscription-manager register --username $username --password $password --force
subscription-manager attach --pool=$poolID
yum update -y
yum install wget git vim python-netaddr -y
subscription-manager repos --disable="*"
subscription-manager repos \
                --enable="rhel-7-server-rpms" \
                --enable="rhel-7-server-extras-rpms" \
                --enable="rhel-7-server-ose-3.7-rpms" \
                --enable="rhel-7-fast-datapath-rpms"

wget -O /tmp/epel-release-latest-7.noarch.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && rpm -ivh /tmp/epel-release-latest-7.noarch.rpm
yum update -y
yum install atomic-openshift-excluder atomic-openshift-utils git -y
atomic-openshift-excluder unexclude -y
EOF

chmod +x run.sh
./run.sh
