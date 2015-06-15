#!/usr/bin/env bats

setup() {
  # Setup environment
  host=$(echo $DOCKER_HOST|cut -d":" -f2|sed -e 's/\/\///')
}

teardown () {
  # Cleanup
  docker stop ${IMAGE} >/dev/null
  docker rm ${IMAGE} >/dev/null
}

@test "Confirm installed Kibana version" {
  run docker run --name ${IMAGE} ${IMAGE}:${TAG} /opt/kibana/bin/kibana -v
  [[ $output =~ "Version: ${TAG}" ]]
}

@test "Confirm Kibana is available" {
  run docker run -d --name ${IMAGE} -P ${IMAGE}:${TAG}
  port=$(docker port ${IMAGE} | grep 9200 | cut -d":" -f2)
  sleep 10
  curl --retry 10 --retry-delay 5 --location --silent http://${host}:${port}
  [ $status -eq 0 ]
}
