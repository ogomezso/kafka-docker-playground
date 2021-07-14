#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh

CONFIG_FILE=~/.ccloud/config

if [ ! -f ${CONFIG_FILE} ]
then
     logerror "ERROR: ${CONFIG_FILE} is not set"
     exit 1
fi

${DIR}/../ccloud-demo/ccloud-generate-env-vars.sh ${CONFIG_FILE}

if [ -f /tmp/delta_configs/env.delta ]
then
     source /tmp/delta_configs/env.delta
else
     logerror "ERROR: /tmp/delta_configs/env.delta has not been generated"
     exit 1
fi

# generate producer.js
sed -e "s|:BOOTSTRAP_SERVERS:|$BOOTSTRAP_SERVERS|g" \
    -e "s|:CLOUD_KEY:|$CLOUD_KEY|g" \
    -e "s|:CLOUD_SECRET:|$CLOUD_SECRET|g" \
    ${DIR}/producer-template-repro-connection-issues.js > ${DIR}/producer.js
# generate consumer.js
sed -e "s|:BOOTSTRAP_SERVERS:|$BOOTSTRAP_SERVERS|g" \
    -e "s|:CLOUD_KEY:|$CLOUD_KEY|g" \
    -e "s|:CLOUD_SECRET:|$CLOUD_SECRET|g" \
    ${DIR}/consumer-template.js > ${DIR}/consumer.js

log "Building docker image"
docker build -t vdesabou/kafkajs-ccloud-example-docker .

set +e
docker rm -f kafkajs-ccloud-consumer
set -e
log "Starting consumer. Logs are in consumer.log."
docker run -i --name kafkajs-ccloud-consumer vdesabou/kafkajs-ccloud-example-docker node /usr/src/app/consumer.js > consumer.log 2>&1 &

set +e
docker rm -f kafkajs-ccloud-producer
set -e
log "Starting producer"
docker run -i --name kafkajs-ccloud-producer vdesabou/kafkajs-ccloud-example-docker node /usr/src/app/producer.js > producer.log 2>&1 &

sleep 10

docker exec --privileged --user root kafkajs-ccloud-producer sh -c "iptables -A OUTPUT -p tcp --dport 9092 -j DROP"
docker exec --privileged --user root kafkajs-ccloud-producer sh -c "iptables -A INPUT -p tcp --dport 9092 -j DROP"
#docker exec --privileged --user root kafkajs-ccloud-producer sh -c "iptables -D OUTPUT -p tcp --dport 9092 -j DROP"