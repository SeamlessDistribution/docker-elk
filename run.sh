#!/bin/bash

if [ -n "$ES_M1" ]; then
    sed -ri "s|__M1__|${ES_M1}|" /elasticsearch/config/elasticsearch.yml
    sed -ri "s|__M2__|${ES_M2}|" /elasticsearch/config/elasticsearch.yml
    sed -ri "s|__M3__|${ES_M3}|" /elasticsearch/config/elasticsearch.yml
else
    sed -ri 's|discovery.zen.minimum_master_nodes: 2|discovery.zen.minimum_master_nodes: 1|' /elasticsearch/config/elasticsearch.yml
    sed -ri 's|discovery.zen.ping.unicast.hosts.*||' /elasticsearch/config/elasticsearch.yml
fi

if [ -n "$ES_NO_DATA" ]; then
    sed -ri 's|node.data: true|node.data: false|' /elasticsearch/config/elasticsearch.yml
fi

if [ -n "$ES_DATA_ONLY" ]; then
    sed -ri 's|node.master: true|node.master: false|' /elasticsearch/config/elasticsearch.yml
fi

export REDIS_HOST=${REDIS_HOST:-localhost}

sed -ri "s|__REDIS_HOST__|${REDIS_HOST}|" /logstash/config/logstash.conf


export ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST:-localhost}
export ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT:-9200}

sed -ri "s|__ELASTICSEARCH_HOST__|${ELASTICSEARCH_HOST}|" /logstash/config/logstash.conf
sed -i "s/^elasticsearch_url: .*$/elasticsearch_url: \"http:\/\/${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}\"/g" /opt/kibana/config/kibana.yml

if [ -z "$1" ]; then
    /logstash/bin/logstash -f /logstash/config/   &

    /bin/su kibana -s /bin/bash -c '/opt/kibana/bin/kibana' &

    /elasticsearch/bin/elasticsearch
else
    case $1 in
        elasticsearch)
            /elasticsearch/bin/elasticsearch
            ;;
        logstash)
            /logstash/bin/logstash -f /logstash/config/
            ;;
        kibana)
            /bin/su kibana -s /bin/bash -c '/opt/kibana/bin/kibana'
            ;;
        shell)
            /bin/bash
            ;;
        *)
            echo "$0 <elasticsearch|logstash|shell>"
            exit 1
            ;;
    esac
fi