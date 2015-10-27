#!/usr/bin/env bash
# Kibana startup file.

# Setup shutdown handlers
pid=0
trap 'shutdown_handler' SIGTERM SIGINT

# Fail hard, include pipelines
#set -eo pipefail

# Set environment
KIBANA_CFG_FILE="/opt/kibana/config/kibana.yml"

if [ -z "$KIBANA_ELASTICSEARCH_URL" ]; then
  echo "$(date +"[%F %X,000]")[WARN ][action.admin.container    ] environment variable KIBANA_ELASTICSEARCH_URL not set"
  exit 1
fi
echo "$(date +"[%F %X,000]")[INFO ][action.admin.container    ] KIBANA_ELASTICSEARCH_URL=${KIBANA_ELASTICSEARCH_URL}"

# Download the config file if given a URL
if [ ! -z ${KIBANA_CFG_URL} ]; then
  curl -sSL --output ${KIBANA_CFG_FILE} ${KIBANA_CFG_URL}
  if [ $? -ne 0 ]; then
    echo "$(date +"[%F %X,000]")[WARN ][action.admin.container    ] Unable to download file ${KIBANA_CFG_URL}"
    exit 1
  fi
fi

# Reset/set to value to avoid errors in env processing
KIBANA_CFG_URL=${KIBANA_CFG_FILE}

shutdown_handler() {
  # Handle Docker shutdown signals to allow correct exit codes upon container shutdown
  echo "$(date +"[%F %X,000]")[INFO ][action.admin.container.shutdown   ] Requesting container shutdown"
  kill -SIGINT "$pid"
  echo "$(date +"[%F %X,000]")[INFO ][action.admin.container.shutdown   ] Container stopped"
  exit 0
}

# Process environment variables
for VAR in `env`; do
  if [[ "$VAR" =~ ^KIBANA_ && ! "$VAR" =~ ^KIBANA_CFG_ && ! "$VAR" =~ ^KIBANA_VERSION && ! "$VAR" =~ ^KIBANA_HOME && ! "$VAR" =~ ^KIBANA_USER && ! "$VAR" =~ ^KIBANA_GROUP ]]; then
    KIBANA_CONFIG_VAR=$(echo "$VAR" | sed -r "s/KIBANA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]')
    KIBANA_ENV_VAR=$(echo "$VAR" | sed -r "s/(.*)=.*/\1/g")

    if egrep -q "(^|^#)$KIBANA_CONFIG_VAR" $KIBANA_CFG_FILE; then
      # No config values may contain an '@' char. Below is due to bug otherwise seen.
      sed -r -i "s@(^|^#)($KIBANA_CONFIG_VAR): (.*)@\2: ${!KIBANA_ENV_VAR}@g" $KIBANA_CFG_FILE
    else
      echo "$KIBANA_CONFIG_VAR: ${!KIBANA_ENV_VAR}" >> $KIBANA_CFG_FILE
    fi
  fi
done

# If there are any arguments then we want to run those instead
if [ -z $1 ]; then
  exec /opt/kibana/bin/kibana &
  pid=$!
  echo "$(date +"[%F %X,000]")[INFO ][action.admin.container.startup    ] Started with PID: ${pid}"
  wait ${pid}
  trap - SIGTERM SIGINT
  wait ${pid}
else
  exec "$@"
fi
