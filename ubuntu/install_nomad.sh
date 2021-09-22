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

# 내 계정 docker 그룹에 추가
usermod -aG docker ubuntu

# ============================
# Install Hey.
apt-get install -y hey

# ============================
# Download and install Nomad and Consul.
curl --silent --show-error --remote-name-all \
  https://releases.hashicorp.com/nomad/"${nomad_version}"/nomad_"${nomad_version}"_linux_amd64.zip \
  https://releases.hashicorp.com/consul/"${consul_version}"/consul_"${consul_version}"_linux_amd64.zip
unzip nomad_"${nomad_version}"_linux_amd64.zip
unzip consul_"${consul_version}"_linux_amd64.zip
mv consul /usr/local/bin
mv nomad /usr/local/bin
chmod +x /usr/local/bin/consul
chmod +x /usr/local/bin/nomad

mkdir /etc/consul.d
mkdir /etc/nomad.d

sudo cp ../common/consul.hcl /etc/consul.d/consul.hcl
sudo cp ../common/consul.service /etc/systemd/system/consul.service
sudo cp ../common/nomad.hcl /etc/nomad.d/nomad.hcl
sudo cp ../common/nomad.service /etc/systemd/system/nomad.service

sudo systemctl daemon-reload

sudo systemctl enable consul
sudo systemctl start consul.service
sudo systemctl enable nomad
sudo systemctl start nomad.service