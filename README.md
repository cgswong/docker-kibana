## Kibana Dockerfile

This repository contains a **Dockerfile** of [Kibana](http://www.elasticsearch.org/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/cgswong/kibana/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

It is usually the front-end for Elasticsearch but can be used for other purposes.


### Base Docker Image

* [cgswong/java:orajdk8](https://registry.hub.docker.com/u/cgswong/java/)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/cgswong/kibana/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull cgswong/kibana`

  (alternatively, you can build an image from Dockerfile: `docker build -t="cgswong/kibana" github.com/cgswong/docker-kibana`)


### Usage
We use a basic Kibana 4 setup without any proxying. This container requires a dependent Elasticsearch container that registers itself within either an etcd or consul KV store, using the expected key of:

- `/services/logging/es/host`: IPV4 address of Elasticsearch host

We will wait until a subkey is present, then use **confd** to update the Kibana configuration file `$KIBANA_HOME/config/kibana.yml`, setting the value for `elasticsearch_url` with the key, then starting Kibana.

To use the default etcd KV backend:

```sh
source /etc/environment
docker run --rm --name kibana -p 5601:5601 -e KV_HOST=${COREOS_PRIVATE_IPV4} cgswong/kibana
```

To use consul as the KV backend:

```sh
source /etc/environment
docker run --rm --name kibana -p 5601:5601 -e KV_HOST=${COREOS_PRIVATE_IPV4} -e KV_TYPE=consul cgswong/kibana
```

After few seconds the container should start and you can open `http://<container_host>:5601` to see the result.

### Changing Defaults
A few environment variables can be passed via the Docker `-e` flag to do some further configuration:

  - KV_TYPE: Sets the type of KV store to use as the backend. Options are etcd (default) and consul.
  - KV_PORT: Sets the port used in connecting to the KV store which defaults to 4001 for etcd and 8500 for consul.

**Note: The startup procedures previously shown assume you are using CoreOS (with either etcd or consul as your KV store). If you are not using CoreOS then simply substitute the CoreOS specific statements with the appropriate OS specific equivalents.**
