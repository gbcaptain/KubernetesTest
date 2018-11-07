###########################################################
### Provisioning the CA and Generating TLS Certificates ###
###########################################################
### Cert Auth###

{

cat > ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json << EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}


### generate Client Cert ###
###Admin Auth###
{

cat > admin-csr.json << EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

}

### Kube Client Cert ###
WORKER0_HOST=gbcaptain3.mylabserver.com
WORKER0_IP=172.31.19.31
WORKER1_HOST=gbcaptain4.mylabserver.com
WORKER1_IP=172.31.103.225

{
cat > ${WORKER0_HOST}-csr.json << EOF
{
  "CN": "system:node:${WORKER0_HOST}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WORKER0_IP},${WORKER0_HOST} \
  -profile=kubernetes \
  ${WORKER0_HOST}-csr.json | cfssljson -bare ${WORKER0_HOST}

cat > ${WORKER1_HOST}-csr.json << EOF
{
  "CN": "system:node:${WORKER1_HOST}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WORKER1_IP},${WORKER1_HOST} \
  -profile=kubernetes \
  ${WORKER1_HOST}-csr.json | cfssljson -bare ${WORKER1_HOST}

}

### Controller Manager Client cert ###
{

cat > kube-controller-manager-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

}

### Kube Proxy Client cert ###
{

cat > kube-proxy-csr.json << EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

}

### Kube Scheduler Client Cert ###
{

cat > kube-scheduler-csr.json << EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

}


### generate API Server Cert ###
CERT_HOSTNAME=10.32.0.1,<controller node 1 Private IP>,<controller node 1 hostname>,<controller node 2 Private IP>,<controller node 2 hostname>,<API load balancer Private IP>,<API load balancer hostname>,127.0.0.1,localhost,kubernetes.default

CERT_HOSTNAME=10.32.0.1,172.31.28.61,gbcaptain1.mylabserver.com,172.31.97.252,gbcaptain2.mylabserver.com,172.31.106.201,gbcaptain6.mylabserver.com,127.0.0.1,localhost,kubernetes.default

{

cat > kubernetes-csr.json << EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${CERT_HOSTNAME} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}


### generate Serv Acc Key Pair ###
{

cat > service-account-csr.json << EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CA",
      "L": "Toronto",
      "O": "system:masters",
      "OU": "Kubernetes Testbed",
      "ST": "Ontario"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

}


### Distribute Cert file ###
## Move certificate files to the worker nodes
scp ca.pem <worker 1 hostname>-key.pem <worker 1 hostname>.pem user@<worker 1 public IP>:~/
scp ca.pem <worker 2 hostname>-key.pem <worker 2 hostname>.pem user@<worker 2 public IP>:~/

scp ca.pem gbcaptain3.mylabserver.com-key.pem gbcaptain3.mylabserver.com.pem user@54.200.230.57:~/
scp ca.pem gbcaptain4.mylabserver.com-key.pem gbcaptain4.mylabserver.com.pem user@18.237.40.184:~/


## Move certificate files to the controller nodes
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem user@<controller 1 public IP>:~/
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem user@<controller 2 public IP>:~/

scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem user@52.38.161.17:~/
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem user@18.237.189.190:~/

##################################
### Generate kube config file ###
##################################
KUBERNETES_ADDRESS=<load balancer private ip>

KUBERNETES_ADDRESS=172.31.106.201

## Generate a kubelet kubeconfig for each worker node
for instance in gbcaptain3.mylabserver.com gbcaptain4.mylabserver.com; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

## Generate a kube-proxy kubeconfig
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

## Generate a kube-controller-manager kubeconfig:
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}

## Generate a kube-scheduler kubeconfig
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}


## Generate an admin kubeconfig
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}


### Distribute kubeConfig file ###
## Move kubeconfig files to the worker nodes:
scp <worker 1 hostname>.kubeconfig kube-proxy.kubeconfig user@<worker 1 public IP>:~/
scp <worker 2 hostname>.kubeconfig kube-proxy.kubeconfig user@<worker 2 public IP>:~/

