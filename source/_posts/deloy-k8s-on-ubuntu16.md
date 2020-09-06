---
title: Ubuntu 16.04上部署单机Kubernetes
date: 2020-09-06 08:33:55
tags: ['Kubernetes', 'Docker']
---

在公司都是用现成的K8s集群，没自己搭过，想知道搭建集群涉及哪些组件、做了什么，于是自己搭了一下，没想象的顺利，动作做到位了，也就不会有太多问题。

许多资料都是基于Centos7的，包括《Kubernetes权威指南》，手头只有Ubuntu 16.04，刚好也是支持K8s最低Ubuntu版本，就在Ubuntu上面部署。Ubuntu与Centos部署K8s并没有太大区别，唯一区别是安装kubeadm等软件的不同，由于k8s本身也是运行在容器中，其他的过程二者都相同了，这种设计也极大的方便了k8s集群的搭建。

**没有阿里云，搭建一个K8s集群还是挺费劲的**。

## 准备工作

1. `/etc/hosts`中加入：

```
127.0.0.1 k8s-master
```


2. 关闭防火墙：`ufw status`

3. [安装Docker，并设置镜像加速器](https://lessisbetter.site/2020/09/05/docker-proxy-and-registry-mirror/)。

## 安装软件

Ubuntu 16.04上利用阿里云安装kubeadm、kubelet、kubectl

```
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s http://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb http://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

centos 7上利用阿里云镜像安装kubeadm、kubelet、kubectl

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 将 SELinux 设置为 permissive 模式（相当于将其禁用）
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet
```

二进制程序安装位置：

```
[~]$ which kubectl kubeadm kubectl
/usr/bin/kubectl
/usr/bin/kubeadm
/usr/bin/kubectl
```


## 部署Master节点

```
kubeadm init \
  --kubernetes-version=v1.19.0 \
  --image-repository registry.aliyuncs.com/google_containers \
  --pod-network-cidr=10.24.0.0/16 \
  --ignore-preflight-errors=Swap
```

- `--image-repository` ： 使用阿里云提供的k8s镜像仓库，快速下载k8s相关的镜像
- `--ignore-preflight-errors` ： 部署时忽略swap问题
- `--pod-network-cidr` ：设置pod的ip区间

遇到错误需要重置集群：`kubeadm reset`

遇到错误参考：[kubernetes安装过程报错及解决方法](https://www.cnblogs.com/pu20065226/p/10641312.html)

## 拷贝kubectl配置

切回普通用户，拷贝当前集群的配置给kubectl使用：

```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

查看集群信息：

```
dabin@ubuntu:~$ kubectl cluster-info
Kubernetes master is running at https://192.168.0.103:6443
KubeDNS is running at https://192.168.0.103:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```



## 安装CNI网络插件

集群启动后，缺少网络插件，集群的Pod直接还不能通信。

```
dabin@ubuntu:~$ kubectl get node
NAME         STATUS     ROLES    AGE    VERSION
k8s-master   NotReady   master   5m8s   v1.19.0
```

k8s的[文档](https://kubernetes.io/zh/docs/concepts/cluster-administration/addons/)列举了多种选择，这里提供2种：

weave:

```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

flannel:

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

本机选择了weave：

```
dabin@ubuntu:~$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.apps/weave-net created
```


安装之后节点变为Ready：

```
dabin@ubuntu:~$ kubectl get node
NAME         STATUS   ROLES    AGE   VERSION
k8s-master   Ready    master   10m   v1.19.0
dabin@ubuntu:~$
dabin@ubuntu:~$ kubectl get -n kube-system pods
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-6d56c8448f-bdgwj             1/1     Running   0          10m
coredns-6d56c8448f-w6nnb             1/1     Running   0          10m
etcd-k8s-master                      1/1     Running   0          10m
kube-apiserver-k8s-master            1/1     Running   0          10m
kube-controller-manager-k8s-master   1/1     Running   0          10m
kube-proxy-xtgwn                     1/1     Running   0          10m
kube-scheduler-k8s-master            1/1     Running   0          10m
weave-net-4gtcq                      2/2     Running   0          93s
```

## 开启master调度

master节点默认是不可调度的，不可在master上部署任务，在单节点下，需要开启master可被调度。

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

以上集群搭建完毕。

## 测试

部署一个Pod进行测试，Pod能Running，代表Docker、K8s的配置基本没问题了：

声明文件为`twocontainers.yaml`:

```
apiVersion: v1 #指定当前描述文件遵循v1版本的Kubernetes API
kind: Pod #我们在描述一个pod
metadata:
  name: twocontainers #指定pod的名称
  namespace: default #指定当前描述的pod所在的命名空间
  labels: #指定pod标签
    app: twocontainers
  annotations: #指定pod注释
    version: v0.5.0
    releasedBy: david
    purpose: demo
spec:
  containers:
    - name: sise #容器的名称
      image: quay.io/openshiftlabs/simpleservice:0.5.0 #创建容器所使用的镜像
      ports:
        - containerPort: 9876 #应用监听的端口
    - name: shell #容器的名称
      image: centos:7 #创建容器所使用的镜像
      command: #容器启动命令
        - "bin/bash"
        - "-c"
        - "sleep 10000"
```

部署Pod：

```
kubectl apply -f twocontainers.yaml
```

几分钟后可以看pod状态是否为running。

```
dabin@k8s-master:~/workspace/notes/kubernetes/examples$ kubectl get pods
NAME            READY   STATUS    RESTARTS   AGE
twocontainers   2/2     Running   2          83m
```

如果不是，查看Pod部署遇到的问题：

```
kubectl describe pod twocontainers
```

## 资料

1. 人人必备的神书《Kuerbenetes权威指南》
2. [K8S中文文档](https://kubernetes.io/zh/docs/setup/independent/create-cluster-kubeadm/)
3. [kubernetes安装过程报错及解决方法](https://www.cnblogs.com/pu20065226/p/10641312.html)