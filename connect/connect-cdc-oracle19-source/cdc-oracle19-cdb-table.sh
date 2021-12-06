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

log "Insert a record"
docker exec -i oracle sqlplus C\#\#MYUSER/mypassword@//localhost:1521/ORCLCDB << EOF
Insert into CUSTOMERS (GRGR_CK,CICI_ID,GRGR_ID,PAGR_CK,GRGR_NAME,GRGR_ADDR1,GRGR_ADDR2,GRGR_ADDR3,GRGR_CITY,GRGR_STATE,GRGR_ZIP,GRGR_COUNTY,GRGR_CTRY_CD,GRGR_PHONE,GRGR_PHONE_EXT,GRGR_FAX,GRGR_FAX_EXT,GRGR_EMAIL,GRGR_MCTR_TYPE,GRGR_MCTR_VIP,MCAR_AREA_ID,CSCS_ID,GRGR_STS,GRGR_ORIG_EFF_DT,GRGR_TERM_DT,GRGR_MCTR_TRSN,EXCD_ID,GRGR_RNST_DT,GRGR_CONV_DT,GRGR_RENEW_MMDD,GRGR_PREV_ANNV_DT,GRGR_CURR_ANNV_DT,GRGR_NEXT_ANNV_DT,GRGR_MCTR_PTYP,GRGR_UNDW_USUS_ID,GRGR_CAP_IND,GRGR_LAST_CAP_DT,GRGR_CAP_BAT_STS,GRGR_BILL_LEVEL,GRGR_LMT_ADJ_MOS,GRGR_BL_CONV_DT,GRGR_NAME_XLOW,GRGR_CITY_XLOW,GRGR_MCTR_LANG,GRGR_EXTN_ADDR_IND,WMDS_SEQ_NO,GRGR_TOTAL_EMPL,GRGR_TOTAL_ELIG,GRGR_TOTAL_CONTR,GRGR_POL_NO,CRCY_ID,GRGR_EIN,GRGR_ERIS_MMDD,GRGR_RECD_DT,GRGR_DEN_CHT_IND,GRGR_CAP_CONV_DT,GRGR_RUNOUT_DT,GRGR_RUNOUT_EXCD,GRGR_TRANS_ACCEPT,GRGR_ITS_CODE,GRGR_AUTONUM_IND,GRGR_CONT_EFF_DT,GRGR_TERM_PREM_MOS,GRGR_RNST_TYPE,GRGR_RNST_VAL,GRGR_LOCK_TOKEN,ATXR_SOURCE_ID,SYS_LAST_UPD_DTM,SYS_USUS_ID,SYS_DBUSER_ID,SYS_BITMAP_NVL,SYS_LAST_OFFSET_NVL,GRGR_PUP_IND_NVL) values (7013,'01','20001777',0,'FAYDA ZAKARIA MD PC HMO','1711 MONROE ST',' ',' ','Dearborn','MI','48124','Wayne','USA','3135629100',' ',' ',' ',' ','None','None',' ',' ','AC',to_timestamp('2019-02-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),to_timestamp('9999-12-31 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),' ',' ',to_timestamp('1753-01-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),to_timestamp('1753-01-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),201,to_timestamp('9999-12-31 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),to_timestamp('9999-12-31 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),to_timestamp('9999-12-31 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),' ',' ','Y',to_timestamp('1753-01-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),0,'S',12,to_timestamp('1753-01-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),'fayda za','dearborn','None',' ',0,0,0,0,' ',' ',' ',201,to_timestamp('1753-01-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),'N',to_timestamp('1753-01-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),to_timestamp('9999-12-31 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),' ',' ',' ','Y',to_timestamp('1753-01-01 00:00:00.000000000','YYYY-MM-DD HH24:MI:SS.FF'),0,'N',0,1,to_timestamp('3423-01-01 00:44:56.680000000','YYYY-MM-DD HH24:MI:SS.FF'),to_timestamp('2020-09-26 09:48:17.000000000','YYYY-MM-DD HH24:MI:SS.FF'),'FACETS','FACETS',null,null,'N');
  exit;
EOF

log "Waiting 60s for connector to read new data"
sleep 60

log "Verifying topic ORCLCDB.C__MYUSER.CUSTOMERS: there should be 1 records"
set +e
timeout 60 docker exec connect kafka-avro-console-consumer -bootstrap-server broker:9092 --property schema.registry.url=http://schema-registry:8081 --topic ORCLCDB.C__MYUSER.CUSTOMERS --from-beginning --max-messages 1 > /tmp/result.log  2>&1
set -e
cat /tmp/result.log

