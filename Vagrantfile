# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
  {
    ip: '10.0.0.10',
    hostname:  'dev.local',
    ram: 4096,
    cpu: 2,
    box:  'ubuntu/bionic64'
  }
]

Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.ssh.forward_agent = true
      node.disksize.size = '16GB'
      node.vm.box = machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.network 'private_network', ip: machine[:ip]
      node.vm.network "forwarded_port", guest: 8001, host: 8001
      node.vm.network "forwarded_port", guest: 8443, host: 8443
      node.vm.provision 'shell', inline: 'sudo mkdir -p /home/ubuntu/.ssh/'
      node.vm.synced_folder '~/.ssh', '/home/ubuntu/keys'
      node.vm.provision 'shell', inline: 'sudo cat /home/ubuntu/keys/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys'
      node.vm.provision 'shell', inline: 'sudo chown -R ubuntu:ubuntu /home/ubuntu'
      node.vm.provider 'virtualbox' do |vb|
        vb.customize ['modifyvm', :id, '--memory', machine[:ram]]
        vb.customize ['modifyvm', :id, '--cpus', machine[:cpu]]
        vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
        vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vb.customize ['modifyvm', :id, '--nictype1', 'virtio']
      end
    end
  end
end
