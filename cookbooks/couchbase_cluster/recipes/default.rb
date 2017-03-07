#
# Cookbook Name:: couchbase_cluster
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

rpm_url = "#{node[:rpm][:url]}#{node[:rpm][:version]}/#{node[:rpm][:pkg]}"
rpm_cache = "#{Chef::Config[:file_cache_path]}/#{node[:rpm][:pkg]}"

remote_file rpm_cache do
  source rpm_url
  action :create_if_missing
  checksum node[:rpm][:checksum]
end

rpm_package node[:rpm][:pkg] do
  source rpm_cache
  action :install
  not_if 'rpm -qa | grep couchbase-server-community'
end
execute 'wait after couchbase-server installation' do
  command 'sleep 10'
end

execute 'init cluster' do
  command "#{node[:couchbase][:bin]} cluster-init \
    -c 127.0.0.1 \
    --cluster-username=#{node[:cluster][:username]} \
    --cluster-password=#{node[:cluster][:password]} \
    --cluster-port=#{node[:cluster][:port]} \
    --services=#{node[:cluster][:services]} \
    --cluster-ramsize=#{node[:cluster][:ramsize]} \
    --cluster-index-ramsize=#{node[:cluster][:ramsize]} \
    --cluster-fts-ramsize=#{node[:cluster][:ramsize]} \
    --index-storage-setting=#{node[:cluster][:index_storage]}"
  not_if "[[ $(#{node[:couchbase][:bin]} cluster-init \
    -c 127.0.0.1 \
    --cluster-username=#{node[:cluster][:username]} \
    --cluster-password=#{node[:cluster][:password]} \
    --cluster-port=#{node[:cluster][:port]} \
    --services=#{node[:cluster][:services]} \
    --cluster-ramsize=#{node[:cluster][:ramsize]} \
    --cluster-index-ramsize=#{node[:cluster][:ramsize]} \
    --cluster-fts-ramsize=#{node[:cluster][:ramsize]} \
    --index-storage-setting=#{node[:cluster][:index_storage]}
    -u #{node[:cluster][:username]} -p #{node[:cluster][:password]}) ]]"
end

execute 'wait after couchbase-server init' do
  command 'sleep 10'
end

if node[:hostname] == node[:cluster][:master_hostname]

  node[:nodes][:list].each do |ip|
    seconds = 10
    execute 'add cluster' do
      command "#{node[:couchbase][:bin]} server-add \
        -c #{node[:cluster][:master_ip]}:#{node[:cluster][:port]} \
        -u #{node[:cluster][:username]} -p #{node[:cluster][:password]} \
        --server-add=#{ip}:#{node[:cluster][:port]} \
        --server-add-username=#{node[:cluster][:username]} \
        --server-add-password=#{node[:cluster][:password]}"
      not_if "#{node[:couchbase][:bin]} server-list \
        -c #{node[:cluster][:master_ip]}:#{node[:cluster][:port]} \
        -u #{node[:cluster][:username]} \
        -p #{node[:cluster][:password]} | grep -q '#{ip}'"
    end
    execute "wait #{seconds} after adding node to cluster" do
      command "sleep #{seconds}"
    end
    seconds += 1
  end

  execute 'rebalance cluster' do
    command "#{node[:couchbase][:bin]} rebalance \
      -c #{node[:cluster][:master_ip]}:#{node[:cluster][:port]} \
      -u #{node[:cluster][:username]} -p #{node[:cluster][:password]}"
  end

  execute 'create example bucket' do
    command "#{node[:couchbase][:bin]} bucket-create \
      -c #{node[:cluster][:master_ip]}:#{node[:cluster][:port]} \
      -u #{node[:cluster][:username]} -p #{node[:cluster][:password]} \
      --bucket=#{node[:bucket][:name]} --bucket-type=#{node[:bucket][:type]} \
      --bucket-ramsize=#{node[:bucket][:ramsize]} \
      --bucket-replica=#{node[:bucket][:replica]} --wait"
    not_if "#{node[:couchbase][:bin]} bucket-list \
      -c #{node[:cluster][:master_ip]}:#{node[:cluster][:port]} \
      -u #{node[:cluster][:username]} \
      -p #{node[:cluster][:password]} | grep -q #{node[:bucket][:name]}"
  end

end
