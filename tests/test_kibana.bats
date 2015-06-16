#!/usr/bin/env bats

setup() {
  # Setup environment
  SLEEP=8
  host=$(echo $DOCKER_HOST|cut -d":" -f2|sed -e 's/\/\///')

  # Launch required ES container
  docker run -d --name eskibana -P cgswong/elasticsearch:latest >/dev/null
  es_port=$(docker port eskibana | grep 9200 | cut -d":" -f2)
  es_url="http://${host}:${es_port}"

  sleep $SLEEP

  # Launch container
  docker run -d --name ${IMAGE} -P --env KIBANA_ELASTICSEARCH_URL=$es_url ${IMAGE}:${TAG} >/dev/null
  port=$(docker port ${IMAGE} | grep 5601 | cut -d":" -f2)
  url="http://${host}:${port}"
}

teardown () {
  # Cleanup
  docker stop ${IMAGE} >/dev/null
  docker rm ${IMAGE} >/dev/null
  docker stop eskibana >/dev/null
  docker rm eskibana >/dev/null
}

@test "Confirm Kibana is available" {
  sleep $SLEEP
  run curl --retry 10 --retry-delay 5 --silent --output /dev/null --location --head --write-out "%{http_code}" $url
  [ $status -eq 0 ]
  [[ "$output" =~ "200" ]]
}

@test "Confirm Kibana version ${TAG}" {
  sleep $SLEEP
  run curl --retry 10 --retry-delay 5 --silent --location $url
  [[ "$output" =~ "KIBANA_VERSION='${TAG}'" ]]
}
