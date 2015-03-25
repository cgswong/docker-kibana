## Docker Kibana

This is a configurable [Kibana](https://www.elastic.co/products/kibana) [Docker](https://www.docker.com/) built using [Docker's automated build process](https://registry.hub.docker.com/u/cgswong/kibana/) and published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

It is usually the front-end visualization component for an **ELK stack**. That is, [Elasticsearch](https://www.elastic.co/products/elasticsearch), [Logstash](https://www.elastic.co/products/logstash) and [Kibana](https://www.elastic.co/products/kibana) .


### How to use this image
To start a basic container, specify a URL (hostname/IP and port) for a target Elasticsearch node to connect using `-e ES_URL=<hostname/ipv4>:<port>` or `--env ES_URL=<hostname/ipv4>:<port>`. If following best practices you should be using a proxy node but you can connect via any proxy or data node.

```sh
docker run --name %p \
  --publish 5601:5601 \
  --env ES_URL=elasticsearch.example.com:9200
  cgswong/kibana
```

For more advanced usage involving **Service Discovery** (**etcd** and **consul** are supported) you will need to use environment variables:

- ES_CLUSTER: Name of Elasticsearch cluster
- KV_TYPE: Type of KV store backend. Currently only `etcd` (default) and `consul` are supported.
- KV_HOST: hostname/ipv4 address of service discovery backend.
- KV_PORT: Port number of KV store. Defaults to 4001 for etcd and 8500 for consul.

This usage is mutually exclusive with the ES_URL variable, which takes precedence.

#### Etcd backend
```sh
docker run --name %p \
  --publish 5601:5601 \
  --env ES_CLUSTER=es_cluster1 \
  --env KV_HOST=172.17.8.101 \
  cgswong/kibana
```

#### Consul backend
```sh
docker run --name %p \
  --publish 5601:5601 \
  --env ES_CLUSTER=es_cluster1 \
  --env KV_HOST=172.17.8.101 \
  --env KV_TYPE=consul \
  cgswong/kibana
```

In the service discovery use case, we are watching the key below `/services/logging/es/<es_cluster>/proxy` to detect the hostname/ipv4 and port to use when connecting to the specified ES cluster. Any changes in the key or value will trigger a restart of Kibana with the updated key or value.

> Note that port 5601 has been exposed for client connectivity. Also, there is currently no security used, but this will be included in a future release involving proxy authentication (using nginx).

Sample systemd unit files are provided for incorporating this image in a full working model.
