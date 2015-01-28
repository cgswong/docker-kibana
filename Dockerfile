# ################################################################
# NAME: Dockerfile
# DESC: Docker file to create Kibana image.
#
# LOG:
# yyyy/mm/dd [name] [version]: [notes]
# 2014/10/15 cgwong [v0.1.0]: Initial creation.
# 2014/11/11 cgwong v0.2.0: Updated sed command.
#                           Added environment variable for nginx config directory.
# 2014/12/03 cgwong v0.2.1: Updated Kibana version. Switch to specific nginx version.
# 2014/12/04 cgwong v0.2.2: Introduce more environment variables. Corrected bug in dashboard copy.
# 2015/01/08 cgwong v1.0.0: Added another variable.
# 2015/01/09 cgwong v1.1.0: Updated to nginx 1.7.9-1.
# 2015/01/14 cgwong v1.2.0: Updated variables.
#                           Removed Kibana 4 references to other branch.
# 2015/01/28 cgwong v1.3.0: Corrected ENTRYPOINT variable substitution.
# ################################################################

FROM dockerfile/ubuntu
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Install Kibana
ENV KIBANA_VERSION 3.1.2
ENV KIBANA_BASE /var/www
ENV KIBANA_HOME ${KIBANA_BASE}/kibana
ENV KIBANA_EXEC /usr/local/bin/kibana.sh

RUN mkdir -p ${KIBANA_BASE}
WORKDIR ${KIBANA_BASE}
RUN curl -s https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}.tar.gz | tar zx -C ${KIBANA_BASE} \
  && ln -s kibana-${KIBANA_VERSION} kibana

# Setup Kibana dashboards
COPY dashboards/ ${KIBANA_HOME}/app/dashboards/
RUN mv ${KIBANA_HOME}/app/dashboards/default.json ${KIBANA_HOME}/app/dashboards/default-org.json \
    && cp ${KIBANA_HOME}/app/dashboards/logstash.json ${KIBANA_HOME}/app/dashboards/default.json

# Setup nginx for proxy/authention for Kibana
ENV NGINX_VERSION 1.7.9-1~trusty
ENV NGINX_CFG_DIR /etc/nginx/conf.d
RUN wget -qO - http://nginx.org/keys/nginx_signing.key | sudo apt-key add -
RUN echo "deb http://nginx.org/packages/mainline/ubuntu/ trusty nginx" >> /etc/apt/sources.list
RUN apt-get -y update && apt-get -y install \
    apache2-utils \
    nginx=${NGINX_VERSION}

# Forward standard out and error logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# Expose persistent nginx configuration storage area
VOLUME ["${NGINX_CFG_DIR}"]

# Copy config and user password file into image
COPY conf/nginx-kibana.conf ${NGINX_CFG_DIR}/nginx-kibana.conf
COPY conf/kibana.localhost.htpasswd ${NGINX_CFG_DIR}/kibana.localhost.htpasswd
COPY kibana.sh ${KIBANA_EXEC}
RUN chmod +x ${KIBANA_EXEC}

# Listen for connections on HTTP port/interface: 80
EXPOSE 80
# Listen for SSL connections on HTTPS port/interface: 443
EXPOSE 443

# Define default command.
ENTRYPOINT ["/usr/local/bin/kibana.sh"]
