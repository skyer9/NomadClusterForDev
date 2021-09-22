datacenter = "dc1"
data_dir   = "/opt/nomad/data"
bind_addr  = "0.0.0.0"

advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}

server {
  enabled          = true
  bootstrap_expect = 1
}

log_file = "/var/log/nomad/"
log_level = "INFO"

client {
  enabled = true

  host_volume "grafana" {
    # add directory manually
    # sudo mkdir -p /opt/nomad-volumes/grafana
    # sudo chown 472:472 /opt/nomad-volumes/grafana
    path = "/opt/nomad-volumes/grafana"
  }
  host_volume "jenkins_home" {
    # add directory manually
    # sudo mkdir -p /opt/nomad-volumes/jenkins_home
    # sudo chown 1000:1000 /opt/nomad-volumes/jenkins_home
    path = "/opt/nomad-volumes/jenkins_home"
  }
}

consul {
  address = "127.0.0.1:8500"
}

#plugin "nvidia-gpu" {
#  config {
#    enabled            = true
#    ignored_gpu_ids    = ["GPU-fef8089b", "GPU-ac81e44d"]
#    fingerprint_period = "1m"
#  }
#}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }

    # 실행 실패시 이미지 삭제
    # 디버깅시 false 로 할것
    gc {
      container   = true
    }

#    auth {
#      # Nomad will prepend "docker-credential-" to the helper value and call
#      # that script name.
#      helper = "ecr-login"
#    }
  }
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}
