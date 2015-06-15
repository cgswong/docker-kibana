# ################################################################
# DESC: Docker file to create Kibana image.
# ################################################################

FROM alpine:latest
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

# Variables
ENV KIBANA_VERSION 4.0.2
ENV KIBANA_HOME /opt/kibana
ENV KIBANA_USER kibana
ENV KIBANA_GROUP kibana

# Install requirements and Kibana
RUN apk --update add \
      curl \
      bash && \
    mkdir -p ${ES_VOL}/data ${ES_VOL}/logs ${ES_VOL}/plugins ${ES_VOL}/work ${ES_VOL}/config ${JAVA_BASE} /opt &&\
    curl --silent --insecure --location https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz | tar zxf - -C /opt &&\
    ln -s kibana-${KIBANA_VERSION}-linux-x64 ${KIBANA_HOME} &&\
    addgroup ${KIBANA_GROUP} &&\
    adduser -h ${KIBANA_HOME} -D -s /bin/bash -G ${KIBANA_GROUP} ${KIBANA_USER} &&\
    chown -R ${KIBANA_USER}:${KIBANA_GROUP} ${KIBANA_HOME}/ ${KIBANA_VOL} &&\

# Expose volumes
VOLUME ["${KIBANA_HOME}/config"]

# Configure environment
COPY src/ /

# Listen for 5601/tcp (http)
EXPOSE 5601

# Start container
ENTRYPOINT ["/usr/local/bin/kibana.sh"]
CMD [""]
