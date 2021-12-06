#!/bin/sh

echo "Populating CUSTOMERS table"

docker exec -i oracle sqlplus C\#\#MYUSER/mypassword@//localhost:1521/$1 << EOF
  insert into CUSTOMERS (first_name, last_name, email, gender, club_status, comments, my_timestamp) values ('Frantz', 'Kafka', 'fkafka@confluent.io', 'Male', ' ', 'Evil is whatever distracts', TO_TIMESTAMP('1753-01-01 00:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));
  insert into CUSTOMERS (first_name, last_name, email, gender, club_status, comments, my_timestamp) values ('Gregor', 'Samsa', 'gsamsa@confluent.io', 'Male', 'vincent', 'How about if I sleep a little bit longer and forget all this nonsense', TO_TIMESTAMP('1753-01-01 00:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));
  exit;
EOF