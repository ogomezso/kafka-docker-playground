#!/bin/sh

echo 'Populating CUSTOMERS table'

sqlplus C\#\#MYUSER/mypassword@//localhost:1521/ORCLCDB  <<- EOF

insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, my_timestamp) values (1, 'Rica', 'Blaisdell', 'rblaisdell0@rambler.ru', 'Female', ' ', 'Universal optimal hierarchy', TO_TIMESTAMP('1753-01-01 12:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, my_timestamp) values (2, 'Ruthie', 'Brockherst', 'rbrockherst1@ow.ly', 'Female', ' ', 'Reverse-engineered tangible interface', TO_TIMESTAMP('1753-01-01 12:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, my_timestamp) values (3, 'Mariejeanne', 'Cocci', 'mcocci2@techcrunch.com', 'Female', ' ', 'Multi-tiered bandwidth-monitored capability', TO_TIMESTAMP('1753-01-01 12:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, my_timestamp) values (4, 'Hashim', 'Rumke', 'hrumke3@sohu.com', 'Male', ' ', 'Self-enabling 24/7 firmware', TO_TIMESTAMP('1753-01-01 12:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, my_timestamp) values (5, 'Hansiain', 'Coda', 'hcoda4@senate.gov', 'Male', ' ', 'Centralized full-range approach', TO_TIMESTAMP('1753-01-01 12:00:00.000000000', 'YYYY-MM-DD HH24:MI:SS.FF'));

  exit;
EOF