log "Verifying topic redo-log-topic: there should be 1 records"
timeout 60 docker exec connect kafka-avro-console-consumer -bootstrap-server broker:9092 --property schema.registry.url=http://schema-registry:8081 --topic redo-log-topic --from-beginning --max-messages 1

# results with 1.4.0

# {
#     "ATXR_SOURCE_ID": 45852223496680,
#     "CICI_ID": "01",
#     "CRCY_ID": " ",
#     "CSCS_ID": " ",
#     "EXCD_ID": " ",
#     "GRGR_ADDR1": "1711 MONROE ST",
#     "GRGR_ADDR2": " ",
#     "GRGR_ADDR3": " ",
#     "GRGR_AUTONUM_IND": "Y",
#     "GRGR_BILL_LEVEL": "S",
#     "GRGR_BL_CONV_DT": -6847804800000,
#     "GRGR_CAP_BAT_STS": 0,
#     "GRGR_CAP_CONV_DT": -6847804800000,
#     "GRGR_CAP_IND": "Y",
#     "GRGR_CITY": "Dearborn",
#     "GRGR_CITY_XLOW": "dearborn",
#     "GRGR_CK": 7013,
#     "GRGR_CONT_EFF_DT": -6847804800000,
#     "GRGR_CONV_DT": -6847804800000,
#     "GRGR_COUNTY": "Wayne",
#     "GRGR_CTRY_CD": "USA",
#     "GRGR_CURR_ANNV_DT": 253402214400000,
#     "GRGR_DEN_CHT_IND": "N",
#     "GRGR_EIN": " ",
#     "GRGR_EMAIL": " ",
#     "GRGR_ERIS_MMDD": 201,
#     "GRGR_EXTN_ADDR_IND": " ",
#     "GRGR_FAX": " ",
#     "GRGR_FAX_EXT": " ",
#     "GRGR_ID": "20001777",
#     "GRGR_ITS_CODE": " ",
#     "GRGR_LAST_CAP_DT": -6847804800000,
#     "GRGR_LMT_ADJ_MOS": 12,
#     "GRGR_LOCK_TOKEN": 1,
#     "GRGR_MCTR_LANG": "None",
#     "GRGR_MCTR_PTYP": " ",
#     "GRGR_MCTR_TRSN": " ",
#     "GRGR_MCTR_TYPE": "None",
#     "GRGR_MCTR_VIP": "None",
#     "GRGR_NAME": "FAYDA ZAKARIA MD PC HMO",
#     "GRGR_NAME_XLOW": "fayda za",
#     "GRGR_NEXT_ANNV_DT": 253402214400000,
#     "GRGR_ORIG_EFF_DT": 1548979200000,
#     "GRGR_PHONE": "3135629100",
#     "GRGR_PHONE_EXT": " ",
#     "GRGR_POL_NO": " ",
#     "GRGR_PREV_ANNV_DT": 253402214400000,
#     "GRGR_PUP_IND_NVL": "N",
#     "GRGR_RECD_DT": -6847804800000,
#     "GRGR_RENEW_MMDD": 201,
#     "GRGR_RNST_DT": -6847804800000,
#     "GRGR_RNST_TYPE": "N",
#     "GRGR_RNST_VAL": 0,
#     "GRGR_RUNOUT_DT": 253402214400000,
#     "GRGR_RUNOUT_EXCD": " ",
#     "GRGR_STATE": "MI",
#     "GRGR_STS": "AC",
#     "GRGR_TERM_DT": 253402214400000,
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
#         "long": 1601113697000
#     },
#     "SYS_USUS_ID": {
#         "string": "FACETS"
#     },
#     "WMDS_SEQ_NO": 0,
#     "current_ts": {
#         "string": "1638805826756"
#     },
#     "op_ts": {
#         "string": "1638805822000"
#     },
#     "op_type": {
#         "string": "I"
#     },
#     "row_id": {
#         "string": "AAAR32AAHAAAAFbAAA"
#     },
#     "scn": {
#         "string": "2163159"
#     },
#     "table": {
#         "string": "ORCLCDB.C##MYUSER.CUSTOMERS"
#     },
#     "username": {
#         "string": "C##MYUSER"
#     }
# }


# REDO

