#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DIR}/../../scripts/utils.sh

create_or_get_oracle_image "LINUX.X64_193000_db_home.zip" "$(pwd)/ora-setup-scripts-cdb-table"

${DIR}/../../environment/plaintext/start.sh "${PWD}/docker-compose.plaintext.cdb-table.yml"


# Verify Oracle DB has started within MAX_WAIT seconds
MAX_WAIT=2500
CUR_WAIT=0
log "Waiting up to $MAX_WAIT seconds for Oracle DB to start"
docker container logs oracle > /tmp/out.txt 2>&1
while [[ ! $(cat /tmp/out.txt) =~ "DONE: Executing user defined scripts" ]]; do
sleep 10
docker container logs oracle > /tmp/out.txt 2>&1
CUR_WAIT=$(( CUR_WAIT+10 ))
if [[ "$CUR_WAIT" -gt "$MAX_WAIT" ]]; then
     logerror "ERROR: The logs in oracle container do not show 'DONE: Executing user defined scripts' after $MAX_WAIT seconds. Please troubleshoot with 'docker container ps' and 'docker container logs'.\n"
     exit 1
fi
done
log "Oracle DB has started!"

# Create a redo-log-topic. Please make sure you create a topic with the same name you will use for "redo.log.topic.name": "redo-log-topic"
# CC-13104
docker exec connect kafka-topics --create --topic redo-log-topic --bootstrap-server broker:9092 --replication-factor 1 --partitions 1 --config cleanup.policy=delete --config retention.ms=120960000
log "redo-log-topic is created"
sleep 5


log "Creating Oracle source connector"
curl -X PUT \
     -H "Content-Type: application/json" \
     --data '{
               "connector.class": "io.confluent.connect.oracle.cdc.OracleCdcSourceConnector",
               "tasks.max":2,
               "key.converter": "io.confluent.connect.avro.AvroConverter",
               "key.converter.schema.registry.url": "http://schema-registry:8081",
               "value.converter": "io.confluent.connect.avro.AvroConverter",
               "value.converter.schema.registry.url": "http://schema-registry:8081",
               "confluent.license": "",
               "confluent.topic.bootstrap.servers": "broker:9092",
               "confluent.topic.replication.factor": "1",
               "oracle.server": "oracle",
               "oracle.port": 1521,
               "oracle.sid": "ORCLCDB",
               "oracle.username": "C##MYUSER",
               "oracle.password": "mypassword",
               "start.from":"snapshot",
               "redo.log.topic.name": "redo-log-topic",
               "redo.log.consumer.bootstrap.servers":"broker:9092",
               "table.inclusion.regex": ".*CUSTOMERS.*",
               "table.topic.name.template": "${databaseName}.${schemaName}.${tableName}",
               "numeric.mapping": "best_fit",
               "connection.pool.max.size": 20,
               "redo.log.row.fetch.size":1,
               "oracle.dictionary.mode": "auto"
          }' \
     http://localhost:8083/connectors/cdc-oracle-source-cdb/config | jq .

log "Waiting 60s for connector to read existing data"
sleep 60

log "Update GRGR_NAME field"
docker exec -i oracle sqlplus C\#\#MYUSER/mypassword@//localhost:1521/ORCLCDB << EOF
  update CUSTOMERS set GRGR_NAME = 'VINCENT HAS UPDATED GRGR_NAME' where GRGR_CK = '1';
  exit;
EOF

log "Waiting 60s for connector to read new data"
sleep 60

log "Verifying topic ORCLCDB.C__MYUSER.CUSTOMERS: there should be 2 records"
set +e
timeout 60 docker exec connect kafka-avro-console-consumer -bootstrap-server broker:9092 --property schema.registry.url=http://schema-registry:8081 --topic ORCLCDB.C__MYUSER.CUSTOMERS --from-beginning --max-messages 2 > /tmp/result.log  2>&1
set -e
cat /tmp/result.log

set +e
log "Checking problematic field ATXR_SOURCE_ID, if it is different, problem is reproduced"
cat /tmp/result.log | jq .ATXR_SOURCE_ID
set -e

log "Verifying topic redo-log-topic: there should be 1 record"
timeout 60 docker exec connect kafka-avro-console-consumer -bootstrap-server broker:9092 --property schema.registry.url=http://schema-registry:8081 --topic redo-log-topic --from-beginning --max-messages 1

