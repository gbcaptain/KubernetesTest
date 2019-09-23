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
