#!/bin/sh

echo 'Creating CUSTOMERS table in CDB'

sqlplus C\#\#MYUSER/mypassword@//localhost:1521/ORCLCDB  <<- EOF

  CREATE TABLE "CUSTOMERS" 
   (	"GRGR_CK" NUMBER(10,0), 
	"CICI_ID" VARCHAR2(2 BYTE), 
	"GRGR_ID" VARCHAR2(8 BYTE), 
	"PAGR_CK" NUMBER(10,0), 
	"GRGR_NAME" VARCHAR2(50 BYTE), 
	"GRGR_ADDR1" VARCHAR2(40 BYTE), 
	"GRGR_ADDR2" VARCHAR2(40 BYTE), 
	"GRGR_ADDR3" VARCHAR2(40 BYTE), 
	"GRGR_CITY" VARCHAR2(19 BYTE), 
	"GRGR_STATE" VARCHAR2(2 BYTE), 
	"GRGR_ZIP" VARCHAR2(11 BYTE), 
	"GRGR_COUNTY" VARCHAR2(20 BYTE), 
	"GRGR_CTRY_CD" VARCHAR2(4 BYTE), 
	"GRGR_PHONE" VARCHAR2(20 BYTE), 
	"GRGR_PHONE_EXT" VARCHAR2(4 BYTE), 
	"GRGR_FAX" VARCHAR2(20 BYTE), 
	"GRGR_FAX_EXT" VARCHAR2(4 BYTE), 
	"GRGR_EMAIL" VARCHAR2(40 BYTE), 
	"GRGR_MCTR_TYPE" VARCHAR2(4 BYTE), 
	"GRGR_MCTR_VIP" VARCHAR2(4 BYTE), 
	"MCAR_AREA_ID" VARCHAR2(4 BYTE), 
	"CSCS_ID" VARCHAR2(4 BYTE), 
	"GRGR_STS" VARCHAR2(2 BYTE), 
	"GRGR_ORIG_EFF_DT" TIMESTAMP (3), 
	"GRGR_TERM_DT" TIMESTAMP (3), 
	"GRGR_MCTR_TRSN" VARCHAR2(4 BYTE), 
	"EXCD_ID" VARCHAR2(3 BYTE), 
	"GRGR_RNST_DT" TIMESTAMP (3), 
	"GRGR_CONV_DT" TIMESTAMP (3), 
	"GRGR_RENEW_MMDD" NUMBER(5,0), 
	"GRGR_PREV_ANNV_DT" TIMESTAMP (3), 
	"GRGR_CURR_ANNV_DT" TIMESTAMP (3), 
	"GRGR_NEXT_ANNV_DT" TIMESTAMP (3), 
	"GRGR_MCTR_PTYP" VARCHAR2(4 BYTE), 
	"GRGR_UNDW_USUS_ID" VARCHAR2(10 BYTE), 
	"GRGR_CAP_IND" VARCHAR2(1 BYTE), 
	"GRGR_LAST_CAP_DT" TIMESTAMP (3), 
	"GRGR_CAP_BAT_STS" NUMBER(10,0), 
	"GRGR_BILL_LEVEL" VARCHAR2(1 BYTE), 
	"GRGR_LMT_ADJ_MOS" NUMBER(5,0), 
	"GRGR_BL_CONV_DT" TIMESTAMP (3), 
	"GRGR_NAME_XLOW" VARCHAR2(8 BYTE), 
	"GRGR_CITY_XLOW" VARCHAR2(8 BYTE), 
	"GRGR_MCTR_LANG" VARCHAR2(4 BYTE), 
	"GRGR_EXTN_ADDR_IND" VARCHAR2(1 BYTE), 
	"WMDS_SEQ_NO" NUMBER(5,0), 
	"GRGR_TOTAL_EMPL" NUMBER(10,0), 
	"GRGR_TOTAL_ELIG" NUMBER(10,0), 
	"GRGR_TOTAL_CONTR" NUMBER(10,0), 
	"GRGR_POL_NO" VARCHAR2(30 BYTE), 
	"CRCY_ID" VARCHAR2(12 BYTE), 
	"GRGR_EIN" VARCHAR2(9 BYTE), 
	"GRGR_ERIS_MMDD" NUMBER(5,0), 
	"GRGR_RECD_DT" TIMESTAMP (3), 
	"GRGR_DEN_CHT_IND" VARCHAR2(1 BYTE), 
	"GRGR_CAP_CONV_DT" TIMESTAMP (3), 
	"GRGR_RUNOUT_DT" TIMESTAMP (3), 
	"GRGR_RUNOUT_EXCD" VARCHAR2(3 BYTE), 
	"GRGR_TRANS_ACCEPT" VARCHAR2(1 BYTE), 
	"GRGR_ITS_CODE" VARCHAR2(4 BYTE), 
	"GRGR_AUTONUM_IND" VARCHAR2(1 BYTE), 
	"GRGR_CONT_EFF_DT" TIMESTAMP (3), 
	"GRGR_TERM_PREM_MOS" NUMBER(5,0), 
	"GRGR_RNST_TYPE" VARCHAR2(1 BYTE), 
	"GRGR_RNST_VAL" NUMBER(5,0), 
	"GRGR_LOCK_TOKEN" NUMBER(5,0), 
	"ATXR_SOURCE_ID" TIMESTAMP (3), 
	"SYS_LAST_UPD_DTM" TIMESTAMP (3), 
	"SYS_USUS_ID" VARCHAR2(48 BYTE), 
	"SYS_DBUSER_ID" VARCHAR2(48 BYTE), 
	"SYS_BITMAP_NVL" NUMBER(10,0), 
	"SYS_LAST_OFFSET_NVL" VARCHAR2(100 BYTE), 
	"GRGR_PUP_IND_NVL" VARCHAR2(1 BYTE) DEFAULT 'N'
   );

   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CK" IS 'Group Contrived Key - The system-generated key for this entity (such as the member or subscriber). A contrived key is a unique number which the system uses instead of the logical key element/s for the entity.  Further information can be found on the CER_CKEY_CONTRIVE table.';
   COMMENT ON COLUMN "CUSTOMERS"."CICI_ID" IS 'Client Identifier - Client ID. This represents a unique 2-character ID that can be used for security purposes reporting and optionally for mapping to General Ledger. The Client ID is defined in System Administration Client Definition Application.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ID" IS 'Group Identifier - Group ID';
   COMMENT ON COLUMN "CUSTOMERS"."PAGR_CK" IS 'Parent Group Contrived Key - The system-generated key for this entity (Parent Group).  A contrived key is a unique number which the system uses instead of the logical key element/s for the entity.  Further information can be found on the CER_CKEY_CONTRIVE table.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_NAME" IS 'Group Name - Group name';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ADDR1" IS 'Group Address Line 1 - Line 1 of the group address';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ADDR2" IS 'Group Address Line 2 - Line 2 of group address';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ADDR3" IS 'Group Address Line 3 - Line 3 of group address';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CITY" IS 'City - City';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_STATE" IS 'State - State';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ZIP" IS 'Zip Code - Zip code';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_COUNTY" IS 'County - County';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CTRY_CD" IS 'Country - Country code';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_PHONE" IS 'Group Phone Number - Telephone number starting with the 3-digit area code.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_PHONE_EXT" IS 'Phone Extension - Extension number';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_FAX" IS 'Group Fax Number - Fax telephone number for incoming faxes starting with the 3-digit area code.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_FAX_EXT" IS 'Fax Extension - Fax extension number';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_EMAIL" IS 'Email - Email address';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_MCTR_TYPE" IS 'Group Type - Unique identifier for this parent group group or subgroup.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_MCTR_VIP" IS 'Group VIP Type - ''Very Important'' status indicator.';
   COMMENT ON COLUMN "CUSTOMERS"."MCAR_AREA_ID" IS 'Area Identifier - Service or network area defined by a zip code or range of zip codes used to define the geographic perimeters for either the subscriber''s home address the location of the practitioner and/or the location of the facility.';
   COMMENT ON COLUMN "CUSTOMERS"."CSCS_ID" IS 'Class Identifier - Class Identification number';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_STS" IS 'Group Status - The status of the Group.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ORIG_EFF_DT" IS 'Group Original Effective Date - Date when this parent group group or subgroup began active billing and claims processing for this plan.  This date must be on or after the effective date of the Provider agreement for the plan.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_TERM_DT" IS 'Group Termination Date - Date when this parent group group or subgroup ended its link with this plan. When you end a group link to a plan all subscribers or members are also discontinued from this plan automatically.Note: This date must be on or after the Group and Provider Agreement effective dates for the plan.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_MCTR_TRSN" IS 'Group Termination Reason - Termination reason';
   COMMENT ON COLUMN "CUSTOMERS"."EXCD_ID" IS 'Explanation Code - Eligibility and claims processing status code for this parent group group or subgroup.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_RNST_DT" IS 'Group Reinstatement Date - Reinstatement date';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CONV_DT" IS 'Group Conversion Date - Conversion date.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_RENEW_MMDD" IS 'Renewal Date - Renewal date for the Group in MM/DD format';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_PREV_ANNV_DT" IS 'Prior Anniversary - Prior anniversary date for the group.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CURR_ANNV_DT" IS 'Current Anniversary - Current anniversary date for the group.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_NEXT_ANNV_DT" IS 'Next Anniversary - Next anniversary date for the group.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_MCTR_PTYP" IS 'Policy Type - Policy type.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_UNDW_USUS_ID" IS 'Underwriter User ID - Underwriter''s User ID.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CAP_IND" IS 'Group Capitation Indicator - Capitation batch run indicator.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_LAST_CAP_DT" IS 'Group Last Capitation Date - Last capitation allocation batch run date.  This is maintained in the CMC_CRGH_GRGR_HIST table CRBH_PAY_DT column for the GRGR_CK.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CAP_BAT_STS" IS 'Group Capitation Status - Capitation allocation batch run status for the group.  The Cap Batch Status is maintained in the CMC_CRGH_GRGR_HIST table CRGH_STS column for the GRGR_CK.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_BILL_LEVEL" IS 'Billing Level - Billing entity level at which a bill will be generated for this group.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_LMT_ADJ_MOS" IS 'Billing Adjustment Limit Months - Adjustments limit months';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_BL_CONV_DT" IS 'Billing Conversion Date - Billing conversion date.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_NAME_XLOW" IS 'Case Insensitive Field - System generated data element that allows search criteria to be case insensitive.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CITY_XLOW" IS 'Case Insensitive Field - System generated data element that allows search criteria to be case insensitive.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_MCTR_LANG" IS 'Group language indicator - Primary language of the related entity.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_EXTN_ADDR_IND" IS 'Group external address indicator - External address indicator';
   COMMENT ON COLUMN "CUSTOMERS"."WMDS_SEQ_NO" IS 'User Defined Warning Message - Used to attach an application specific (Claims UM or Customer Service)  user defined warning message to a row within the corresponding application so that during processing in Claims UM or Customer Service the system will match the user''s security level to that associated with the message linked to the sequence number to determine if the system should require the process to be pended for additional review.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_TOTAL_EMPL" IS 'Total Number of Employees - Total number of employees including full time and part time etc. employed by the group.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_TOTAL_ELIG" IS 'Total Number of Eligible Employees - Total number of employees who are eligible to receive benefits.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_TOTAL_CONTR" IS 'Total Number of Contracts - Total number of contracts sold for this group.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_POL_NO" IS 'Policy Code - Policy Code for this group.';
   COMMENT ON COLUMN "CUSTOMERS"."CRCY_ID" IS 'Capitation Cycle ID - Cycle ID for selective capitation.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_EIN" IS 'Employer Identification Number - Employer Identification number.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ERIS_MMDD" IS 'ERISA Plan Year - ERISA plan year by MMDD (month and day).';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_RECD_DT" IS 'Received Date - Contract or addendum received date';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_DEN_CHT_IND" IS 'PBA Inclusion Indicator - Indicates whether this Group is participating in Payment Bundling Administration.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CAP_CONV_DT" IS 'Cap Conversion Date - Capitation processing begin date.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_RUNOUT_DT" IS 'Group Claim Runout Date - Last date claims will be accepted for processing.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_RUNOUT_EXCD" IS 'Group Claim Runout Explanation Code - The explanation code used to disallow claims received after the runout date';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_TRANS_ACCEPT" IS 'Group Accumulator Transfer Acceptance Indicator - Indicates whether the Group accepts accumulator transfers.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_ITS_CODE" IS 'ITS Host - Indicates if the group is used for ITS Host Processing';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_AUTONUM_IND" IS 'Auto Number Indicator - Subscriber ID Auto-numbering indicator. A ''Y-Yes'' value cannot be changed to ''N-No'' once a group has one or more subscribers saved to the database. This is for release 4.1 and forward.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_CONT_EFF_DT" IS 'Contract Effective Date - Contract begin date';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_TERM_PREM_MOS" IS 'Terminal Billing Months - Number of months the group will bill for terminal billing. (valid values: 0-4)';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_RNST_TYPE" IS 'Reinstate Type - Group Reinstatement Period Type';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_RNST_VAL" IS 'Reinstate Value - Group Reinstatement Period Value.  Valid values 0 -999';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_LOCK_TOKEN" IS 'Lock Token - A system generated numeric entry used to prevent one user''s change to a row from overlaying another user''s concurrent change to the same row.  The first user to complete a ''save'' for the row has priority over all other users of the row until they exit the application being saved.';
   COMMENT ON COLUMN "CUSTOMERS"."ATXR_SOURCE_ID" IS 'Attachment Source Id - The key to the attachments for this record.  This value is system generated when the record is saved with attachments.  Attachments include such things as memos notes letters and user fields.  Further information can be found on the CER_ATXR_ATTACH_U table.';
   COMMENT ON COLUMN "CUSTOMERS"."SYS_LAST_UPD_DTM" IS 'Last Update Datetime - The date and time of the last update to the row.';
   COMMENT ON COLUMN "CUSTOMERS"."SYS_USUS_ID" IS 'Last Update User ID - System user id of user applying database change. Entry triggered by database update.';
   COMMENT ON COLUMN "CUSTOMERS"."SYS_DBUSER_ID" IS 'Last Update DBMS User ID - Database User ID of user applying file. Entry triggered by database update.';
   COMMENT ON COLUMN "CUSTOMERS"."SYS_BITMAP_NVL" IS 'Bitmap Indicator -  Bitmap Indicator used to determine if the entity was published.  Column is not used by Facets.';
   COMMENT ON COLUMN "CUSTOMERS"."SYS_LAST_OFFSET_NVL" IS 'Last Offset Location -  Location within the state stream where the last published entity lives.  Column is not used by Facets.';
   COMMENT ON COLUMN "CUSTOMERS"."GRGR_PUP_IND_NVL" IS 'Group Pend Until Paid Indicator - Group Eligibility Pend Until Paid Indicator. Works with BLPE_PEND_IND to control if a member''s eligibility is pended until the selected billing due date is in a paid status';
   COMMENT ON TABLE "CUSTOMERS"  IS 'Group indicative data - This table maintains indicative data for a group.';
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_ATXR
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_ATXR" ON "CUSTOMERS" ("ATXR_SOURCE_ID");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_CITY
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_CITY" ON "CUSTOMERS" ("GRGR_CITY");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_CITY_XLOW
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_CITY_XLOW" ON "CUSTOMERS" ("GRGR_CITY_XLOW");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_CYCLE
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_CYCLE" ON "CUSTOMERS" ("CRCY_ID");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_ITS_CODE
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_ITS_CODE" ON "CUSTOMERS" ("GRGR_ITS_CODE");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_NAME
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_NAME" ON "CUSTOMERS" ("GRGR_NAME");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_NAME_XLOW
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_NAME_XLOW" ON "CUSTOMERS" ("GRGR_NAME_XLOW");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_PAGR_CK
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_PAGR_CK" ON "CUSTOMERS" ("PAGR_CK") ;
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_POL_NO
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_POL_NO" ON "CUSTOMERS" ("GRGR_POL_NO")  ;
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_PRIMARY
--------------------------------------------------------

  CREATE UNIQUE INDEX "CUSTOMERS"."CMCX_GRGR_PRIMARY" ON "CUSTOMERS" ("GRGR_CK") ;
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_SECOND
--------------------------------------------------------

  CREATE UNIQUE INDEX "CUSTOMERS"."CMCX_GRGR_SECOND" ON "CUSTOMERS" ("GRGR_ID");
