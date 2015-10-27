#!/usr/bin/env bats

setup() {
  # Launch required ES container
  docker run -d --name eskibana -P monsantoco/elasticsearch:latest >/dev/null
  es_port=$(docker inspect -f '{{(index (index .NetworkSettings.Ports "9200/tcp") 0).HostPort}}' eskibana)
  es_url="http://${DOCKER_HOST_IP}:${es_port}"
  sleep 10
  # Launch container
  docker run -d --name ${DOCKER_IMAGE} -P --env KIBANA_ELASTICSEARCH_URL=$es_url ${DOCKER_IMAGE}:${VERSION} >/dev/null
  port=$(docker inspect -f '{{(index (index .NetworkSettings.Ports "5601/tcp") 0).HostPort}}' ${DOCKER_IMAGE})
  url="http://${DOCKER_HOST_IP}:${port}"
}

teardown () {
  # Cleanup
  docker stop ${DOCKER_IMAGE} >/dev/null
  docker rm -f ${DOCKER_IMAGE} >/dev/null
  docker stop eskibana >/dev/null
  docker rm eskibana >/dev/null
}

@test "Confirm Kibana version ${VERSION}" {
  sleep 10
  run curl --retry 10 --retry-delay 5 --silent --location $url
  [[ "$output" =~ "KIBANA_VERSION='${VERSION}'" ]]
}

@test "Confirm Kibana is available" {
  sleep 10
  run curl --retry 10 --retry-delay 5 --silent --output /dev/null --location --head --write-out "%{http_code}" $url
  [ $status -eq 0 ]
  [[ "$output" =~ "200" ]]
}
