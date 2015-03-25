#!/bin/bash
# #################################################################
# NAME: kibana.sh
# DESC: Kibana startup file.
#
# LOG:
# yyyy/mm/dd [user] [version]: [notes]
# 2015/02/05 cgwong v1.0.0: re- creation
# 2015/02/05 cgwong v1.0.1: Modify toml file name.
# 2015/03/25 cgwong v1.1.0: Enable using command line variable, ES_URL, as option for configuration.
# #################################################################

# Fail hard and fast
set -eo pipefail

# Set environment for ES URL and use if enabled
if [ ! -z $ES_URL ]; then
  echo "[kibana] Using $ES_URL as value for elasticsearch_url."
  sed -ie "s/elasticsearch_url: \"http:\/\/localhost:9200\"/elasticsearch_url: \"http:\/\/$ES_URL\"/g" /opt/kibana/config/kibana.yml
else
  # Set environment for KV usage
  ES_CLUSTER=${ES_CLUSTER:-"es01"}
  KV_TYPE=${KV_TYPE:-etcd}
  KV_HOST=${KV_HOST:-localhost}
  if [ "$KV_TYPE" = "etcd" ]; then
    # Set as default for etcd unless otherwise stated
    KV_PORT=${KV_PORT:-4001}
  else
    # Set as default for consul unless otherwise stated
    KV_PORT=${KV_PORT:-8500}
  fi
  KV_URL=${KV_HOST}:${KV_PORT}

  [ ! -z $ES_CLUSTER ] && sed -ie "s/es01/$ES_CLUSTER/g" /etc/confd/conf.d/kibana.toml && sed -ie "s/es01/$ES_CLUSTER/g" /etc/confd/templates/kibana.yml.tmpl

  echo "[kibana] booting container using $KV_TYPE KV store and $ES_CLUSTER ES cluster name."

  # Loop every 5 seconds until confd has updated the initial config
  until confd -onetime -backend $KV_TYPE -node $KV_URL -config-file /etc/confd/conf.d/kibana.toml; do
    echo "[kibana] waiting for confd to refresh config (waiting for ElasticSearch to be available)"
    sleep 5
  done

  # Put continual polling on `confd` process in the background to watch for any changes every 10 seconds.
  confd -interval 10 -backend $KV_TYPE -node $KV_URL -config-file /etc/confd/conf.d/kibana.toml &
  echo "[kibana] confd is now monitoring $KV_TYPE for any changes..."
fi

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  echo "[kibana] Starting Kibana service..."
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
  #exec /opt/kibana/bin/kibana "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
