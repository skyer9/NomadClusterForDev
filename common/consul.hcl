advertise_addr = "127.0.0.1"
bind_addr = "0.0.0.0"
bootstrap_expect = 1
client_addr = "0.0.0.0"

data_dir = "/opt/consul/data"

log_level = "INFO"

server = true
ui_config {
  enabled = true
}

connect {
  enabled = true
}

telemetry {
  prometheus_retention_time = "24h"
}

service {
  name = "consul"
}