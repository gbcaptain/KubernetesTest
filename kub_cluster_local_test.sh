##################
# Enviroment Set #
##################

/etc/hosts
10.1.1.10       k8s-master
10.1.1.11       k8s-node

# Create Working Folder
cd ~/
mkdir k8s
cd k8s/

#######################
### Install kubectl ###
#######################
wget https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

#############################################
### Install the tools CFSSL and CFSSLJSON ###
############################################# 
$ sudo curl -s -L -o /bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
$ sudo curl -s -L -o /bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
$ sudo curl -s -L -o /bin/cfssl-certinfo https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
$ sudo chmod +x /bin/cfssl*

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
WORKER0_HOST=k8s-node
WORKER0_IP=10.1.1.11

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
CERT_HOSTNAME=10.1.1.10,127.0.0.1,localhost,kubernetes.default

CERT_HOSTNAME=10.1.1.10,k8s-master,10.1.1.11,k8s-node,127.0.0.1,localhost,kubernetes.default

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

scp ca.pem k8s-node-key.pem k8s-node.pem bguan@k8s-node:~/

## Move certificate files to the controller nodes
scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem user@<controller 1 public IP>:~/

scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem bguan@k8s-node:~/

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
