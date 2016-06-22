# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

  config.vm.box = "centos/7"

  _CONSUL_JOIN_ADDRESS = "192.168.33.10"
  _NOMAD_JOIN_ADDRESS = _CONSUL_JOIN_ADDRESS

  config.vm.define :server do |host|
    _HOSTNAME = "server"
    _PRIVATE_IP_ADDRESS = _CONSUL_JOIN_ADDRESS
    _CONSUL_ARGS = _HOSTNAME + " " + _PRIVATE_IP_ADDRESS + " " + _CONSUL_JOIN_ADDRESS

    host.vm.hostname = _HOSTNAME
    host.vm.network "private_network", ip: _PRIVATE_IP_ADDRESS
    host.vm.provision :shell, path: "install-consul.sh"
    host.vm.provision :shell, path: "run-consul-server.sh", args: _CONSUL_ARGS
    host.vm.provision :shell, path: "set-dns.sh"
    host.vm.provision :shell, path: "install-nomad.sh"
    host.vm.provision :shell, path: "run-nomad-server.sh", args: _CONSUL_ARGS
  end

  config.vm.define :agent01 do |host|
    _HOSTNAME = "agent01"
    _PRIVATE_IP_ADDRESS = "192.168.33.20"
    _CONSUL_ARGS = _HOSTNAME + " " + _PRIVATE_IP_ADDRESS + " " + _CONSUL_JOIN_ADDRESS

    host.vm.hostname = _HOSTNAME
    host.vm.network "private_network", ip: _PRIVATE_IP_ADDRESS
    host.vm.provision :shell, path: "install-consul.sh"
    host.vm.provision :shell, path: "run-consul-client.sh", args: _CONSUL_ARGS
    host.vm.provision :shell, path: "set-dns.sh"
    host.vm.provision :shell, path: "install-nomad.sh"
    host.vm.provision :shell, path: "run-nomad-agent.sh", args: _CONSUL_ARGS
  end

  config.vm.define :front do |host|
    _HOSTNAME = "front"
    _PRIVATE_IP_ADDRESS = "192.168.33.30"
    _CONSUL_ARGS = _HOSTNAME + " " + _PRIVATE_IP_ADDRESS + " " + _CONSUL_JOIN_ADDRESS

    host.vm.hostname = _HOSTNAME
    host.vm.network "private_network", ip: _PRIVATE_IP_ADDRESS
    host.vm.provision :shell, path: "install-nginx.sh", args: _HOSTNAME
    host.vm.provision :shell, path: "install-consul.sh"
    host.vm.provision :shell, path: "run-consul-client.sh", args: _CONSUL_ARGS
    host.vm.provision :shell, path: "set-dns.sh"
    host.vm.provision :shell, path: "install-consul-template.sh"
    host.vm.provision :shell, path: "run-consul-template.sh"
  end

end
