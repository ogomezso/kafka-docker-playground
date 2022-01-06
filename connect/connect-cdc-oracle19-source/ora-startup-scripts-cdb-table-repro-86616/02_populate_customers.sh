#!/bin/sh

echo 'Populating TIP table'

sqlplus C\#\#MYUSER/mypassword@//localhost:1521/ORCLCDB  <<- EOF

INSERT INTO TIP (TIP_ID, TIP_TITLE, TIP_ABSTRACT, TIP_DESCRIPTION, SITE_ID,LAST_UPD_DATE, LAST_UPD_BY, OBSOLETE_FLAG) Values (15, 'A row with abstract and description', 'An abstract', 'A description', 9,TO_DATE('12/09/2012 23:30:39', 'MM/DD/YYYY HH24:MI:SS'), 'NOBODY', 'N');

INSERT INTO TIP (TIP_ID, TIP_TITLE, TIP_ABSTRACT, SITE_ID,LAST_UPD_DATE, LAST_UPD_BY, OBSOLETE_FLAG) Values (16, 'A row without description', 'An abstract', 9, TO_DATE('12/09/2012 23:30:39', 'MM/DD/YYYY HH24:MI:SS'), 'NOBODY', 'N');

  exit;
EOF
