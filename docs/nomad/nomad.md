# Nomad

[Nomad](https://www.nomadproject.io/) is a tool for managing a cluster of machines and running applications on them. Nomad abstracts away machines and the location of applications, and instead enables users to declare what they want to run and Nomad handles where they should run and how to run them.

The key features of [Nomad](https://www.nomadproject.io/) are:

Docker Support: Nomad supports Docker as a first-class workload type. Jobs submitted to Nomad can use the docker driver to easily deploy containerized applications to a cluster. Nomad enforces the user-specified constraints, ensuring the application only runs in the correct region, datacenter, and host environment. Jobs can specify the number of instances needed and Nomad will handle placement and recover from failures automatically.

Operationally Simple: Nomad ships as a single binary, both for clients and servers, and requires no external services for coordination or storage. Nomad combines features of both resource managers and schedulers into a single system. Nomad builds on the strength of Serf and Consul, distributed management tools by HashiCorp.

Multi-Datacenter and Multi-Region Aware: Nomad models infrastructure as groups of datacenters which form a larger region. Scheduling operates at the region level allowing for cross-datacenter scheduling. Multiple regions federate together allowing jobs to be registered globally.

Flexible Workloads: Nomad has extensible support for task drivers, allowing it to run containerized, virtualized, and standalone applications. Users can easily start Docker containers, VMs, or application runtimes like Java. Nomad supports Linux, Windows, BSD and OSX, providing the flexibility to run any workload.

Built for Scale: Nomad was designed from the ground up to support global scale infrastructure. Nomad is distributed and highly available, using both leader election and state replication to provide availability in the face of failures. Nomad is optimistically concurrent, enabling all servers to participate in scheduling decisions which increases the total throughput and reduces latency to support demanding workloads.

## Architecture
Nomad is a complex system that has many different pieces. To help both users and developers of Nomad build a mental model of how it works, this page documents the system architecture.

To learn more about Nomad refer to the official docs at  [Nomad internals](https://www.nomadproject.io/docs/internals/index.html)

> In this section one nomad server and two(2) clients will be deployed as part of the Nomad control plane.

## Provision the Nomad Server

### Step 1
First let’s do a dnf update and grab a couple of extra packages! (In case you haven't installed wget and unzip on the host)

```bash
# run as root
$ dns -y update
$ dnf -y install unzip wget
```

Next let’s download and unpack Nomad (0.6.3).

```bash
$ NOMAD=0.6.3
$ cd /tmp
$ wget https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_amd64.zip -O nomad.zip --quiet
$ unzip nomad.zip >/dev/null
$ chmod +x nomad
$ rm *.zip
```
### Step 2

create the config files

```bash
$ touch /etc/nomad/nomad-server.hcl
```
For nomad-server.hcl

```bash
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/nomad-server"

# Setupnode name
name = "nomad-server"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1

    enabled_schedulers = ["batch"]
    num_schedulers     = 2
}

```
Config files used on this tutorials can be found on [configfiles](../../configfiles)

Set nomad service as a daemon process:

```bash
$ sudo vim /etc/systemd/system/nomad-server.service
# ...>
[Unit]
Description=Nomad server
Wants=network-online.target
After=network-online.target
[Service]
ExecStart=/usr/bin/nomad agent -config /etc/nomad/nomad-server.hcl
Restart=always
RestartSec=10
[Install]
WantedBy=multi-user.target
```

To enable this daemon process:

```bash
$ sudo systemctl enable nomad-server.service
$ sudo systemctl start nomad-server.service
```

Or you can just use the [service.sh](../../scripts/nomad/service.sh) script used on this tutorial

Right now we must see that we have a server as a member of our nomad cluster

```bash
$ nomad server-members
Name                 Address      Port  Status  Leader  Protocol  Build  Datacenter  Region
nomad-server.global  x.x.x.x      4648  alive   true    2         0.6.3  dc1         global
```

## Provision the Nomad clients

> First:
> Repeat [Step 1](#Step-1) from [Provision the Nomad server](#Provision-the-Nomad-Server)

Similar to the server, we must first configure the clients. Either download the configuration for client-1 and client-2 from the repository here, or paste the following into client.hcl:

create the config files

```bash
$ touch /etc/nomad/nomad-client.hcl
```
For nomad-server.hcl

```bash
# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/nomad-client"

# Setupnode name
name = "nomad-client-#"

# Enable the client
client {
    enabled = true
    # here we assume that the system has a
    # Consul.service active used for service discovery.
    servers = ["nomad.service.consul:4647"]

    # Specifies an arbitrary string used to
    # logically group client nodes by user-defined class. This can be used during job placement as a filter.
    node_class    = "worker"
}

# Modify our port to avoid a collision with server1
ports {
    http = 5656
}

```
Config files used on this tutorials can be found on [configfiles](../../configfiles)

Set nomad service as a daemon process:

```bash
$ sudo vim /etc/systemd/system/nomad-client.service
#...>
[Unit]
Description=Nomad client
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/nomad agent -config /etc/nomad/nomad-client.hcl -bind=["CLIENT_IP_ADDR"]
Environment=GOMAXPROCS=2
Restart=on-failure
RestartSec=10
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
```
To enable this daemon process on client:

```bash
$ sudo systemctl enable nomad-client.service
$ sudo systemctl start nomad-client.service
```

Using the node-status command we should see both nodes in the ready state:

```bash
$ nomad node-status
ID        Datacenter  Name   Class   Drain  Status
fca62612  dc1         nomad  <none>  false  ready
c887deef  dc1         nomad  <none>  false  ready
```

**Repeat this steps for the Client-2**

<!--
EOF!
-->
