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

# Fail hard, include pipelines
set -eo pipefail

# Set some environment variables
KIBANA_CONFD_CFG="/etc/confd/conf.d/kibana.toml"
KIBANA_CONFD_TMPL="/etc/confd/templates/kibana.yml.tmpl"
KIBANA_CFG_FILE="/opt/kibana/config/kibana.yml"

validateURL() {
  # Use URL if provided
  if [ ! -z "$ES_URL" ]; then
    echo "[kibana] Using $ES_URL as value for elasticsearch_url."
    sed -i "s|^elasticsearch_url: .*|elasticsearch_url: \"http:\/\/$ES_URL\"|g" -e ${KIBANA_CFG_FILE}
  fi
}

configKV() {
  # Set environment for KV usage
  ES_CLUSTER=${ES_CLUSTER:-"es01"}
  if [ ! -z "$KV_TYPE" ]; then
    KV_HOST=${KV_HOST:-localhost}
    if [ "$KV_TYPE" = "etcd" ]; then
      # Set as default for etcd unless otherwise stated
      KV_PORT=${KV_PORT:-4001}
    elif [ "$KV_TYPE" = "consul" ]; then
      # Set as default for consul unless otherwise stated
      KV_PORT=${KV_PORT:-8500}
    else
      echo "[kibana] Invalid KV_TYPE. Valid values are etcd and consul."
      exit 1
    fi
    KV_URL=${KV_HOST}:${KV_PORT}

    sed -i "s|es01|$ES_CLUSTER|g" -e ${KIBANA_CONFD_CFG}
    sed -i "s|es01|$ES_CLUSTER|g" -e ${KIBANA_CONFD_TMPL}

    echo "[kibana] booting container using $KV_TYPE KV store and $ES_CLUSTER ES cluster name."

    # Loop every 5 seconds until confd has updated the initial config
    until confd -onetime -backend $KV_TYPE -node $KV_URL -config-file ${KIBANA_CONFD_CFG}; do
      echo "[kibana] waiting for confd to refresh config (waiting for ElasticSearch to be available)"
      sleep 5
    done

    # Put continual polling on `confd` process in the background to watch for any changes every 10 seconds.
    confd -interval 10 -backend $KV_TYPE -node $KV_URL -config-file ${KIBANA_CONFD_CFG} &
    echo "[kibana] confd is now monitoring $KV_TYPE for any changes..."
  fi
}

validateURL
configKV

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  echo "[kibana] Starting Kibana service..."
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
  #exec /opt/kibana/bin/kibana "$@"
fi

# As argument is not Elasticsearch, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