# {"SCN":{"long":2163159},"START_SCN":{"long":2163159},"COMMIT_SCN":{"long":2163160},"TIMESTAMP":{"long":1638805822000},"START_TIMESTAMP":{"long":1638805822000},"COMMIT_TIMESTAMP":{"long":1638805822000},"XIDUSN":{"long":10},"XIDSLT":{"long":1},"XIDSQN":{"long":855},"XID":{"bytes":"\n\u0000\u0001\u0000W\u0003\u0000\u0000"},"PXIDUSN":{"long":10},"PXIDSLT":{"long":1},"PXIDSQN":{"long":855},"PXID":{"bytes":"\n\u0000\u0001\u0000W\u0003\u0000\u0000"},"TX_NAME":null,"OPERATION":{"string":"INSERT"},"OPERATION_CODE":{"int":1},"ROLLBACK":{"boolean":false},"SEG_OWNER":{"string":"C##MYUSER"},"SEG_NAME":{"string":"CUSTOMERS"},"TABLE_NAME":{"string":"CUSTOMERS"},"SEG_TYPE":{"int":2},"SEG_TYPE_NAME":{"string":"TABLE"},"TABLE_SPACE":{"string":"USERS"},"ROW_ID":{"string":"AAAR32AAHAAAAFbAAA"},"USERNAME":{"string":"C##MYUSER"},"OS_USERNAME":{"string":"oracle"},"MACHINE_NAME":{"string":"oracle"},"AUDIT_SESSIONID":{"long":130003},"SESSION_NUM":{"long":750},"SERIAL_NUM":{"long":16759},"SESSION_INFO":{"string":"login_username=C##MYUSER client_info= OS_username=oracle Machine_name=oracle OS_terminal=pts/0 OS_process_id=551 OS_program_name=sqlplus@oracle (TNS V1-V3)"},"THREAD_NUM":{"long":1},"SEQUENCE_NUM":{"long":2},"RBASQN":{"long":11},"RBABLK":{"long":53},"RBABYTE":{"long":156},"UBAFIL":{"long":4},"UBABLK":{"long":16777489},"UBAREC":{"long":44},"UBASQN":{"long":174},"ABS_FILE_NUM":{"long":7},"REL_FILE_NUM":{"long":7},"DATA_BLK_NUM":{"long":347},"DATA_OBJ_NUM":{"long":73206},"DATA_OBJV_NUM":{"long":69},"DATA_OBJD_NUM":{"long":73206},"SQL_REDO":{"string":"insert into \"C##MYUSER\".\"CUSTOMERS\"(\"GRGR_CK\",\"CICI_ID\",\"GRGR_ID\",\"PAGR_CK\",\"GRGR_NAME\",\"GRGR_ADDR1\",\"GRGR_ADDR2\",\"GRGR_ADDR3\",\"GRGR_CITY\",\"GRGR_STATE\",\"GRGR_ZIP\",\"GRGR_COUNTY\",\"GRGR_CTRY_CD\",\"GRGR_PHONE\",\"GRGR_PHONE_EXT\",\"GRGR_FAX\",\"GRGR_FAX_EXT\",\"GRGR_EMAIL\",\"GRGR_MCTR_TYPE\",\"GRGR_MCTR_VIP\",\"MCAR_AREA_ID\",\"CSCS_ID\",\"GRGR_STS\",\"GRGR_ORIG_EFF_DT\",\"GRGR_TERM_DT\",\"GRGR_MCTR_TRSN\",\"EXCD_ID\",\"GRGR_RNST_DT\",\"GRGR_CONV_DT\",\"GRGR_RENEW_MMDD\",\"GRGR_PREV_ANNV_DT\",\"GRGR_CURR_ANNV_DT\",\"GRGR_NEXT_ANNV_DT\",\"GRGR_MCTR_PTYP\",\"GRGR_UNDW_USUS_ID\",\"GRGR_CAP_IND\",\"GRGR_LAST_CAP_DT\",\"GRGR_CAP_BAT_STS\",\"GRGR_BILL_LEVEL\",\"GRGR_LMT_ADJ_MOS\",\"GRGR_BL_CONV_DT\",\"GRGR_NAME_XLOW\",\"GRGR_CITY_XLOW\",\"GRGR_MCTR_LANG\",\"GRGR_EXTN_ADDR_IND\",\"WMDS_SEQ_NO\",\"GRGR_TOTAL_EMPL\",\"GRGR_TOTAL_ELIG\",\"GRGR_TOTAL_CONTR\",\"GRGR_POL_NO\",\"CRCY_ID\",\"GRGR_EIN\",\"GRGR_ERIS_MMDD\",\"GRGR_RECD_DT\",\"GRGR_DEN_CHT_IND\",\"GRGR_CAP_CONV_DT\",\"GRGR_RUNOUT_DT\",\"GRGR_RUNOUT_EXCD\",\"GRGR_TRANS_ACCEPT\",\"GRGR_ITS_CODE\",\"GRGR_AUTONUM_IND\",\"GRGR_CONT_EFF_DT\",\"GRGR_TERM_PREM_MOS\",\"GRGR_RNST_TYPE\",\"GRGR_RNST_VAL\",\"GRGR_LOCK_TOKEN\",\"ATXR_SOURCE_ID\",\"SYS_LAST_UPD_DTM\",\"SYS_USUS_ID\",\"SYS_DBUSER_ID\",\"SYS_BITMAP_NVL\",\"SYS_LAST_OFFSET_NVL\",\"GRGR_PUP_IND_NVL\") values ('7013','01','20001777','0','FAYDA ZAKARIA MD PC HMO','1711 MONROE ST',' ',' ','Dearborn','MI','48124','Wayne','USA','3135629100',' ',' ',' ',' ','None','None',' ',' ','AC',TO_TIMESTAMP('2019-02-01 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),' ',' ',TO_TIMESTAMP('1753-01-01 00:00:00.000'),TO_TIMESTAMP('1753-01-01 00:00:00.000'),'201',TO_TIMESTAMP('9999-12-31 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),' ',' ','Y',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'0','S','12',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'fayda za','dearborn','None',' ','0','0','0','0',' ',' ',' ','201',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'N',TO_TIMESTAMP('1753-01-01 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),' ',' ',' ','Y',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'0','N','0','1',TO_TIMESTAMP('3423-01-01 00:44:56.680'),TO_TIMESTAMP('2020-09-26 09:48:17.000'),'FACETS','FACETS',NULL,NULL,'N');"},"SQL_UNDO":{"string":"delete from \"C##MYUSER\".\"CUSTOMERS\" where \"GRGR_CK\" = '7013' and \"CICI_ID\" = '01' and \"GRGR_ID\" = '20001777' and \"PAGR_CK\" = '0' and \"GRGR_NAME\" = 'FAYDA ZAKARIA MD PC HMO' and \"GRGR_ADDR1\" = '1711 MONROE ST' and \"GRGR_ADDR2\" = ' ' and \"GRGR_ADDR3\" = ' ' and \"GRGR_CITY\" = 'Dearborn' and \"GRGR_STATE\" = 'MI' and \"GRGR_ZIP\" = '48124' and \"GRGR_COUNTY\" = 'Wayne' and \"GRGR_CTRY_CD\" = 'USA' and \"GRGR_PHONE\" = '3135629100' and \"GRGR_PHONE_EXT\" = ' ' and \"GRGR_FAX\" = ' ' and \"GRGR_FAX_EXT\" = ' ' and \"GRGR_EMAIL\" = ' ' and \"GRGR_MCTR_TYPE\" = 'None' and \"GRGR_MCTR_VIP\" = 'None' and \"MCAR_AREA_ID\" = ' ' and \"CSCS_ID\" = ' ' and \"GRGR_STS\" = 'AC' and \"GRGR_ORIG_EFF_DT\" = TO_TIMESTAMP('2019-02-01 00:00:00.000') and \"GRGR_TERM_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_MCTR_TRSN\" = ' ' and \"EXCD_ID\" = ' ' and \"GRGR_RNST_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_CONV_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_RENEW_MMDD\" = '201' and \"GRGR_PREV_ANNV_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_CURR_ANNV_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_NEXT_ANNV_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_MCTR_PTYP\" = ' ' and \"GRGR_UNDW_USUS_ID\" = ' ' and \"GRGR_CAP_IND\" = 'Y' and \"GRGR_LAST_CAP_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_CAP_BAT_STS\" = '0' and \"GRGR_BILL_LEVEL\" = 'S' and \"GRGR_LMT_ADJ_MOS\" = '12' and \"GRGR_BL_CONV_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_NAME_XLOW\" = 'fayda za' and \"GRGR_CITY_XLOW\" = 'dearborn' and \"GRGR_MCTR_LANG\" = 'None' and \"GRGR_EXTN_ADDR_IND\" = ' ' and \"WMDS_SEQ_NO\" = '0' and \"GRGR_TOTAL_EMPL\" = '0' and \"GRGR_TOTAL_ELIG\" = '0' and \"GRGR_TOTAL_CONTR\" = '0' and \"GRGR_POL_NO\" = ' ' and \"CRCY_ID\" = ' ' and \"GRGR_EIN\" = ' ' and \"GRGR_ERIS_MMDD\" = '201' and \"GRGR_RECD_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_DEN_CHT_IND\" = 'N' and \"GRGR_CAP_CONV_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_RUNOUT_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_RUNOUT_EXCD\" = ' ' and \"GRGR_TRANS_ACCEPT\" = ' ' and \"GRGR_ITS_CODE\" = ' ' and \"GRGR_AUTONUM_IND\" = 'Y' and \"GRGR_CONT_EFF_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_TERM_PREM_MOS\" = '0' and \"GRGR_RNST_TYPE\" = 'N' and \"GRGR_RNST_VAL\" = '0' and \"GRGR_LOCK_TOKEN\" = '1' and \"ATXR_SOURCE_ID\" = TO_TIMESTAMP('3423-01-01 00:44:56.680') and \"SYS_LAST_UPD_DTM\" = TO_TIMESTAMP('2020-09-26 09:48:17.000') and \"SYS_USUS_ID\" = 'FACETS' and \"SYS_DBUSER_ID\" = 'FACETS' and \"SYS_BITMAP_NVL\" IS NULL and \"SYS_LAST_OFFSET_NVL\" IS NULL and \"GRGR_PUP_IND_NVL\" = 'N' and ROWID = 'AAAR32AAHAAAAFbAAA';"},"RS_ID":{"string":" 0x00000b.00000035.009c "},"SSN":{"long":0},"CSF":{"boolean":false},"INFO":null,"STATUS":{"int":0},"REDO_VALUE":{"long":70},"UNDO_VALUE":{"long":71},"SAFE_RESUME_SCN":{"long":0},"CSCN":{"long":2163160},"OBJECT_ID":null,"EDITION_NAME":null,"CLIENT_ID":null,"SRC_CON_NAME":{"string":"CDB$ROOT"},"SRC_CON_ID":{"long":1},"SRC_CON_UID":{"long":1},"SRC_CON_DBID":{"long":0},"SRC_CON_GUID":null,"CON_ID":{"boolean":false}}

