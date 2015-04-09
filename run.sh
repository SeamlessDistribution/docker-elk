#!/bin/bash

sed -ri "s|__TAG_ENV__|${TAG_ENV}|" /elasticsearch/config/elasticsearch.yml
sed -ri "s|__AWS_ACCESS_KEY__|${AWS_ACCESS_KEY}|" /elasticsearch/config/elasticsearch.yml
sed -ri "s|__AWS_SECRET_KEY__|${AWS_SECRET_KEY}|" /elasticsearch/config/elasticsearch.yml
sed -ri "s|__AWS_REGION__|${AWS_REGION}|" /elasticsearch/config/elasticsearch.yml

sed -ri "s|__REDIS_HOST__|${REDIS_HOST}|" /logstash/config/logstash.conf




/logstash/bin/logstash -f /logstash/config/   &

/elasticsearch/bin/elasticsearch