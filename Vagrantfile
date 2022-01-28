IMAGE_NAME = "bento/ubuntu-21.10"
N = 2

Vagrant.configure("2") do |config|

    config.vm.provision "shell", path: "bootstrap.sh"
    config.ssh.insert_key = false

    config.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 2
    end
    
    # Provision Master Node
    config.vm.define "k8s-master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip: "192.168.56.10"
        master.vm.hostname = "k8s-master"
        master.vm.provision "shell", path: "bootstrap_k8smaster.sh"
    end

    # Provision WorkerNode
    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "192.168.56.#{i + 10}"
            node.vm.hostname = "node-#{i}"
            node.vm.provision "shell", path: "bootstrap_k8sworker.sh"
        end
    end
end
    