# With 1.3.2 SNAPSHOT

# {
#     "ATXR_SOURCE_ID": 45852223496680,
#     "CICI_ID": "01",
#     "CRCY_ID": " ",
#     "CSCS_ID": " ",
#     "EXCD_ID": " ",
#     "GRGR_ADDR1": "1711 MONROE ST",
#     "GRGR_ADDR2": " ",
#     "GRGR_ADDR3": " ",
#     "GRGR_AUTONUM_IND": "Y",
#     "GRGR_BILL_LEVEL": "S",
#     "GRGR_BL_CONV_DT": -6847804800000,
#     "GRGR_CAP_BAT_STS": 0,
#     "GRGR_CAP_CONV_DT": -6847804800000,
#     "GRGR_CAP_IND": "Y",
#     "GRGR_CITY": "Dearborn",
#     "GRGR_CITY_XLOW": "dearborn",
#     "GRGR_CK": 7013,
#     "GRGR_CONT_EFF_DT": -6847804800000,
#     "GRGR_CONV_DT": -6847804800000,
#     "GRGR_COUNTY": "Wayne",
#     "GRGR_CTRY_CD": "USA",
#     "GRGR_CURR_ANNV_DT": 253402214400000,
#     "GRGR_DEN_CHT_IND": "N",
#     "GRGR_EIN": " ",
#     "GRGR_EMAIL": " ",
#     "GRGR_ERIS_MMDD": 201,
#     "GRGR_EXTN_ADDR_IND": " ",
#     "GRGR_FAX": " ",
#     "GRGR_FAX_EXT": " ",
#     "GRGR_ID": "20001777",
#     "GRGR_ITS_CODE": " ",
#     "GRGR_LAST_CAP_DT": -6847804800000,
#     "GRGR_LMT_ADJ_MOS": 12,
#     "GRGR_LOCK_TOKEN": 1,
#     "GRGR_MCTR_LANG": "None",
#     "GRGR_MCTR_PTYP": " ",
#     "GRGR_MCTR_TRSN": " ",
#     "GRGR_MCTR_TYPE": "None",
#     "GRGR_MCTR_VIP": "None",
#     "GRGR_NAME": "FAYDA ZAKARIA MD PC HMO",
#     "GRGR_NAME_XLOW": "fayda za",
#     "GRGR_NEXT_ANNV_DT": 253402214400000,
#     "GRGR_ORIG_EFF_DT": 1548979200000,
#     "GRGR_PHONE": "3135629100",
#     "GRGR_PHONE_EXT": " ",
#     "GRGR_POL_NO": " ",
#     "GRGR_PREV_ANNV_DT": 253402214400000,
#     "GRGR_PUP_IND_NVL": "N",
#     "GRGR_RECD_DT": -6847804800000,
#     "GRGR_RENEW_MMDD": 201,
#     "GRGR_RNST_DT": -6847804800000,
#     "GRGR_RNST_TYPE": "N",
#     "GRGR_RNST_VAL": 0,
#     "GRGR_RUNOUT_DT": 253402214400000,
#     "GRGR_RUNOUT_EXCD": " ",
#     "GRGR_STATE": "MI",
#     "GRGR_STS": "AC",
#     "GRGR_TERM_DT": 253402214400000,
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
#         "long": 1601113697000
#     },
#     "SYS_USUS_ID": {
#         "string": "FACETS"
#     },
#     "WMDS_SEQ_NO": 0,
#     "current_ts": {
#         "string": "1638806499409"
#     },
#     "op_ts": {
#         "string": "1638806458000"
#     },
#     "op_type": {
#         "string": "I"
#     },
#     "row_id": {
#         "string": "AAAR32AAHAAAAFfAAA"
#     },
#     "scn": {
#         "string": "2161573"
#     },
#     "table": {
#         "string": "ORCLCDB.C##MYUSER.CUSTOMERS"
#     },
#     "username": {
#         "string": "C##MYUSER"
#     }
# }


