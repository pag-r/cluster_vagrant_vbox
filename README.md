#Couchbase cluster cookbook using VirtualBox, Chef and Vagrant

Cookbook is builded by default on Centos6.6

Cookbook is created to add cluster nodes very easily using json-like file.
VirtualBox was used to build VMs as VBox allows usage of concurrent builds in
[Vagrantfile](../Vagrantfile)

###Config
#####schema.json
All parts of cookbook uses single one config file:
[schema.json](../cookbooks/couchbase_cluster/files/schema.json)] format
```json
{
  "master"    : "192.168.33.10",
  "user"      : "root",
  "password"  : "secretpass",
  "nodes": [
    {
      "hostname"    : "clstr20node",
      "ip_address"  : "192.168.33.22",
      "cookbook"    : "couchbase_cluster"
    },
    {
      "hostname"    : "clstr00serv",
      "ip_address"  : "192.168.33.10",
      "cookbook"    : "couchbase_cluster"
    }
  ]
}
```
`master` node uses IP notation instead of hostname
###Usage
using vagrant: `vagrant up`
using [Rakefile](../Rakefile)
```shell
$ rake couchbase:reload            # delete vboxes and run vagrant up again
```

###Couchbase Rest API
Using rakefile GET commands for RESTAPI can be made. No further configuration is
needed. Rakefile uses schema.json configuration.
```shell
rake couchbase:restapi[command]  # run command using API like /pools/default/buckets/test_bucket/stats
```
If no command is set GET `/pools/nodes` is used.
