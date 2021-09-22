#!/bin/bash

# ============================
# Install dependencies.
yum update -y
yum install -y \
  curl \
  jq \
  zip

nomad_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r '.current_version')
consul_version=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r '.current_version')

# ============================
# Download and install Docker.
yum install -y docker
systemctl enable docker
systemctl restart docker
docker run hello-world

# 내 계정 docker 그룹에 추가
# usermod -aG docker ec2-user

# ============================
# Install Hey.
wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chown root:root hey_linux_amd64
chmod 755 hey_linux_amd64
mv hey_linux_amd64 /usr/local/bin/hey

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
