require 'json'

namespace :couchbase do
  task default: :restapi

  def json_conf(param)
    conf_file = 'cookbooks/couchbase_cluster/files/schema.json'
    json = JSON.parse(File.read(conf_file))
    json[param]
  end

  desc 'delete vboxes and run vagrant up again'
  task :reload do
    nodes = json_conf 'nodes'
    nodes_list = []
    nodes.each do |n|
      nodes_list << n['hostname']
    end

    vms = `vboxmanage list vms`
    vms.split("\n").each do |vm|
      nodes_list.each do |n|
        next unless vm =~ /#{n}/ && vm =~ /\"(.*)\"/
        to_delete = Regexp.last_match(1)

        puts "\n --> removing vm #{to_delete}\n"
        `vboxmanage controlvm #{to_delete} poweroff`
        `vboxmanage unregistervm #{to_delete} --delete`
      end
    end
    puts "\n --> deleting '.vagrant/' dir\n"
    `rm -rf .vagrant/`
    puts "\n --> running 'vagrant up' ...\n\n"
    sh 'vagrant up'
  end

  desc 'run command using API like /pools/default/buckets/test_bucket/stats'
  task :restapi, [:command] do |_, args|
    admin = json_conf 'user'
    password = json_conf 'password'
    server = json_conf 'master'
    port = 8091
    command = if args.command.nil?
                '/pools/nodes'
              else
                args.command
              end
    sh 'clear'
    sh "curl -u #{admin}:#{password} http://#{server}:#{port}#{command}"
  end
end
