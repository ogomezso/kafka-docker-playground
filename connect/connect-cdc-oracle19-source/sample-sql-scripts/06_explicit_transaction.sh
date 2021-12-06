#!/bin/sh

echo 'Populating CUSTOMERS table after altering the structure'

docker exec -i oracle sqlplus C\#\#MYUSER/mypassword@//localhost:1521/$1 << EOF
  update CUSTOMERS set club_status = ' ' where email = 'gsamsa@confluent.io';
  update CUSTOMERS set club_status = ' ' where email = 'jk@confluent.io';
  commit;
  exit;
EOF
