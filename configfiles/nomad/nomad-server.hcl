# Increase log verbosity
log_level = "DEBUG"

# Setup data dir
data_dir = "/tmp/nomad-server"

# Setupnode name
name = "nomad-server"

# Setup datacenter name
datacenter = "highwind"

# Enable the server
server {
    enabled = true

    # Self-elect, should be 3 or 5 for production
    bootstrap_expect = 1

    enabled_schedulers = ["batch"]
    num_schedulers     = 2
}
