#!/bin/bash
# Con esto extraigo la parte correcta de Loki
sed -i '/loki:/,/alloy:/ {
  s|command: -config.file=/et\./Loki/loki-config.yaml|command: -config.file=/etc/loki/loki-config.yaml|
  s|/et\./Loki/loki-config.yaml|/etc/loki/loki-config.yaml|g
  s|./Loki/loki-config.yaml|./loki/loki-config.yaml|g
}' docker-compose.yml