--------------------------------------------------------
--  DDL for Index CMCX_GRGR_ZIP
--------------------------------------------------------

  CREATE INDEX "CUSTOMERS"."CMCX_GRGR_ZIP" ON "CUSTOMERS" ("GRGR_ZIP") ;

  ALTER TABLE "CUSTOMERS" MODIFY ("WMDS_SEQ_NO" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_TOTAL_EMPL" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_TOTAL_ELIG" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_TOTAL_CONTR" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_POL_NO" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("CRCY_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_EIN" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ERIS_MMDD" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_RECD_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_DEN_CHT_IND" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CAP_CONV_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_RUNOUT_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_RUNOUT_EXCD" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_TRANS_ACCEPT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ITS_CODE" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_AUTONUM_IND" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CONT_EFF_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_TERM_PREM_MOS" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_RNST_TYPE" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_RNST_VAL" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_LOCK_TOKEN" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("ATXR_SOURCE_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_PUP_IND_NVL" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" ADD SUPPLEMENTAL LOG GROUP "GGS_278241" ("GRGR_CK") ALWAYS;
  ALTER TABLE "CUSTOMERS" ADD SUPPLEMENTAL LOG DATA (FOREIGN KEY) COLUMNS;
  ALTER TABLE "CUSTOMERS" ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;
  ALTER TABLE "CUSTOMERS" ADD SUPPLEMENTAL LOG DATA (UNIQUE INDEX) COLUMNS;
  ALTER TABLE "CUSTOMERS" ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
  ALTER TABLE "CUSTOMERS" ADD CONSTRAINT "PK_VJB_GRGR" PRIMARY KEY ("GRGR_CK")
  USING INDEX "CUSTOMERS"."CMCX_GRGR_PRIMARY"  ENABLE;
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CK" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("CICI_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("PAGR_CK" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_NAME" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ADDR1" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ADDR2" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ADDR3" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CITY" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_STATE" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ZIP" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_COUNTY" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CTRY_CD" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_PHONE" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_PHONE_EXT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_FAX" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_FAX_EXT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_EMAIL" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_MCTR_TYPE" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_MCTR_VIP" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("MCAR_AREA_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("CSCS_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_STS" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_ORIG_EFF_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_TERM_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_MCTR_TRSN" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("EXCD_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_RNST_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CONV_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_RENEW_MMDD" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_PREV_ANNV_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CURR_ANNV_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_NEXT_ANNV_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_MCTR_PTYP" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_UNDW_USUS_ID" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CAP_IND" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_LAST_CAP_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CAP_BAT_STS" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_BILL_LEVEL" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_LMT_ADJ_MOS" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_BL_CONV_DT" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_NAME_XLOW" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_CITY_XLOW" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_MCTR_LANG" NOT NULL ENABLE);
  ALTER TABLE "CUSTOMERS" MODIFY ("GRGR_EXTN_ADDR_IND" NOT NULL ENABLE);
EOF