scp gbcaptain3.mylabserver.com.kubeconfig kube-proxy.kubeconfig user@54.200.230.57:~/
scp gbcaptain4.mylabserver.com.kubeconfig kube-proxy.kubeconfig user@18.237.40.184:~/


## Move kubeconfig files to the controller nodes:
scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig user@<controller 1 public IP>:~/
scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig user@<controller 2 public IP>:~/

scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig user@52.38.161.17:~/
scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig user@18.237.189.190:~/

#############################################
### Generating the Data Encryption Config ###
#############################################
ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > encryption-config.yaml << EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

## Copy the file to both controller servers:
scp encryption-config.yaml user@52.38.161.17:~/
scp encryption-config.yaml user@18.237.189.190:~/


#################################
### Creating the etcd Cluster ###
#################################
## Controller
wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v3.3.5/etcd-v3.3.5-linux-amd64.tar.gz"
tar -xvf etcd-v3.3.5-linux-amd64.tar.gz
sudo mv etcd-v3.3.5-linux-amd64/etcd* /usr/local/bin/
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

## Set up the following environment variables. Be sure you replace all of the <placeholder values> with their corresponding real values:
ETCD_NAME=<cloud server hostname>
INTERNAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
INITIAL_CLUSTER=<controller 1 hostname>=https://<controller 1 private ip>:2380,<controller 2 hostname>=https://<controller 2 private ip>:2380

ETCD_NAME=gbcaptain1.mylabserver.com
INTERNAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
INITIAL_CLUSTER=gbcaptain1.mylabserver.com=https://172.31.28.61:2380,gbcaptain2.mylabserver.com=https://172.31.97.252:2380

ETCD_NAME=gbcaptain2.mylabserver.com
INTERNAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
INITIAL_CLUSTER=gbcaptain1.mylabserver.com=https://172.31.28.61:2380,gbcaptain2.mylabserver.com=https://172.31.97.252:2380

## Create the systemd unit file for etcd using this command.
cat << EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${INITIAL_CLUSTER} \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

## Start and enable the etcd service:
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

## You can verify that the etcd service started up successfully like so:
sudo systemctl status etcd

## Use this command to verify that etcd is working correctly. The output should list your two etcd nodes:
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem


##################################################
### Bootstrapping the Kubernetes Control Plane ###
##################################################
## Installing Kubernetes Control Plane Binaries
sudo mkdir -p /etc/kubernetes/config

wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl"

chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl

sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

## Setting up the Kubernetes API Server
# configure the Kubernetes API server like so:
sudo mkdir -p /var/lib/kubernetes/

sudo cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
  service-account-key.pem service-account.pem \
  encryption-config.yaml /var/lib/kubernetes/

# Set some environment variables that will be used to create the systemd unit file. Make sure you replace the placeholders with their actual values:
INTERNAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
CONTROLLER0_IP=<private ip of controller 0>
CONTROLLER1_IP=<private ip of controller 1>

CONTROLLER0_IP=172.31.28.61
CONTROLLER1_IP=172.31.97.252

# Generate the kube-apiserver unit file for systemd:
cat << EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=Initializers,NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --enable-swagger-ui=true \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://$CONTROLLER0_IP:2379,https://$CONTROLLER1_IP:2379 \\
  --event-ttl=1h \\
  --experimental-encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2 \\
  --kubelet-preferred-address-types=InternalIP,InternalDNS,Hostname,ExternalIP,ExternalDNS
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

## Setting up the Kubernetes Controller Manager
# configure the Kubernetes Controller Manager like so:
sudo cp kube-controller-manager.kubeconfig /var/lib/kubernetes/

# Generate the kube-controller-manager systemd unit file:
cat << EOF | sudo tee /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

## Setting up the Kubernetes Scheduler
# Copy kube-scheduler.kubeconfig into the proper location:
sudo cp kube-scheduler.kubeconfig /var/lib/kubernetes/

