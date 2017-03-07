# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
schema = "#{Dir.pwd}/cookbooks/couchbase_cluster/files/schema.json"
nodes = JSON.parse(File.read(schema))

Vagrant.configure('2') do |config|
  config.vm.box = 'minimal/centos6'
  config.vm.provider 'virtualbox' do |l|
    l.memory = 1024
    l.cpus = 1
  end

  nodes['nodes'].each do |v|
    config.vm.define (v['hostname']).to_s do |k|
      k.vm.network 'private_network', ip: (v['ip_address']).to_s
      k.vm.hostname = (v['hostname']).to_s
      k.vm.provision 'shell',
                     inline: "ifconfig eth1 #{v['ip_address']} netmask 255.255.255.0"
      config.vm.provision 'chef_solo' do |chef|
        chef.add_recipe (v['cookbook']).to_s
      end
    end
  end
end
