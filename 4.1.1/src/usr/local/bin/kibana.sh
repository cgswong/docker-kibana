#!/bin/bash
# #################################################################
# DESC: Kibana startup file.
# #################################################################

# Fail hard, include pipelines
#set -eo pipefail

# Set environment
KIBANA_CFG_FILE="/opt/kibana/config/kibana.yml"

if [ -z "$KIBANA_ELASTICSEARCH_URL" ]; then
  echo "KIBANA_ELASTICSEARCH_URL not set, exiting."
  exit 1
fi
echo "KIBANA_ELASTICSEARCH_URL=${KIBANA_ELASTICSEARCH_URL}"

# Download the config file if given a URL
if [ ! -z ${KIBANA_CFG_URL} ]; then
  curl --location --silent --insecure --output ${KIBANA_CFG_FILE} ${KIBANA_CFG_URL}
  if [ $? -ne 0 ]; then
    echo "[KIBANA] Unable to download file ${KIBANA_CFG_URL}."
    exit 1
  fi
fi

# Reset/set to value to avoid errors in env processing
KIBANA_CFG_URL=${KIBANA_CFG_FILE}

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
  /opt/kibana/bin/kibana
else
  exec "$@"
fi
