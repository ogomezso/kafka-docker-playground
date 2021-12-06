#!/bin/sh

echo 'Populating CUSTOMERS table after altering the structure'

docker exec -i oracle sqlplus C\#\#MYUSER/mypassword@//localhost:1521/$1 << EOF
  insert into CUSTOMERS (first_name, last_name, email, gender, club_status, comments, country, my_timestamp) values ('Josef', 'K', 'jk@confluent.io', 'Male', ' ', 'How is it even possible for someone to be guilty', 'Poland', TO_TIMESTAMP('1753-01-01 12:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));
  update CUSTOMERS set club_status = 'silver' where email = 'gsamsa@confluent.io';
  exit;
EOF
