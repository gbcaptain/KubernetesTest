[Reference Source](https://www.qikqiak.com/post/manual-install-high-available-kubernetes-cluster/ "手动搭建高可用的kubernetes 集群")


1. 组件版本 && 集群环境
  组件版本
  etcd 集群 && k8s master 机器 && k8s node 机器
  集群环境变量
2. 创建CA 证书和密钥
  安装 CFSSL
  创建CA
  分发证书
3. 部署高可用etcd 集群
  定义环境变量
  下载etcd 二进制文件
  创建TLS 密钥和证书
  创建etcd 的systemd unit 文件
  启动etcd 服务
  验证服务
4. 配置kubectl 命令行工具
  环境变量
  下载kubectl
  创建admin 证书
  创建kubectl kubeconfig 文件
  分发kubeconfig 文件
5. 部署Flannel 网络
  环境变量
  创建TLS 密钥和证书
  向etcd 写入集群Pod 网段信息
  安装和配置flanneld
  启动flanneld
  检查flanneld 服务
  检查分配给各flanneld 的Pod 网段信息
  确保各节点间Pod 网段能互联互通
6. 部署master 节点
  环境变量
  下载最新版本的二进制文件
  创建kubernetes 证书
  6.1 配置和启动kube-apiserver
    创建kube-apiserver 使用的客户端token 文件
    创建kube-apiserver 的systemd unit文件
    启动kube-apiserver
  6.2 配置和启动kube-controller-manager
    创建kube-controller-manager 的systemd unit 文件
    启动kube-controller-manager
  6.3 配置和启动kube-scheduler
    创建kube-scheduler 的systemd unit文件
    启动kube-scheduler
  6.4 验证master 节点
7. kube-apiserver 高可用
  安装haproxy
  配置haproxy
  启动haproxy
  问题
    方式1：使用阿里云SLB
    方式2：使用keepalived
  kube-controller-manager 和kube-scheduler 的高可用
8. 部署Node 节点
  环境变量
  开启路由转发
  配置docker
  启动docker
  安装和配置kubelet
  创建kubelet bootstapping kubeconfig 文件
  创建kubelet 的systemd unit 文件
  启动kubelet
  通过kubelet 的TLS 证书请求
  配置kube-proxy
    创建kube-proxy 证书签名请求：
    生成kube-proxy 客户端证书和私钥
    创建kube-proxy kubeconfig 文件
    创建kube-proxy 的systemd unit 文件
    启动kube-proxy
  验证集群功能
9. 部署kubedns 插件
  系统预定义的RoleBinding
  配置kube-dns ServiceAccount
  配置kube-dns 服务
  配置kube-dns Deployment
  执行所有定义文件
  检查kubedns 功能
10. 部署Dashboard 插件
  配置dashboard-controller
  配置dashboard-service
  执行所有定义文件
  检查执行结果
  访问dashboard
11. 部署Heapster 插件
  执行所有文件
  检查执行结果
  访问 grafana
12. 安装Ingress
  部署traefik
    创建rbac
    DaemonSet 形式部署traefik
    创建ingress
    Traefik UI测试
13. 日志收集
14. 私有仓库harbor 搭建
15. 问题汇总
  15.1 dashboard无法显示监控图
  15.2 kube-proxy报错kube-proxy[2241]: E0502 15:55:13.889842 2241 conntrack.go:42] conntrack returned error: error looking for path of conntrack: exec: “conntrack”: executable file not found in $PATH
  15.3 Unable to access kubernetes services: no route to host
  15.4 使用NodePort 类型的服务，只能在POD 所在节点进行访问
参考资料
