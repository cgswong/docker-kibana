# ################################################################
# NAME: Dockerfile
# DESC: Docker file to create Kibana image.
#
# LOG:
# yyyy/mm/dd [name] [version]: [notes]
# 2015/02/05 cgwong v1.0.0: Use minimal JDK 8 base image. Re-create.
# ################################################################

FROM cgswong/java:oracleJDK8
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Variables
ENV KIBANA_VERSION 4.0.0-beta3
ENV KIBANA_BASE /opt
ENV KIBANA_HOME ${KIBANA_BASE}/kibana
ENV KIBANA_EXEC /usr/local/bin/kibana.sh
ENV KIBANA_USER kibana
ENV KIBANA_GROUP kibana

# Install Kibana
WORKDIR ${KIBANA_BASE}
RUN apt-get -yq update && DEBIAN_FRONTEND=noninteractive apt-get -yq install \
  curl \
#  supervisor \
  && apt-get -y clean && apt-get -y autoclean && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && curl -s https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}.tar.gz | tar zxf - \
  && ln -s kibana-${KIBANA_VERSION} kibana \
  && curl -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.6.3/confd-0.6.3-linux-amd64 \
  && chmod +x /usr/local/bin/confd

# Expose volumes
VOLUME ["${KIBANA_HOME}/config"]

# Copy in files and process user/group permissions
COPY src/ /
RUN groupadd -r ${KIBANA_GROUP} \
  && useradd -M -r -d ${KIBANA_HOME} -g ${KIBANA_GROUP} -c "Kibana Service User" -s /bin/false ${KIBANA_USER} \
  && chown -R ${KIBANA_USER}:${KIBANA_GROUP} ${ES_HOME}/ ${KIBANA_EXEC} \
  && chmod +x ${KIBANA_EXEC}

# Listen for connections on HTTP port/interface: 80
EXPOSE 5601

# Define default command.
CMD ["/usr/local/bin/kibana.sh"]