# Generate the kube-scheduler yaml config file.
cat << EOF | sudo tee /etc/kubernetes/config/kube-scheduler.yaml
apiVersion: componentconfig/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF

# Create the kube-scheduler systemd unit file:
cat << EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start and enable all of the services:
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler
sudo systemctl start kube-apiserver kube-controller-manager kube-scheduler

# verify that everything is working correctly so far: Make sure all the services are active (running):
sudo systemctl status kube-apiserver kube-controller-manager kube-scheduler

# Use kubectl to check componentstatuses:
kubectl get componentstatuses --kubeconfig admin.kubeconfig


## Enable HTTP Health Checks
# set up a basic nginx proxy for the healthz endpoint by first installing nginx"
sudo apt-get install -y nginx

# Create an nginx configuration for the health check proxy:
cat > kubernetes.default.svc.cluster.local << EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF

# Set up the proxy configuration so that it is loaded by nginx:
sudo mv kubernetes.default.svc.cluster.local /etc/nginx/sites-available/kubernetes.default.svc.cluster.local
sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/
sudo systemctl restart nginx
sudo systemctl enable nginx

# You can verify that everything is working like so:
curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz


## Set up RBAC (Role-Based Access Control) for Kubelet Authorization
# Create a role with the necessary permissions:
cat << EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF

# Bind the role to the kubernetes user:
cat << EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF


## Setting up a Kube API Frontend Load Balancer
# set up the nginx load balancer. Run these on the server that you have designated as your load balancer server:
sudo apt-get install -y nginx
sudo systemctl enable nginx
sudo mkdir -p /etc/nginx/tcpconf.d
sudo vi /etc/nginx/nginx.conf

