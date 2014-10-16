# ################################################################
# NAME: Dockerfile
# DESC: Docker file to create Kibana image.
#
# LOG:
# yyyy/mm/dd [name] [version]: [notes]
# 2014/10/15 cgwong [v0.1.0]: Initial creation.
# ################################################################

FROM dockerfile/java:oracle_java7
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Install Kibana
##ENV KIBANA_VERSION 4.0.0-beta1.1
##ENV KIBANA_VERSION 3.1.1
ENV KIBANA_VERSION latest
RUN mkdir -p /var/www
WORKDIR /var/www
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-$KIBANA_VERSION.tar.gz && \
  tar zxf kibana-$KIBANA_VERSION.tar.gz && rm -f kibana-$KIBANA_VERSION.tar.gz && ln -s kibana-$KIBANA_VERSION kibana

# Copy in kibana.yml file for verion 4.x
##COPY config/kibana.yml /opt/kibana/conf/kibana.yml
# Setup 
RUN sed -i -e 's/elasticsearch: */elasticsearch: "http://localhost:80"/' /var/www/kibana/config.js

# Setup Kibana dashboards
##COPY dashboards/ /opt/kibana/app/dashboards/
RUN ["mv", "/var/www/kibana/app/dashboards/default.json", "/var/www/kibana/app/dashboards/default-bkup.json"]
RUN ["cp", "/var/www/kibana/app/dashboards/logstash.json", "/var/www/kibana/app/dashboards/default.json"]

USER nobody
WORKDIR /tmp
CMD ["/usr/bin/twistd", "-n", "web", "--path", "/var/www/kibana"]

# HTTP interface
EXPOSE 8080
