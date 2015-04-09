FROM        seqr/jre:8
MAINTAINER Lars Larsson <lars.larsson@seamless.se>

ENV LOGSTASH_VERSION 1.4.2
ENV ELASTICSEARCH_VERSION 1.5.1
ENV BIGDESK_VERSION 2.5.0
ENV KIBANA_VERSION 4.0.1
#ENV CLOUDAWS_VERSION 2.3.0

RUN curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.crt \
    -O https://download.elasticsearch.org/logstash/logstash/logstash-$LOGSTASH_VERSION.tar.gz && \
gunzip logstash-$LOGSTASH_VERSION.tar.gz && \
tar xvf logstash-$LOGSTASH_VERSION.tar && \
mv logstash-$LOGSTASH_VERSION /logstash && \
rm -Rf logstash-$LOGSTASH_VERSION.tar

ADD logstash_config /logstash/config

# Install ElasticSearch.
RUN \
  cd /tmp && \
  curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.crt \
  -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  gunzip elasticsearch-$ELASTICSEARCH_VERSION.tar.gz && \
  tar xvf elasticsearch-$ELASTICSEARCH_VERSION.tar && \
  rm -f elasticsearch-$ELASTICSEARCH_VERSION.tar && \
  mv /tmp/elasticsearch-$ELASTICSEARCH_VERSION /elasticsearch

# Install some plugins
RUN /elasticsearch/bin/plugin -install lukas-vlcek/bigdesk/$BIGDESK_VERSION
RUN /elasticsearch/bin/plugin -install mobz/elasticsearch-head
RUN /elasticsearch/bin/plugin -install royrusso/elasticsearch-HQ
#RUN /elasticsearch/bin/plugin --install elasticsearch/elasticsearch-cloud-aws/$CLOUDAWS_VERSION

ADD elasticsearch_config /elasticsearch/config

# Install Kibana
RUN cd /tmp \
    && curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.crt \
     -O https://download.elasticsearch.org/kibana/kibana/kibana-$KIBANA_VERSION-linux-x64.tar.gz \
    && gunzip kibana-*.tar.gz \
    && tar xf kibana-*.tar \
    && rm kibana-*.tar \
    && mv kibana-* /opt/kibana

RUN opkg-install libstdcpp

RUN adduser -D -s /sbin/nologin kibana

ADD run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]