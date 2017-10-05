#!/usr/bin/env bash
set -e

echo "Starting Consul..."
if [ -x "$(command -v systemctl)" ]; then
  echo "using systemctl"
  sudo systemctl enable nomad.service
  sudo systemctl start nomad.service
else
  echo "using upstart"
  sudo start consul
fi

# EOF!
