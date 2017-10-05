# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/nomad-client"

# Setupnode name
name = "nomad-client-#"

# Setup datacenter name
datacenter = "highwind"

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