# Add the following to the end of nginx.conf:
include /etc/nginx/tcpconf.d/*;

# Set up some environment variables for the lead balancer config file:
CONTROLLER0_IP=<controller 0 private ip>
CONTROLLER1_IP=<controller 1 private ip>

CONTROLLER0_IP=172.31.28.61
CONTROLLER1_IP=172.31.97.252

# Create the load balancer nginx config file:
cat << EOF | sudo tee /etc/nginx/tcpconf.d/kubernetes.conf
stream {
    upstream kubernetes {
        server $CONTROLLER0_IP:6443;
        server $CONTROLLER1_IP:6443;
    }

    server {
        listen 6443;
        listen 443;
        proxy_pass kubernetes;
    }
}
EOF

# Reload the nginx configuration:
sudo nginx -s reload

# You can verify that the load balancer is working like so:
curl -k https://localhost:6443/version


#################################################
### Bootstrapping the Kubernetes Worker Nodes ###
#################################################
## Installing Worker Node Binaries
# install the worker binaries like so. Run these commands on both worker nodes:
sudo apt-get -y install socat conntrack ipset

wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-incubator/cri-tools/releases/download/v1.0.0-beta.0/crictl-v1.0.0-beta.0-linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-the-hard-way/runsc \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc5/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz \
  https://github.com/containerd/containerd/releases/download/v1.1.0/containerd-1.1.0.linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubelet

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

chmod +x kubectl kube-proxy kubelet runc.amd64 runsc
sudo mv runc.amd64 runc
sudo mv kubectl kube-proxy kubelet runc runsc /usr/local/bin/
sudo tar -xvf crictl-v1.0.0-beta.0-linux-amd64.tar.gz -C /usr/local/bin/
sudo tar -xvf cni-plugins-amd64-v0.6.0.tgz -C /opt/cni/bin/
sudo tar -xvf containerd-1.1.0.linux-amd64.tar.gz -C /

##  Configuring Containerd
# configure the containerd service like so. Run these commands on both worker nodes:
sudo mkdir -p /etc/containerd/

# Create the containerd config.taml:
cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = "overlayfs"
    [plugins.cri.containerd.default_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runc"
      runtime_root = ""
    [plugins.cri.containerd.untrusted_workload_runtime]
      runtime_type = "io.containerd.runtime.v1.linux"
      runtime_engine = "/usr/local/bin/runsc"
      runtime_root = "/run/containerd/runsc"
EOF

# Create the containerd unit file:
cat << EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

## Configuring Kubelet
# Set a HOSTNAME environment variable that will be used to generate your config files. Make sure you set the HOSTNAME appropriately for each worker node:
HOSTNAME=$(hostname)
sudo mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem /var/lib/kubelet/
sudo mv ${HOSTNAME}.kubeconfig /var/lib/kubelet/kubeconfig
sudo mv ca.pem /var/lib/kubernetes/

# Create the kubelet config file:
cat << EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS: 
  - "10.32.0.10"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF

# Create the kubelet unit file:
cat << EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2 \\
  --hostname-override=${HOSTNAME} \\
  --allow-privileged=true
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

## Configuring Kube-Proxy
# configure the kube-proxy service like so. Run these commands on both worker nodes:
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig

# Create the kube-proxy config file:
cat << EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "10.200.0.0/16"
EOF

# Create the kube-proxy unit file:
cat << EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Now you are ready to start up the worker node services! Run these:
sudo systemctl daemon-reload
sudo systemctl enable containerd kubelet kube-proxy
sudo systemctl start containerd kubelet kube-proxy

# Check the status of each service to make sure they are all active (running) on both worker nodes:
sudo systemctl status containerd kubelet kube-proxy

# Finally, verify that both workers have registered themselves with the cluster. Log in to one of your control nodes and run this:
kubectl get nodes

#############################################
### Configuring kubectl for Remote Access ###
#############################################
# open up an ssh tunnel to port 6443 on your Kubernetes API load balancer:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

ssh -L 6443:localhost:6443 user@34.219.96.107

# You can configure your local kubectl in your main shell like so. Set KUBERNETES_PUBLIC_ADDRESS to the public IP of your load balancer.
cd ~/kthw

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://localhost:6443

kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem

kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin

kubectl config use-context kubernetes-the-hard-way

# Verify that everything is working with:
kubectl get pods
kubectl get nodes
kubectl version

##################
### Networking ###
##################
## Installing Weave Net
# First, log in to both worker nodes and enable IP forwarding:
sudo sysctl net.ipv4.conf.all.forwarding=1
echo "net.ipv4.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf

# The remaining commands can be done using kubectl. To connect with kubectl, you can either log in to one of the control nodes and run kubectl there or open an SSH tunnel for port 6443 to the load balancer server and use kubectl locally.
# You can open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

ssh -L 6443:localhost:6443 user@34.219.96.107

# Install Weave Net like this:
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.200.0.0/16"

# Now Weave Net is installed, but we need to test our network to make sure everything is working.
# First, make sure the Weave Net pods are up and running:
kubectl get pods -n kube-system

# Next, we want to test that pods can connect to each other and that they can connect to services. We will set up two Nginx pods and a service for those two pods. Then, we will create a busybox pod and use it to test connectivity to both Nginx pods and the service.
# First, create an Nginx deployment with 2 replicas:
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      run: nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF

# Next, create a service for that deployment so that we can test connectivity to services as well:
kubectl expose deployment/nginx

# Now let's start up another pod. We will use this pod to test our networking. We will test whether we can connect to the other pods and services from this pod.
kubectl run busybox --image=radial/busyboxplus:curl --command -- sleep 3600
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

#Now let's get the IP addresses of our two Nginx pods:
kubectl get ep nginx

# Now let's make sure the busybox pod can connect to the Nginx pods on both of those IP addresses.
kubectl exec $POD_NAME -- curl <first nginx pod IP address>
kubectl exec $POD_NAME -- curl <second nginx pod IP address>


# Now let's verify that we can connect to services.
kubectl get svc

# Let's see if we can access the service from the busybox pod!
kubectl exec $POD_NAME -- curl <nginx service IP address>

## Cleanup
# open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# You can clean up the testing objects from the previous lesson like so:
kubectl delete deployment busybox
kubectl delete deployment nginx
kubectl delete svc nginx


########################################
### Deploying the DNS Cluster Add-on ###
########################################
## Deploying Kube-dns to the Cluster
# open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# You can install kube-dns like so:
kubectl create -f https://storage.googleapis.com/kubernetes-the-hard-way/kube-dns.yaml

# Verify that the kube-dns pod starts up correctly:
kubectl get pods -l k8s-app=kube-dns -n kube-system

# Now let's test our kube-dns installation by doing a DNS lookup from within a pod. First, we need to start up a pod that we can use for testing:
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")

# Next, run an nslookup from inside the busybox container:
kubectl exec -ti $POD_NAME -- nslookup kubernetes

# Once you are done, it's probably a good idea to clean up the the objects that were created for testing:
kubectl delete deployment busybox


##################
### Smoke Test ###
##################
## Smoke Testing Data Encryption
# open an SSH tunnel. You can open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# Create a test secret:
kubectl create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"

# Log in to one of your controller servers, and get the raw data for the test secret from etcd:
sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C


## Smoke Testing Deployments
# open an SSH tunnel. You can open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# Create a a simple nginx deployment:
kubectl run nginx --image=nginx

# Verify that the deployment created a pod and that the pod is running:
kubectl get pods -l run=nginx


## Smoke Testing Port Forwarding
# open an SSH tunnel. You can open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# First, get the pod name of the nginx pod and store it an an environment variable:
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")

# Forward port 8081 to the nginx pod:
kubectl port-forward $POD_NAME 8081:80

# Open up a new terminal, log in to the controller server, and verify that the port forward works:
curl --head http://127.0.0.1:8081


## Smoke Testing Logs
# open an SSH tunnel. You can open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# First, let's set an environment variable to the name of the nginx pod:
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")

# Get the logs from the nginx pod:
kubectl logs $POD_NAME

## Smoke Testing Exec
# open an SSH tunnel. You can open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# First, let's set an environment variable to the name of the nginx pod:
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")

# To test kubectl exec, execute a simple nginx -v command inside the nginx pod:
kubectl exec -ti $POD_NAME -- nginx -v

## Smoke Testing Services
# open the SSH tunnel by running this in a separate terminal. Leave the session open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# First, create a service to expose the nginx deployment:
kubectl expose deployment nginx --port 80 --type NodePort

# Get the node port assigned to the newly-created service and assign it to an environment variable:
kubectl get svc

# Next, log in to one of your worker servers and make a request to the service using the node port. Be sure to replace the placeholder with the actual node port:
curl -I localhost:<node port>

##  Smoke Testing Untrusted Workloads
# open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# First, create an untrusted pod:
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: untrusted
  annotations:
    io.kubernetes.cri.untrusted-workload: "true"
spec:
  containers:
    - name: webserver
      image: gcr.io/hightowerlabs/helloworld:2.0.0
EOF

# Make sure that the untrusted pod is running:
kubectl get pods untrusted -o wide

# Take note of which worker node the untrusted pod is running on, then log into that worker node.
# On the worker node, list all of the containers running under gVisor:
sudo runsc --root  /run/containerd/runsc/k8s.io list

# Get the pod ID of the untrusted pod and store it in an environment variable:
POD_ID=$(sudo crictl -r unix:///var/run/containerd/containerd.sock \
  pods --name untrusted -q)

# Get the container ID of the container running in the untrusted pod and store it in an environment variable:
CONTAINER_ID=$(sudo crictl -r unix:///var/run/containerd/containerd.sock \
  ps -p ${POD_ID} -q)

# Get information about the process running in the container:
sudo runsc --root /run/containerd/runsc/k8s.io ps ${CONTAINER_ID}

## Smoke Testing Cleanup
# open while you are working to keep the tunnel active:
ssh -L 6443:localhost:6443 user@<your Load balancer cloud server public IP>

# You can clean up the objects that were created for smoke testing purposes like so:
kubectl delete secret kubernetes-the-hard-way
kubectl delete svc nginx
kubectl delete deployment nginx
kubectl delete pod untrusted
