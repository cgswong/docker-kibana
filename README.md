## Docker Kibana

This is a configurable [Kibana](https://www.elastic.co/products/kibana) [Docker](https://www.docker.com/) built using [Docker's automated build process](https://registry.hub.docker.com/u/cgswong/kibana/) and published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

It is usually the front-end visualization component for an **ELK stack**. That is, [Elasticsearch](https://www.elastic.co/products/elasticsearch), [Logstash](https://www.elastic.co/products/logstash) and [Kibana](https://www.elastic.co/products/kibana) .


### How to use this image
To start a basic container, specify a URL (hostname/IP and port) for a target Elasticsearch node to connect using `--env KIBANA_ELASTICSEARCH_URL=http://[hostname_or_ipv4]:[port]`. For example:

```sh
docker run --name kibana \
  --publish 5601:5601 \
  --env KIBANA_ELASTICSEARCH_URL=http://elasticsearch.example.com:9200 \
  cgswong/kibana
```

> Note that for connecting to an Elasticsearch cluster you should be using a proxy node or load balancer.

### Additional Configuration
Within the image the port `5601` is exposed for host mapping. The volume `/opt/kibana/config` is also exposed such that you can use your own configuration file via a host mounted volume. However, you can also download your own configuration file via the `KIBANA_CFG_URL` environment variable. For example:

```sh
docker run --name kibana \
  --publish 5601:5601 \
  --env KIBANA_ELASTICSEARCH_URL=http://elasticsearch.example.com:9200 \
  --env KIBANA_CFG_URL=http://pastebin.com/hig0bnm9
  cgswong/kibana
```

Environment variables are accepted as a means to provide further configuration by reading those starting with `KIBANA_`. Any matching variables will get added to Kibana's configuration file, `kibana.yml' by:

  1. Removing the `KIBANA_` prefix
  2. Transforming to lower case

This is how we actually use `KIBANA_ELASTICSEARCH_URL`, by transforming it into `elasticsearch_url` within `kibana.yml`. The environment variable substitution also works for your configuration file (host mounted or remote download) as well.
