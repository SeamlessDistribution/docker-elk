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

if [ -n "$REDIS_HOST" ]; then
    sed -ri "s|__REDIS_HOST__|${REDIS_HOST}|" /logstash/config/logstash.conf
else
    sed -ri "s|__REDIS_HOST__|localhost|" /logstash/config/logstash.conf
fi

if [ -n "$ELASTICSEARCH_HOST" ]; then
    sed -ri "s|__ELASTICSEARCH_HOST__|${ELASTICSEARCH_HOST}|" /logstash/config/logstash.conf
else
    sed -ri "s|__ELASTICSEARCH_HOST__|localhost|" /logstash/config/logstash.conf
fi



if [ -z "$1" ]; then
    /logstash/bin/logstash -f /logstash/config/   &

    /elasticsearch/bin/elasticsearch
else
    case $1 in
        elasticsearch)
            /elasticsearch/bin/elasticsearch
            ;;
        logstash)
            /logstash/bin/logstash -f /logstash/config/
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