# -*- mode: ruby -*-
# # vi: set ft=ruby :


Vagrant.require_version ">= 1.6.5"

Vagrant.configure("2") do |config|

	config.vm.box = "ubuntu/xenial64"
	config.vm.box_url = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box"
	config.vm.hostname = "ubuntu-xenial"

	config.vm.provider :virtualbox do |vb|
		vb.gui = false
		vb.memory = 1024
		vb.cpus = 2
	end

	config.vm.provision "ansible" do |ansible|
		ansible.playbook = "ansible/site.yml"
		ansible.sudo = true
	end
	config.vm.synced_folder "/tmp/", "/vagrant"
end
