sqlplus MYUSER/password@//localhost:1521/XE  <<- EOF

insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, start_date) values (1, 'Rica', 'Blaisdell', 'rblaisdell0@rambler.ru', 'Female', 'bronze', 'Universal optimal hierarchy',DATE '2017-11-14');
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, start_date) values (2, 'Ruthie', 'Brockherst', 'rbrockherst1@ow.ly', 'Female', 'platinum', 'Reverse-engineered tangible interface',DATE '2017-11-14');
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, start_date) values (3, 'Mariejeanne', 'Cocci', 'mcocci2@techcrunch.com', 'Female', 'bronze', 'Multi-tiered bandwidth-monitored capability',DATE '2017-11-14');
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, start_date) values (4, 'Hashim', 'Rumke', 'hrumke3@sohu.com', 'Male', 'platinum', 'Self-enabling 24/7 firmware',DATE '2017-11-14');
insert into CUSTOMERS (id, first_name, last_name, email, gender, club_status, comments, start_date) values (5, 'Hansiain', 'Coda', 'hcoda4@senate.gov', 'Male', 'platinum', 'Centralized full-range approach',DATE '2017-11-14');

EOF