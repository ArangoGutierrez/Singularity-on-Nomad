#!/bin/bash

set -e

CONFIGDIR=/ops/shared/config

CONSULCONFIGDIR=/etc/consul.d
NOMADCONFIGDIR=/etc/nomad.d
HOME_DIR=$HOME

# Wait for network

IP_ADDRESS=[=>AGENT IP<=]
SERVER_COUNT=1

# Nomad
echo "Fetching Nomad..."
NOMAD=0.6.3
cd /tmp
wget https://releases.hashicorp.com/nomad/${NOMAD}/nomad_${NOMAD}_linux_amd64.zip -O nomad.zip --quiet
unzip nomad.zip >/dev/null
chmod +x nomad

echo "Fetching Nomad..."
sudo mv nomad /usr/local/bin
sudo mkdir -p /opt/consul/data
sudo mkdir -p /etc/nomad

# EOF!
