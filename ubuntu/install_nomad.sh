#!/bin/bash

# ============================
# Install dependencies.
apt-get update
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  jq \
  software-properties-common \
  zip

nomad_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r '.current_version')
consul_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r '.current_version')

# ============================
# Download and install Docker.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
apt-get update
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io
docker run hello-world
usermod -aG docker vagrant

# ============================
# Install Hey.
apt-get install -y hey

# ============================
# Download and install Nomad and Consul.
curl --silent --show-error --remote-name-all \
  https://releases.hashicorp.com/nomad/"${nomad_version}"/nomad_"${nomad_version}"_linux_amd64.zip \
  https://releases.hashicorp.com/consul/"${consul_version}"/consul_"${consul_version}"_linux_amd64.zip
unzip nomad_"${nomad_version}"_linux_amd64.zip
# shellcheck disable=SC2086
unzip consul_${consul_version}_linux_amd64.zip
mv nomad consul /usr/local/bin
chmod +x /usr/local/bin/{nomad,consul}

sudo cp ../common/consul.hcl /etc/consul.d/consul.hcl
sudo cp ../common/consul.service /etc/systemd/system/consul.service
sudo cp ../common/nomad.hcl /etc/nomad.d/nomad.hcl
sudo cp ../common/nomad.service /etc/systemd/system/nomad.service

sudo systemctl daemon-reload

sudo systemctl enable consul
sudo systemctl start consul.service
sudo systemctl enable nomad
sudo systemctl start nomad.service