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
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-$KIBANA_VERSION.tar.gz \
  && tar zxf kibana-$KIBANA_VERSION.tar.gz \
  && rm -f kibana-$KIBANA_VERSION.tar.gz \
  && ln -s kibana-$KIBANA_VERSION kibana

# Copy in kibana.yml file for verion 4.x
##COPY config/kibana.yml /opt/kibana/conf/kibana.yml
# Setup for Kibana 3.x using config.
RUN sed -i -e 's/elasticsearch: */elasticsearch: "http://localhost:80"/' /var/www/kibana/config.js

# Setup Kibana dashboards
##COPY dashboards/ /opt/kibana/app/dashboards/
RUN mv /var/www/kibana/app/dashboards/default.json /var/www/kibana/app/dashboards/default-bkup.json \
    && cp/var/www/kibana/app/dashboards/logstash.json /var/www/kibana/app/dashboards/default.json

# nginx installation - used for proxy/authention for Kibana
RUN wget http://nginx.org/keys/nginx_signing.key \
    && apt-key -y COPY nginx_signing.key \
    && cat "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list \
RUN apt-get -y update && apt-get -y install \
    apache2-utils \
    nginx 

# Expose persistent nginx configuration storage area
##VOLUME ["/etc/nginx/nginx.d"]

COPY conf/nginx-kibana.conf /etc/nginx/nginx.d/nginx-kibana.conf
COPY conf/kibana.localhost.htpasswd /etc/nginx/conf.d/kibana.localhost.htpasswd

# Listen for connections on HTTP port/interface: 80
EXPOSE 80