# results with 1.5.0 (ATXR_SOURCE_ID is same -6847804800000)
# results with 1.4.0 (ATXR_SOURCE_ID is not same, i.e -6847786800000 and -6847787038000)
# {
#     "ATXR_SOURCE_ID": -6847786800000,
#     "CICI_ID": "01",
#     "CRCY_ID": " ",
#     "CSCS_ID": " ",
#     "EXCD_ID": " ",
#     "GRGR_ADDR1": "VINCENT",
#     "GRGR_ADDR2": " ",
#     "GRGR_ADDR3": " ",
#     "GRGR_AUTONUM_IND": "Y",
#     "GRGR_BILL_LEVEL": "S",
#     "GRGR_BL_CONV_DT": -6847786800000,
#     "GRGR_CAP_BAT_STS": 0,
#     "GRGR_CAP_CONV_DT": -6847786800000,
#     "GRGR_CAP_IND": "Y",
#     "GRGR_CITY": "Dearborn",
#     "GRGR_CITY_XLOW": "dearborn",
#     "GRGR_CK": 1,
#     "GRGR_CONT_EFF_DT": -6847786800000,
#     "GRGR_CONV_DT": -6847786800000,
#     "GRGR_COUNTY": "Wayne",
#     "GRGR_CTRY_CD": "USA",
#     "GRGR_CURR_ANNV_DT": 253402232400000,
#     "GRGR_DEN_CHT_IND": "N",
#     "GRGR_EIN": " ",
#     "GRGR_EMAIL": " ",
#     "GRGR_ERIS_MMDD": 201,
#     "GRGR_EXTN_ADDR_IND": " ",
#     "GRGR_FAX": " ",
#     "GRGR_FAX_EXT": " ",
#     "GRGR_ID": "20001777",
#     "GRGR_ITS_CODE": " ",
#     "GRGR_LAST_CAP_DT": -6847786800000,
#     "GRGR_LMT_ADJ_MOS": 12,
#     "GRGR_LOCK_TOKEN": 1,
#     "GRGR_MCTR_LANG": "None",
#     "GRGR_MCTR_PTYP": " ",
#     "GRGR_MCTR_TRSN": " ",
#     "GRGR_MCTR_TYPE": "None",
#     "GRGR_MCTR_VIP": "None",
#     "GRGR_NAME": "VINCENT 1ST INSERT",
#     "GRGR_NAME_XLOW": "fayda za",
#     "GRGR_NEXT_ANNV_DT": 253402232400000,
#     "GRGR_ORIG_EFF_DT": 1548997200000,
#     "GRGR_PHONE": "3135629100",
#     "GRGR_PHONE_EXT": " ",
#     "GRGR_POL_NO": " ",
#     "GRGR_PREV_ANNV_DT": 253402232400000,
#     "GRGR_PUP_IND_NVL": "N",
#     "GRGR_RECD_DT": -6847786800000,
#     "GRGR_RENEW_MMDD": 201,
#     "GRGR_RNST_DT": -6847786800000,
#     "GRGR_RNST_TYPE": "N",
#     "GRGR_RNST_VAL": 0,
#     "GRGR_RUNOUT_DT": 253402232400000,
#     "GRGR_RUNOUT_EXCD": " ",
#     "GRGR_STATE": "MI",
#     "GRGR_STS": "AC",
#     "GRGR_TERM_DT": 253402232400000,
#     "GRGR_TERM_PREM_MOS": 0,
#     "GRGR_TOTAL_CONTR": 0,
#     "GRGR_TOTAL_ELIG": 0,
#     "GRGR_TOTAL_EMPL": 0,
#     "GRGR_TRANS_ACCEPT": " ",
#     "GRGR_UNDW_USUS_ID": " ",
#     "GRGR_ZIP": "48124",
#     "MCAR_AREA_ID": " ",
#     "PAGR_CK": 0,
#     "SYS_BITMAP_NVL": null,
#     "SYS_DBUSER_ID": {
#         "string": "FACETS"
#     },
#     "SYS_LAST_OFFSET_NVL": null,
#     "SYS_LAST_UPD_DTM": {
#         "long": 1601128097000
#     },
#     "SYS_USUS_ID": {
#         "string": "FACETS"
#     },
#     "WMDS_SEQ_NO": 0,
#     "current_ts": {
#         "string": "1640081964882"
#     },
#     "op_ts": null,
#     "op_type": {
#         "string": "R"
#     },
#     "row_id": null,
#     "scn": {
#         "string": "2160358"
#     },
#     "table": {
#         "string": "ORCLCDB.C##MYUSER.CUSTOMERS"
#     },
#     "username": null
# }


# and update:

# {
#     "ATXR_SOURCE_ID": -6847787038000,
#     "CICI_ID": "01",
#     "CRCY_ID": " ",
#     "CSCS_ID": " ",
#     "EXCD_ID": " ",
#     "GRGR_ADDR1": "VINCENT",
#     "GRGR_ADDR2": " ",
#     "GRGR_ADDR3": " ",
#     "GRGR_AUTONUM_IND": "Y",
#     "GRGR_BILL_LEVEL": "S",
#     "GRGR_BL_CONV_DT": -6847787038000,
#     "GRGR_CAP_BAT_STS": 0,
#     "GRGR_CAP_CONV_DT": -6847787038000,
#     "GRGR_CAP_IND": "Y",
#     "GRGR_CITY": "Dearborn",
#     "GRGR_CITY_XLOW": "dearborn",
#     "GRGR_CK": 1,
#     "GRGR_CONT_EFF_DT": -6847787038000,
#     "GRGR_CONV_DT": -6847787038000,
#     "GRGR_COUNTY": "Wayne",
#     "GRGR_CTRY_CD": "USA",
#     "GRGR_CURR_ANNV_DT": 253402232400000,
#     "GRGR_DEN_CHT_IND": "N",
#     "GRGR_EIN": " ",
#     "GRGR_EMAIL": " ",
#     "GRGR_ERIS_MMDD": 201,
#     "GRGR_EXTN_ADDR_IND": " ",
#     "GRGR_FAX": " ",
#     "GRGR_FAX_EXT": " ",
#     "GRGR_ID": "20001777",
#     "GRGR_ITS_CODE": " ",
#     "GRGR_LAST_CAP_DT": -6847787038000,
#     "GRGR_LMT_ADJ_MOS": 12,
#     "GRGR_LOCK_TOKEN": 1,
#     "GRGR_MCTR_LANG": "None",
#     "GRGR_MCTR_PTYP": " ",
#     "GRGR_MCTR_TRSN": " ",
#     "GRGR_MCTR_TYPE": "None",
#     "GRGR_MCTR_VIP": "None",
#     "GRGR_NAME": "VINCENT HAS UPDATED GRGR_NAME",
#     "GRGR_NAME_XLOW": "fayda za",
#     "GRGR_NEXT_ANNV_DT": 253402232400000,
#     "GRGR_ORIG_EFF_DT": 1548997200000,
#     "GRGR_PHONE": "3135629100",
#     "GRGR_PHONE_EXT": " ",
#     "GRGR_POL_NO": " ",
#     "GRGR_PREV_ANNV_DT": 253402232400000,
#     "GRGR_PUP_IND_NVL": "N",
#     "GRGR_RECD_DT": -6847787038000,
#     "GRGR_RENEW_MMDD": 201,
#     "GRGR_RNST_DT": -6847787038000,
#     "GRGR_RNST_TYPE": "N",
#     "GRGR_RNST_VAL": 0,
#     "GRGR_RUNOUT_DT": 253402232400000,
#     "GRGR_RUNOUT_EXCD": " ",
#     "GRGR_STATE": "MI",
#     "GRGR_STS": "AC",
#     "GRGR_TERM_DT": 253402232400000,
#     "GRGR_TERM_PREM_MOS": 0,
#     "GRGR_TOTAL_CONTR": 0,
#     "GRGR_TOTAL_ELIG": 0,
#     "GRGR_TOTAL_EMPL": 0,
#     "GRGR_TRANS_ACCEPT": " ",
#     "GRGR_UNDW_USUS_ID": " ",
#     "GRGR_ZIP": "48124",
#     "MCAR_AREA_ID": " ",
#     "PAGR_CK": 0,
#     "SYS_BITMAP_NVL": null,
#     "SYS_DBUSER_ID": {
#         "string": "FACETS"
#     },
#     "SYS_LAST_OFFSET_NVL": null,
#     "SYS_LAST_UPD_DTM": {
#         "long": 1601128097000
#     },
#     "SYS_USUS_ID": {
#         "string": "FACETS"
#     },
#     "WMDS_SEQ_NO": 0,
#     "current_ts": {
#         "string": "1640082021156"
#     },
#     "op_ts": {
#         "string": "1640082016000"
#     },
#     "op_type": {
#         "string": "U"
#     },
#     "row_id": {
#         "string": "AAAR32AAHAAAAFeAAA"
#     },
#     "scn": {
#         "string": "2160633"
#     },
#     "table": {
#         "string": "ORCLCDB.C##MYUSER.CUSTOMERS"
#     },
#     "username": {
#         "string": "C##MYUSER"
#     }
# }
