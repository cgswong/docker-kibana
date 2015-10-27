#! /usr/bin/env bats

@test "Check Kibana build" {
  run docker build -t ${DOCKER_IMAGE}:${VERSION} ${VERSION}
  [ $status = 0 ]
}
