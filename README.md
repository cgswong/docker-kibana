## Kibana Dockerfile

This repository contains **Dockerfile** of [Kibana](http://www.elasticsearch.org/) for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/cgswong/kibana/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).
It is usually the front-end for a Logstash and Elasticsearch stack but of course can be used for other purposes.


### Base Docker Image

* [dockerfile/ubuntu](http://dockerfile.github.io/#/ubuntu)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/cgswong/kibana/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull cgswong/kibana`

   (alternatively, you can build an image from Dockerfile: `docker build -t="cgswong/kibana" github.com/cgswong/docker-kibana`)


### Usage
The expectation is that this Kibana/nginx container will be linked with another container, namely Elasticsearch (with alias `es`). You can use a different configuration file via the `-v` flag when doing `docker run` to mount your own. To change the protocol from HTTP to HTTPS when connecting to the Elasticsearch container you can override the environment variable `ES_PORT_9200_TCP_PROTO` via the `-e` flag when doing `docker run`. To run the container:

```sh
docker run -d --link elasticsearch:es -p 80:80 --name kibana cgswong/kibana
```

#### Attach persistent/shared directories

  1. Create a mountable data directory `<data-dir>` on the host.

  2. Create nginx config for Kibana at `<data-dir>/nginx-kibana.conf`.

  3. Start a container by mounting data directory and specifying the custom configuration file:

    ```sh
    docker run -d --link elasticsearch:es -p 80:80 -v <data-dir>:/etc/nginx/conf.d --name kibana cgswong/kibana
    ```

After few seconds, open `http://<host>:80` to see the result.
