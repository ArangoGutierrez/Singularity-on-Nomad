# Consul

[Consul](https://www.consul.io/) is a distributed key/value store that provides service discovery and health checking in a Nomad cluster.

## What is Consul?

[Consul](https://www.consul.io/) has multiple components, but as a whole, it is a tool for discovering and configuring services in your infrastructure. It provides several key features:

Service Discovery: Clients of Consul can provide a service, such as api or mysql, and other clients can use Consul to discover providers of a given service. Using either DNS or HTTP, applications can easily find the services they depend upon.

Health Checking: Consul clients can provide any number of health checks, either associated with a given service ("is the webserver returning 200 OK"), or with the local node ("is memory utilization below 90%"). This information can be used by an operator to monitor cluster health, and it is used by the service discovery components to route traffic away from unhealthy hosts.

KV Store: Applications can make use of Consul's hierarchical key/value store for any number of purposes, including dynamic configuration, feature flagging, coordination, leader election, and more. The simple HTTP API makes it easy to use.

Multi Datacenter: Consul supports multiple datacenters out of the box. This means users of Consul do not have to worry about building additional layers of abstraction to grow to multiple regions.

Consul is designed to be friendly to both the DevOps community and application developers, making it perfect for modern, elastic infrastructures.

## Basic Architecture of Consul

[Consul](https://www.consul.io/) is a distributed, highly available system. This section will cover the basics, purposely omitting some unnecessary detail, so you can get a quick understanding of how Consul works. For more detail, please refer to the in-depth architecture overview.

Every node that provides services to Consul runs a Consul agent. Running an agent is not required for discovering other services or getting/setting key/value data. The agent is responsible for health checking the services on the node as well as the node itself.

The agents talk to one or more Consul servers. The Consul servers are where data is stored and replicated. The servers themselves elect a leader. While Consul can function with one server, 3 to 5 is recommended to avoid failure scenarios leading to data loss. A cluster of Consul servers is recommended for each datacenter.

Components of your infrastructure that need to discover other services or nodes can query any of the Consul servers or any of the Consul agents. The agents forward queries to the servers automatically.

Each datacenter runs a cluster of Consul servers. When a cross-datacenter service discovery or configuration request is made, the local Consul servers forward the request to the remote datacenter and return the result.


> In this section one Consul server and two(2) agents will be deployed as part of the Nomad control plane.

## Provision the Consul Server

### Step 1

First let’s do a dnf update and grab a couple of extra packages! (In case you haven't installed wget and unzip on the host)

```bash
# run as root
$ dns -y update
$ dnf -y install unzip wget
```

Next let’s download and unpack Consul and Consul Web UI (0.9.3).

```bash
mkdir /tmp/bin
cd /tmp/bin
wget https://releases.hashicorp.com/consul/0.9.3/consul_0.6.4_linux_amd64.zip
wget https://releases.hashicorp.com/consul/0.9.0/consul_0.6.4_web_ui.zip
unzip consul_0.9.3_web_ui.zip
unzip consul_0.9.0_linux_amd64.zip
rm *.zip
```
Move Consul binaries and UI to appropriate folders and create config directories. Note here we are going to create both bootstrap and server config directories, the server config will be used in normal operation whilst the bootstrap will be used incase of cluster failure.

```bash
mkdir /var/consul
mkdir -p /home/consul/www
mkdir -p /etc/consul
mv consul /usr/local/bin/
mv index.html /home/user/consul/www/
mv static/ /home/user/consul/www/
```
### Step 2
create the config files

```bash
touch /etc/consul.d/bootstrap/config.json /etc/consul.d/server/config.json
```
For server/config.json

```json
{
    "advertise_addr": "[=>SERVER IP<=]",
    "bind_addr": "[=>SERVER IP<=]",
    "domain": "[=>DOMAIN NAME<=]",
    "bootstrap_expect": 3,
    "server": true,
    "datacenter": "[=>DATACENTRE ID<=]",
    "data_dir": "/var/consul",
    "encrypt": "[=>ENCRYPT KEY<=]",
    "dns_config": {
        "allow_stale": true,
        "max_stale": "15s"
    },
    "retry_join": [
        "[=>LIST OF OTHER CONSUL SERVER IP's<=]",
        "[=>LIST OF OTHER CONSUL AGENTS IP's<=]"
    ],
    "retry_interval": "10s",
    "retry_max": 100,
    "skip_leave_on_interrupt": true,
    "leave_on_terminate": false,
    "ports": {
        "dns": 53,
        "http": 80
    },
    "recursor": "[=>IP FOR FORWARD DNS LOOKUPS<=]",
    "ui_dir": "/home/user/consul/www",
    "rejoin_after_leave": true,
    "addresses": {
        "http": "0.0.0.0",
        "dns": "0.0.0.0"
    }
}
```

For bootstrap/config.json

```json
{
    "bootstrap": true,
    "server": true,
    "datacenter": "[=>DATACENTRE ID<=]",
    "data_dir": "/var/consul",
    "encrypt": "[=>ENCRYPT KEY<=]",
    "skip_leave_on_interrupt": true,
    "leave_on_terminate": false,
    "advertise_addr": "[=>SERVER IP<=]",
    "bind_addr": "[=>SERVER IP<=]",
    "domain": "[=>DOMAIN NAME<=]"

}
```
Config files used on this tutorials can be found on [configfiles](../../configfiles)

Now we must configure consul agent to run as a service.

```bash
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/server -rejoin
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
```
And finally we start consul as a systemd(systemctl) Service

```bash
systemctl start consul.service
systemctl enable consul
```
Or you can just use the [service.sh](../../scripts/consul/service.sh) script used on this tutorial

Right now we must see that we have a server as a member of our consul cluster
```bash
$ consul members
Node          Address           Status  Type    Build  Protocol  DC
agent-server  x.x.x.x:8301      alive   server  0.9.0  2         dc1
```
## Provision the Consul clients

Repeat [Step 1](#Step-1) from [Provision the Consul sever](#Provision-the-Consul-Server)

Now the differences with the first section is:

Move Consul binaries to appropriate folders and create config directories. Note here we are going to create a client folder for our config.json file

```bash
mkdir /var/consul
mkdir -p /etc/consul.d/{client}
mv consul /usr/local/bin/
```

create the config files

```bash
touch /etc/consul.d/client/config.json
```

Our /etc/consul.d/client/config.json must look something like

```json
{
 "bind_addr": "[=>AGENT IP<=]",
 "datacenter": "[=>DATACENTER ID<=]",
 "data_dir": "/opt/consul/data",
 "encrypt": "[=>CONSUL KEY<=]",
 "log_level": "DEBUG",
 "enable_syslog": true,
 "enable_debug": true,
 "node_name": "[=>AGENT-1<=]",
 "server": false,
 "rejoin_after_leave": true,
 "retry_join": [
    "[=>SERVER IP<=]",
    "[=>AGENT-2 IP<=]"
    ]
 }
```
Config files used on this tutorials can be found on [configfiles](../../configfiles)

Now we must configure consul agent to run as a service.

```bash
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Environment=GOMAXPROCS=2
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/server -rejoin
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
```
And finally we start consul as a systemd(systemctl) Service
```bash
systemctl start consul.service
systemctl enable consul
```
Or you can just use the [service.sh](../../scripts/service.sh) script used on this tutorial

Right now we must see that we have a server as a member of our consul cluster
```bash
$ consul members
Node          Address           Status  Type    Build  Protocol  DC
agent-client  x.x.x.x:8301      alive   client  0.9.0  2         dc1
agent-server  x.x.x.x:8301      alive   server  0.9.0  2         dc1
```
**Repeat this steps for the AGENT-2**

<!---
EOF!
-->