# {"SCN":{"long":2161573},"START_SCN":{"long":2161573},"COMMIT_SCN":{"long":2161574},"TIMESTAMP":{"long":1638806458000},"START_TIMESTAMP":{"long":1638806458000},"COMMIT_TIMESTAMP":{"long":1638806458000},"XIDUSN":{"long":10},"XIDSLT":{"long":11},"XIDSQN":{"long":855},"XID":{"bytes":"\n\u0000\u000B\u0000W\u0003\u0000\u0000"},"PXIDUSN":{"long":10},"PXIDSLT":{"long":11},"PXIDSQN":{"long":855},"PXID":{"bytes":"\n\u0000\u000B\u0000W\u0003\u0000\u0000"},"TX_NAME":null,"OPERATION":{"string":"INSERT"},"OPERATION_CODE":{"int":1},"ROLLBACK":{"boolean":false},"SEG_OWNER":{"string":"C##MYUSER"},"SEG_NAME":{"string":"CUSTOMERS"},"TABLE_NAME":{"string":"CUSTOMERS"},"SEG_TYPE":{"int":2},"SEG_TYPE_NAME":{"string":"TABLE"},"TABLE_SPACE":{"string":"USERS"},"ROW_ID":{"string":"AAAR32AAHAAAAFfAAA"},"USERNAME":{"string":"C##MYUSER"},"OS_USERNAME":{"string":"oracle"},"MACHINE_NAME":{"string":"oracle"},"AUDIT_SESSIONID":{"long":130003},"SESSION_NUM":{"long":8},"SERIAL_NUM":{"long":56036},"SESSION_INFO":{"string":"login_username=C##MYUSER client_info= OS_username=oracle Machine_name=oracle OS_terminal=pts/0 OS_process_id=532 OS_program_name=sqlplus@oracle (TNS V1-V3)"},"THREAD_NUM":{"long":1},"SEQUENCE_NUM":{"long":2},"RBASQN":{"long":7},"RBABLK":{"long":100909},"RBABYTE":{"long":156},"UBAFIL":{"long":4},"UBABLK":{"long":16777490},"UBAREC":{"long":38},"UBASQN":{"long":174},"ABS_FILE_NUM":{"long":7},"REL_FILE_NUM":{"long":7},"DATA_BLK_NUM":{"long":351},"DATA_OBJ_NUM":{"long":73206},"DATA_OBJV_NUM":{"long":69},"DATA_OBJD_NUM":{"long":73206},"SQL_REDO":{"string":"insert into \"C##MYUSER\".\"CUSTOMERS\"(\"GRGR_CK\",\"CICI_ID\",\"GRGR_ID\",\"PAGR_CK\",\"GRGR_NAME\",\"GRGR_ADDR1\",\"GRGR_ADDR2\",\"GRGR_ADDR3\",\"GRGR_CITY\",\"GRGR_STATE\",\"GRGR_ZIP\",\"GRGR_COUNTY\",\"GRGR_CTRY_CD\",\"GRGR_PHONE\",\"GRGR_PHONE_EXT\",\"GRGR_FAX\",\"GRGR_FAX_EXT\",\"GRGR_EMAIL\",\"GRGR_MCTR_TYPE\",\"GRGR_MCTR_VIP\",\"MCAR_AREA_ID\",\"CSCS_ID\",\"GRGR_STS\",\"GRGR_ORIG_EFF_DT\",\"GRGR_TERM_DT\",\"GRGR_MCTR_TRSN\",\"EXCD_ID\",\"GRGR_RNST_DT\",\"GRGR_CONV_DT\",\"GRGR_RENEW_MMDD\",\"GRGR_PREV_ANNV_DT\",\"GRGR_CURR_ANNV_DT\",\"GRGR_NEXT_ANNV_DT\",\"GRGR_MCTR_PTYP\",\"GRGR_UNDW_USUS_ID\",\"GRGR_CAP_IND\",\"GRGR_LAST_CAP_DT\",\"GRGR_CAP_BAT_STS\",\"GRGR_BILL_LEVEL\",\"GRGR_LMT_ADJ_MOS\",\"GRGR_BL_CONV_DT\",\"GRGR_NAME_XLOW\",\"GRGR_CITY_XLOW\",\"GRGR_MCTR_LANG\",\"GRGR_EXTN_ADDR_IND\",\"WMDS_SEQ_NO\",\"GRGR_TOTAL_EMPL\",\"GRGR_TOTAL_ELIG\",\"GRGR_TOTAL_CONTR\",\"GRGR_POL_NO\",\"CRCY_ID\",\"GRGR_EIN\",\"GRGR_ERIS_MMDD\",\"GRGR_RECD_DT\",\"GRGR_DEN_CHT_IND\",\"GRGR_CAP_CONV_DT\",\"GRGR_RUNOUT_DT\",\"GRGR_RUNOUT_EXCD\",\"GRGR_TRANS_ACCEPT\",\"GRGR_ITS_CODE\",\"GRGR_AUTONUM_IND\",\"GRGR_CONT_EFF_DT\",\"GRGR_TERM_PREM_MOS\",\"GRGR_RNST_TYPE\",\"GRGR_RNST_VAL\",\"GRGR_LOCK_TOKEN\",\"ATXR_SOURCE_ID\",\"SYS_LAST_UPD_DTM\",\"SYS_USUS_ID\",\"SYS_DBUSER_ID\",\"SYS_BITMAP_NVL\",\"SYS_LAST_OFFSET_NVL\",\"GRGR_PUP_IND_NVL\") values ('7013','01','20001777','0','FAYDA ZAKARIA MD PC HMO','1711 MONROE ST',' ',' ','Dearborn','MI','48124','Wayne','USA','3135629100',' ',' ',' ',' ','None','None',' ',' ','AC',TO_TIMESTAMP('2019-02-01 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),' ',' ',TO_TIMESTAMP('1753-01-01 00:00:00.000'),TO_TIMESTAMP('1753-01-01 00:00:00.000'),'201',TO_TIMESTAMP('9999-12-31 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),' ',' ','Y',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'0','S','12',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'fayda za','dearborn','None',' ','0','0','0','0',' ',' ',' ','201',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'N',TO_TIMESTAMP('1753-01-01 00:00:00.000'),TO_TIMESTAMP('9999-12-31 00:00:00.000'),' ',' ',' ','Y',TO_TIMESTAMP('1753-01-01 00:00:00.000'),'0','N','0','1',TO_TIMESTAMP('3423-01-01 00:44:56.680'),TO_TIMESTAMP('2020-09-26 09:48:17.000'),'FACETS','FACETS',NULL,NULL,'N');"},"SQL_UNDO":{"string":"delete from \"C##MYUSER\".\"CUSTOMERS\" where \"GRGR_CK\" = '7013' and \"CICI_ID\" = '01' and \"GRGR_ID\" = '20001777' and \"PAGR_CK\" = '0' and \"GRGR_NAME\" = 'FAYDA ZAKARIA MD PC HMO' and \"GRGR_ADDR1\" = '1711 MONROE ST' and \"GRGR_ADDR2\" = ' ' and \"GRGR_ADDR3\" = ' ' and \"GRGR_CITY\" = 'Dearborn' and \"GRGR_STATE\" = 'MI' and \"GRGR_ZIP\" = '48124' and \"GRGR_COUNTY\" = 'Wayne' and \"GRGR_CTRY_CD\" = 'USA' and \"GRGR_PHONE\" = '3135629100' and \"GRGR_PHONE_EXT\" = ' ' and \"GRGR_FAX\" = ' ' and \"GRGR_FAX_EXT\" = ' ' and \"GRGR_EMAIL\" = ' ' and \"GRGR_MCTR_TYPE\" = 'None' and \"GRGR_MCTR_VIP\" = 'None' and \"MCAR_AREA_ID\" = ' ' and \"CSCS_ID\" = ' ' and \"GRGR_STS\" = 'AC' and \"GRGR_ORIG_EFF_DT\" = TO_TIMESTAMP('2019-02-01 00:00:00.000') and \"GRGR_TERM_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_MCTR_TRSN\" = ' ' and \"EXCD_ID\" = ' ' and \"GRGR_RNST_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_CONV_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_RENEW_MMDD\" = '201' and \"GRGR_PREV_ANNV_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_CURR_ANNV_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_NEXT_ANNV_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_MCTR_PTYP\" = ' ' and \"GRGR_UNDW_USUS_ID\" = ' ' and \"GRGR_CAP_IND\" = 'Y' and \"GRGR_LAST_CAP_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_CAP_BAT_STS\" = '0' and \"GRGR_BILL_LEVEL\" = 'S' and \"GRGR_LMT_ADJ_MOS\" = '12' and \"GRGR_BL_CONV_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_NAME_XLOW\" = 'fayda za' and \"GRGR_CITY_XLOW\" = 'dearborn' and \"GRGR_MCTR_LANG\" = 'None' and \"GRGR_EXTN_ADDR_IND\" = ' ' and \"WMDS_SEQ_NO\" = '0' and \"GRGR_TOTAL_EMPL\" = '0' and \"GRGR_TOTAL_ELIG\" = '0' and \"GRGR_TOTAL_CONTR\" = '0' and \"GRGR_POL_NO\" = ' ' and \"CRCY_ID\" = ' ' and \"GRGR_EIN\" = ' ' and \"GRGR_ERIS_MMDD\" = '201' and \"GRGR_RECD_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_DEN_CHT_IND\" = 'N' and \"GRGR_CAP_CONV_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_RUNOUT_DT\" = TO_TIMESTAMP('9999-12-31 00:00:00.000') and \"GRGR_RUNOUT_EXCD\" = ' ' and \"GRGR_TRANS_ACCEPT\" = ' ' and \"GRGR_ITS_CODE\" = ' ' and \"GRGR_AUTONUM_IND\" = 'Y' and \"GRGR_CONT_EFF_DT\" = TO_TIMESTAMP('1753-01-01 00:00:00.000') and \"GRGR_TERM_PREM_MOS\" = '0' and \"GRGR_RNST_TYPE\" = 'N' and \"GRGR_RNST_VAL\" = '0' and \"GRGR_LOCK_TOKEN\" = '1' and \"ATXR_SOURCE_ID\" = TO_TIMESTAMP('3423-01-01 00:44:56.680') and \"SYS_LAST_UPD_DTM\" = TO_TIMESTAMP('2020-09-26 09:48:17.000') and \"SYS_USUS_ID\" = 'FACETS' and \"SYS_DBUSER_ID\" = 'FACETS' and \"SYS_BITMAP_NVL\" IS NULL and \"SYS_LAST_OFFSET_NVL\" IS NULL and \"GRGR_PUP_IND_NVL\" = 'N' and ROWID = 'AAAR32AAHAAAAFfAAA';"},"RS_ID":{"string":" 0x000007.00018a2d.009c "},"SSN":{"long":0},"CSF":{"boolean":false},"INFO":null,"STATUS":{"int":0},"REDO_VALUE":{"long":656436},"UNDO_VALUE":{"long":656437},"SAFE_RESUME_SCN":{"long":0},"CSCN":{"long":2161574},"OBJECT_ID":null,"EDITION_NAME":null,"CLIENT_ID":null,"SRC_CON_NAME":{"string":"CDB$ROOT"},"SRC_CON_ID":{"long":1},"SRC_CON_UID":{"long":1},"SRC_CON_DBID":{"long":0},"SRC_CON_GUID":null,"CON_ID":{"boolean":false}}
