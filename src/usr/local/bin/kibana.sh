#!/bin/bash
# #################################################################
# NAME: kibana.sh
# DESC: Kibana startup file.
#
# LOG:
# yyyy/mm/dd [user] [version]: [notes]
# 2015/02/05 cgwong v1.0.0: re- creation
# 2015/02/05 cgwong v1.0.1: Modify toml file name.
# #################################################################

# Fail hard and fast
set -eo pipefail

# Set environment
KV_TYPE=${KV_TYPE:-etcd}
KV_HOST=${KV_HOST:-172.17.8.101}
if [ "$KV_TYPE" = "etcd" ]; then
  # Set as default for etcd unless otherwise stated
  KV_PORT=${KV_PORT:-4001}
else
  # Set as default for consul unless otherwise stated
  KV_PORT=${KV_PORT:-8500}
fi
KV_URL=${KV_HOST}:${KV_PORT}

echo "[kibana] booting container. KV store: $KV_TYPE"

# Loop until confd has updated the config
until confd -onetime -backend $KV_TYPE -node $KV_URL -config-file /etc/confd/conf.d/kibana.toml; do
  echo "[kibana] waiting for confd to refresh config (waiting for ElasticSearch to be available)"
  sleep 5
done

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  exec /opt/kibana/bin/kibana "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
