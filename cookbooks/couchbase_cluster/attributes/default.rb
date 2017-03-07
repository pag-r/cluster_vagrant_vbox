require 'json'

if node[:platform] == 'centos' && node[:platform_version].to_s == '6.6'

  hash_path = ''
  nodes_list = []
  master_ip = ''
  master_hostname = ''
  dir = `find /tmp/vagrant-chef/ -maxdepth 1 -type d | grep -e [0-9a-f]`
  dir.split("\n").each do |line|
    if line =~ %r{\/tmp\/vagrant-chef\/([0-9a-f]{32})}
      hash_path = Regexp.last_match(1)
      break
    end
  end
  j_path = "/tmp/vagrant-chef/#{hash_path}/cookbooks/couchbase_cluster/files/"
  json_conf = JSON.parse(File.read(j_path + 'schema.json'))

  json_conf['nodes'].each do |i|
    master_hostname = i['hostname'] if i['ip_address'] == json_conf['master']
    master_ip = i['ip_address'] if  i['ip_address'] == json_conf['master']
    nodes_list <<  i['ip_address'] unless json_conf['master'] == i['ip_address']
  end

  default[:rpm][:version] = '4.5.0'
  default[:rpm][:url] = 'https://packages.couchbase.com/releases/'
  default[:rpm][:pkg] =
    "couchbase-server-community-#{default[:rpm][:version]}-centos6.x86_64.rpm"
  default[:rpm][:checksum] =
    '698195ccf421ca70cc8cab1358cd6b5340d439a828cecca8ac3846b78da5809c'

  default[:cluster][:username] = json_conf['user']
  default[:cluster][:password] = json_conf['password']
  default[:cluster][:port] = 8091
  default[:cluster][:services] = 'data,index,query,fts'
  default[:cluster][:ramsize] = 256
  default[:cluster][:index_storage] = 'default'
  default[:cluster][:master_ip] = master_ip
  default[:cluster][:master_hostname] = master_hostname

  default[:couchbase][:bin] = '/opt/couchbase/bin/couchbase-cli'

  default[:nodes][:list] = nodes_list

  default[:bucket][:name] = 'test_bucket'
  default[:bucket][:type] = 'couchbase'
  default[:bucket][:ramsize] = 128
  default[:bucket][:replica] = 2

end
