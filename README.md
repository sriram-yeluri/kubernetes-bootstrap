
# Bootstrap kubernetes cluster using kubeadm, with 1 master and 2 worker nodes

Working with kubernetes requires a cluster , and not every one is fortunate enough to have a free cloud account to spin up a managed container service.
Especially for developers who want to get some hands on experience with kubernetes without spending huge bills on cloud infrastructure.

So , i have created this automated kubernetes cluster provisioning using virtualbox, vagrant and bootstrap scripts.
These scripts are created by referring to the official kubernetes documentation.

As you all aware, kubernetes deprecated docker in favour of `Container Runtime Interface (CRI)` , i am using `containerd` as CRI for this provisioning.

## Prerequisites

* Linux or Mac Machine
* Oracle VirtualBox
* Vagrant
* Git (Optional, you can also download the code as zip package from Github)
* Internet connection to pull required packages during the cluster provisioning

## How to provision the kubernetes cluster

Provisioning of the kubernetes cluster can be done with a single `vagrant up` command. This will take approximately 15 to 20 mins depending on the available resources on your host machine.

* `vagrant up` : this will provision the k8s cluster
* `vagrant halt` : this will save the state and stop the VMs
* `vagrant resume` : this will start the VMs from previous state.

## copy config file from vagrant box to host machine

```sh
# for now this is a manual step, 
# TO-DO: automate this step 

# Find on which port, the vagrant box is running
vagrant port k8s-master
22 (guest) => 2222 (host)
# copy the config file to local host in current folder.
# id : vagrant , password: vagrant
scp -P 2222 vagrant@127.0.0.1:/home/vagrant/.kube/config .
```

## Test the cluster

If you want to test and use the AKS cluster from your host machine, then you have to copy the config file as explained above.
Else , you can connect to k8s-master with `vagrant ssh k8s-master` command and use the cluster. If you are using the local host to access the cluster , then move the config file to `$HOME/.kube/config`, so you do not have to provide --kubeconfig flag for kubectl commands.

```sh
Apples-Mac-mini:kubernetes-bootstrap Mac$ kubectl --kubeconfig=config get nodes
NAME         STATUS   ROLES                  AGE   VERSION
k8s-master   Ready    control-plane,master   23h   v1.23.3
node-1       Ready    <none>                 22h   v1.23.3
node-2       Ready    <none>                 22h   v1.23.3
```

```sh
Apples-Mac-mini:kubernetes-bootstrap Mac$ kubectl --kubeconfig=config get pods -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS      AGE
kube-system   calico-kube-controllers-85b5b5888d-bkf2r   1/1     Running   0             23h
kube-system   calico-node-88bm9                          1/1     Running   0             22h
kube-system   calico-node-9lm7s                          1/1     Running   0             22h
kube-system   calico-node-t4vrh                          1/1     Running   0             23h
kube-system   coredns-64897985d-b9krf                    1/1     Running   0             23h
kube-system   coredns-64897985d-pzbwd                    1/1     Running   0             23h
kube-system   etcd-k8s-master                            1/1     Running   0             23h
kube-system   kube-apiserver-k8s-master                  1/1     Running   0             23h
kube-system   kube-controller-manager-k8s-master         1/1     Running   1 (22h ago)   23h
kube-system   kube-proxy-mjtht                           1/1     Running   0             23h
kube-system   kube-proxy-tv5wv                           1/1     Running   0             22h
kube-system   kube-proxy-wfpbh                           1/1     Running   0             22h
kube-system   kube-scheduler-k8s-master                  1/1     Running   0             23h
```

## References i have followed during this automation

### Creating a cluster with kubeadm
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

### Container runtimes
https://kubernetes.io/docs/setup/production-environment/container-runtimes/

### Configuring cgroup driver 
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/


### Cluster Networking
https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model


### Troubleshooting kubeadm
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/
