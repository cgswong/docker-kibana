# ################################################################
# NAME: Dockerfile
# DESC: Docker file to create Kibana image.
#
# LOG:
# yyyy/mm/dd [name] [version]: [notes]
# 2014/10/15 cgwong [v0.1.0]: Initial creation.
# 2014/11/11 cgwong v0.2.0: Updated sed command.
#                           Added environment variable for nginx config directory.
# ################################################################

FROM dockerfile/ubuntu
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Install Kibana
##ENV KIBANA_VERSION 4.0.0-beta1.1
ENV KIBANA_VERSION 3.1.1
##ENV KIBANA_VERSION latest
RUN mkdir -p /var/www
WORKDIR /var/www
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}.tar.gz \
  && tar zxf kibana-${KIBANA_VERSION}.tar.gz \
  && rm -f kibana-${KIBANA_VERSION}.tar.gz \
  && ln -s kibana-${KIBANA_VERSION} kibana

# Setup Kibana dashboards
COPY dashboards/ /opt/kibana/app/dashboards/
RUN mv /var/www/kibana/app/dashboards/default.json /var/www/kibana/app/dashboards/default-org.json \
    && cp /var/www/kibana/app/dashboards/logstash.json /var/www/kibana/app/dashboards/default.json

# Setup nginx for proxy/authention for Kibana
##ENV NGINX_VERSION 1.7.6
##ENV NGINX_VERSION latest
ENV NGINX_CFG_DIR /etc/nginx/conf.d
RUN wget -qO - http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install \
    apache2-utils \
    nginx

# Expose persistent nginx configuration storage area
VOLUME ["${NGINX_CFG_DIR}"]

# Copy config and user password file into image
COPY conf/nginx-kibana.conf ${NGINX_CFG_DIR}/nginx-kibana.conf
COPY conf/kibana.localhost.htpasswd ${NGINX_CFG_DIR}/kibana.localhost.htpasswd
COPY kibana.sh /usr/local/bin/kibana.sh

# Copy in kibana.yml file for verion 4.x
##COPY config/kibana.yml /opt/kibana/conf/kibana.yml
# Setup for Kibana 3.x using config.js
##RUN sed -e 's/"+window.location.hostname+"/localhost/' -i /var/www/kibana/config.js \
##    && cp /var/www/kibana/config.js /usr/share/nginx/html/config.js

# Listen for connections on HTTP port/interface: 80
EXPOSE 80

# Define default command.
##CMD ["nginx"]
ENTRYPOINT ["/usr/local/bin/kibana.sh"]
