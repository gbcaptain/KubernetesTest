[Reference Source](https://www.qikqiak.com/post/manual-install-high-available-kubernetes-cluster/ "手动搭建高可用的kubernetes 集群")

# 1. 组件版本 && 集群环境
## 组件版本
  - Kubernetes 1.8.2(1.9.x版本也可以，只有细微的差别)
  - Docker 17.10.0-ce
  - Etcd 3.2.9
  - Flanneld
  - TLS 认证通信（所有组件，如etcd、kubernetes master 和node）
  - RBAC 授权
  - kubelet TLS Bootstrapping
  - kubedns、dashboard、heapster等插件
  - harbor，使用nfs后端存储

## etcd 集群 && k8s master 机器 && k8s node 机器
  - k8s-master: 10.1.1.10
  - k8s-node: 10.1.1.11

## 集群环境变量
后面的嗯部署将会使用到的全局变量，定义如下（根据自己的机器、网络修改）：

> #TLS Bootstrapping 使用的Token，可以使用命令 head -c 16 /dev/urandom | od -An -t x | tr -d ' ' 生成
> > BOOTSTRAP_TOKEN="8981b594122ebed7596f1d3b69c78223"
>  
> #建议使用未用的网段来定义服务网段和Pod 网段
> #服务网段(Service CIDR)，部署前路由不可达，部署后集群内部使用IP:Port可达
> > SERVICE_CIDR="10.254.0.0/16"
> #Pod 网段(Cluster CIDR)，部署前路由不可达，部署后路由可达(flanneld 保证)
> > CLUSTER_CIDR="172.30.0.0/16"
> 
> #服务端口范围(NodePort Range)
> > NODE_PORT_RANGE="30000-32766"
> 
> #etcd集群服务地址列表
> > ETCD_ENDPOINTS="https://10.1.1.10:2379"
> 
> #flanneld 网络配置前缀
> > FLANNEL_ETCD_PREFIX="/kubernetes/network"
> 
> #kubernetes 服务IP(预先分配，一般为SERVICE_CIDR中的第一个IP)
> > CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"
> 
> #集群 DNS 服务IP(从SERVICE_CIDR 中预先分配)
> > CLUSTER_DNS_SVC_IP="10.254.0.2"
> 
> #集群 DNS 域名
> > CLUSTER_DNS_DOMAIN="cluster.local."
> 
> #MASTER API Server 地址
> > MASTER_URL="k8s-api.virtual.local"

将上面变量保存为: env.sh，然后将脚本拷贝到所有机器的/usr/k8s/bin目录。 
为方便后面迁移，我们在集群内定义一个域名用于访问apiserver，在每个节点的/etc/hosts文件中添加记录：10.1.1.10 k8s-api.virtual.local k8s-api

其中10.1.1.10为master的IP，暂时使用该IP 来做apiserver 的负载地址
