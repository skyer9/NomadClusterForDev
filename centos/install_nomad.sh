#!/bin/bash

# ============================
# Install dependencies.
yum update -y
yum install -y \
  curl \
  jq \
  zip

exit

nomad_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r '.current_version')
consul_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r '.current_version')

# ============================
# Download and install Docker.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
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

cp ../common/consul.hcl /etc/consul.d/consul.hcl
cp ../common/consul.service /etc/systemd/system/consul.service
cp ../common/nomad.hcl /etc/nomad.d/nomad.hcl
cp ../common/nomad.service /etc/systemd/system/nomad.service

mkdir -p /opt/nomad-volumes/grafana
chown 472:472 /opt/nomad-volumes/grafana
mkdir -p /opt/nomad-volumes/jenkins_home
chown 1000:1000 /opt/nomad-volumes/jenkins_home

useradd consul
mkdir -p /opt/consul/data
mkdir -p /var/lib/consul
chown consul:consul /opt/consul/data
chown consul:consul /var/lib/consul

systemctl daemon-reload

systemctl enable consul
systemctl restart consul.service
systemctl enable nomad
systemctl restart nomad.service
