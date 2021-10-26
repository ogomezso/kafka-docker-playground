CREATE ROLE CDC_PRIVS;
GRANT CREATE SESSION TO CDC_PRIVS;
GRANT EXECUTE ON SYS.DBMS_LOGMNR TO CDC_PRIVS;
GRANT SELECT ON V_$LOGMNR_CONTENTS TO CDC_PRIVS;
GRANT SELECT ON V_$DATABASE TO CDC_PRIVS;
GRANT SELECT ON V_$THREAD TO CDC_PRIVS;
GRANT SELECT ON V_$PARAMETER TO CDC_PRIVS;
GRANT SELECT ON V_$NLS_PARAMETERS TO CDC_PRIVS;
GRANT SELECT ON V_$TIMEZONE_NAMES TO CDC_PRIVS;
GRANT SELECT ON ALL_INDEXES TO CDC_PRIVS;
GRANT SELECT ON ALL_OBJECTS TO CDC_PRIVS;
GRANT SELECT ON ALL_USERS TO CDC_PRIVS;
GRANT SELECT ON ALL_CATALOG TO CDC_PRIVS;
GRANT SELECT ON ALL_CONSTRAINTS TO CDC_PRIVS;
GRANT SELECT ON ALL_CONS_COLUMNS TO CDC_PRIVS;
GRANT SELECT ON ALL_TAB_COLS TO CDC_PRIVS;
GRANT SELECT ON ALL_IND_COLUMNS TO CDC_PRIVS;
GRANT SELECT ON ALL_ENCRYPTED_COLUMNS TO CDC_PRIVS;
GRANT SELECT ON ALL_LOG_GROUPS TO CDC_PRIVS;
GRANT SELECT ON ALL_TAB_PARTITIONS TO CDC_PRIVS;
GRANT SELECT ON SYS.DBA_REGISTRY TO CDC_PRIVS;
GRANT SELECT ON SYS.OBJ$ TO CDC_PRIVS;
GRANT SELECT ON DBA_TABLESPACES TO CDC_PRIVS;
GRANT SELECT ON DBA_OBJECTS TO CDC_PRIVS;
GRANT SELECT ON SYS.ENC$ TO CDC_PRIVS;
GRANT SELECT ANY TRANSACTION TO CDC_PRIVS;
GRANT SELECT ANY TABLE TO CDC_PRIVS;

GRANT CONNECT TO CDC_PRIVS;
GRANT CREATE SESSION TO CDC_PRIVS;
GRANT CREATE TABLE TO CDC_PRIVS;
GRANT CREATE SEQUENCE TO CDC_PRIVS;
GRANT CREATE TRIGGER TO CDC_PRIVS;
--ALTER DATABASE default tablespace users;

CREATE USER MYUSER IDENTIFIED BY password DEFAULT TABLESPACE USERS;
ALTER USER MYUSER QUOTA UNLIMITED ON USERS;

GRANT CDC_PRIVS to MYUSER;

-- Enable Supplemental Logging for All Columns
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;

GRANT FLASHBACK ANY TABLE TO MYUSER;

exit;