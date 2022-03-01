/*Loading synthea files into synthea_tables
synthea tables require data for DATE column to be in DATE format
When importing synthea files with date column format YYYY-MM-DD"T"HH24:MI:SS"Z",
--first import the file into temp table with date column datatype varchar2
--Then, load the imported temp table data  into synthea tables using date formatted insert statement
Below are example statements you can use for importing to synthea  tables
Replace the <temp table> with the name of the temp table you have used for importing synthea file*/
/*
--synthea_immunizations
insert into synthea_immunizations
select to_char(to_date(date_IM,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),PATIENT,ENCOUNTER,CODE,DESCRIPTION,BASE_COST
FROM <temp table>
--INSERT INTO SYNTHEA_DEVICES 
select to_char(to_date(START_DEV,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
STOP,PATIENT,ENCOUNTER,CODE,DESCRIPTION,UDI from <temp table>
--INSERT INTO Synthea_Medications 
select to_char(to_date(START_MED,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),PATIENT,PAYER,
ENCOUNTER,CODE ,DESCRIPTION,BASE_COST,PAYER_COVERAGE,DISPENSES,TOTALCOST,REASONCODE,REASONDESCRIPTION FROM <temp table>
--INSERT INTO Synthea_conditions 
select to_char(to_date(START_CON,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),PATIENT,ENCOUNTER,CODE,DESCRIPTION from <temp table>
--INSERT INTO SYNTHEA_PROCEDURES  
select to_char(to_date(DATE_PROC,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
PATIENT,ENCOUNTER,CODE,DESCRIPTION,BASE_COST,REASONCODE,REASONDESCRIPTION from <temp table>
--INSERT INTO SYNTHEA_CAREPLANS 
select Id, to_char(to_date(START_CP,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
 to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),PATIENT,ENCOUNTER,CODE,DESCRIPTION,REASONCODE,	REASONDESCRIPTION from <temp table>
-- INSERT INTO SYNTHEA_ENCOUNTERS 
select Id,to_char(to_date(START_ENC,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),PATIENT,ORGANIZATION,PROVIDER,PAYER,ENCOUNTERCLASS,CODE,DESCRIPTION,
BASE_ENCOUNTER_COST,TOTAL_CLAIM_COST,PAYER_COVERAGE,REASONCODE,REASONDESCRIPTION from <temp table>
-- INSERT INTO Synthea_observations 
 select to_char(to_date(DATE_OB,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
PATIENT, ENCOUNTER,CODE,DESCRIPTION,VALUE,UNITS,TYPE from <temp table>
--INSERT INTO Synthea_allergies 
select to_char(to_date(START_AL,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"')),PATIENT, ENCOUNTER,CODE,DESCRIPTION from <temp table>
*/
CREATE OR REPLACE NONEDITIONABLE PROCEDURE synthea_to_i2b2_oracle IS
    cnt NUMBER;
BEGIN 

-- drop ENCOUNTER_MAPPING and PATIENT_MAPPING, ENCOUNTER_MAPPING tables if they exist
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'ENCOUNTER_MAPPING';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE ENCOUNTER_MAPPING';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'PATIENT_MAPPING';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE PATIENT_MAPPING';
    END IF;
    COMMIT;
--EXECUTE IMMEDIATE 'truncate table PATIENT_DIMENSION'; 
--commit;
-- create table ENCOUNTER_MAPPING
    dbms_output.put_line('create table ENCOUNTER_MAPPING');
    EXECUTE IMMEDIATE 'create table ENCOUNTER_MAPPING  (
	  ENCOUNTER_IDE VARCHAR(200) NOT NULL,
  ENCOUNTER_IDE_SOURCE VARCHAR(50) NOT NULL,
  PROJECT_ID VARCHAR(50) NOT NULL,
  ENCOUNTER_NUM int GENERATED ALWAYS AS IDENTITY(START WITH 1 
       INCREMENT BY 1 
       MINVALUE 1 
       NOMAXVALUE 
       NOCYCLE 
       NOCACHE 
       ORDER)NOT NULL,
  PATIENT_IDE VARCHAR(200) NOT NULL,
  PATIENT_IDE_SOURCE VARCHAR(50) NOT NULL,
  ENCOUNTER_IDE_STATUS VARCHAR(50) NULL,
  UPLOAD_DATE DATE NULL,
  UPDATE_DATE DATE NULL,
  DOWNLOAD_DATE DATE NULL,
  IMPORT_DATE DATE NULL,
  SOURCESYSTEM_CD VARCHAR(50) NULL ,
  UPLOAD_ID INT NULL ,
CONSTRAINT ENCOUNTER_MAPPING_PK PRIMARY KEY(ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE, PROJECT_ID, PATIENT_IDE, PATIENT_IDE_SOURCE)
)';
    COMMIT;
    EXECUTE IMMEDIATE 'CREATE  INDEX EM_IDX_ENCPATH ON ENCOUNTER_MAPPING(ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE, PATIENT_IDE, PATIENT_IDE_SOURCE, ENCOUNTER_NUM)';
    COMMIT;
    EXECUTE IMMEDIATE 'CREATE  INDEX EM_IDX_UPLOADID ON ENCOUNTER_MAPPING(UPLOAD_ID)';
    COMMIT;
    EXECUTE IMMEDIATE 'CREATE INDEX EM_ENCNUM_IDX ON ENCOUNTER_MAPPING(ENCOUNTER_NUM)';
    COMMIT;
-- create table PATIENT_MAPPING
    dbms_output.put_line('create table PATIENT_MAPPING');
    EXECUTE IMMEDIATE 'CREATE TABLE PATIENT_MAPPING ( 
    PATIENT_IDE         VARCHAR(200)  NOT NULL,
    PATIENT_IDE_SOURCE	VARCHAR(50)  NOT NULL,
     PATIENT_NUM      int GENERATED ALWAYS AS IDENTITY(START WITH 1 
       INCREMENT BY 1 
       MINVALUE 1 
       NOMAXVALUE 
       NOCYCLE 
       NOCACHE 
       ORDER)not null,
    PATIENT_IDE_STATUS	VARCHAR(50) NULL,
    PROJECT_ID          VARCHAR(50) NOT NULL,
    UPLOAD_DATE       DATE  NULL,
    UPDATE_DATE       DATE NULL,
    DOWNLOAD_DATE     DATE  NULL,
    IMPORT_DATE       DATE  NULL,
    SOURCESYSTEM_CD   	VARCHAR(50) NULL,
    UPLOAD_ID         	INT NULL,
 CONSTRAINT PATIENT_MAPPING_PK PRIMARY KEY(PATIENT_IDE, PATIENT_IDE_SOURCE, PROJECT_ID)

 )';
    COMMIT;
    EXECUTE IMMEDIATE 'CREATE  INDEX PM_IDX_UPLOADID ON PATIENT_MAPPING(UPLOAD_ID)';
    COMMIT;
    EXECUTE IMMEDIATE 'CREATE INDEX PM_PATNUM_IDX ON PATIENT_MAPPING(PATIENT_NUM)';
    COMMIT;
    EXECUTE IMMEDIATE 'CREATE INDEX PM_ENCPNUM_IDX ON PATIENT_MAPPING(PATIENT_IDE,PATIENT_IDE_SOURCE,PATIENT_NUM)';
    COMMIT;
-- load PATIENT_MAPPING 
    dbms_output.put_line('loading PATIENT_MAPPING');
    EXECUTE IMMEDIATE 'insert into PATIENT_MAPPING(patient_ide, patient_ide_source, patient_ide_status, project_id, upload_date, update_date, download_date, import_date, sourcesystem_cd)
select distinct id, ''SYNTHEA'', ''A'', ''@'', sysdate ,sysdate ,sysdate ,sysdate , ''SYNTHEA''
from SYNTHEA_PATIENTS';
    COMMIT;
   -- load ENCOUNTER_MAPPING
       dbms_output.put_line('loading ENCOUNTER_MAPPING');
    EXECUTE IMMEDIATE 'insert into ENCOUNTER_MAPPING(encounter_ide, encounter_ide_source, encounter_ide_status, patient_ide, patient_ide_source, project_id, upload_date, update_date, download_date, import_date, sourcesystem_cd)
select distinct id, ''SYNTHEA'', ''A'', patient, ''SYNTHEA'', ''@'', sysdate ,sysdate ,sysdate ,sysdate, ''SYNTHEA''
from SYNTHEA_ENCOUNTERS';
    COMMIT;

-- load  PATIENT_DIMENSION
   dbms_output.put_line('loading PATIENT_DIMENSION');
    EXECUTE IMMEDIATE 'truncate table PATIENT_DIMENSION';
    COMMIT;
    EXECUTE IMMEDIATE 'insert into PATIENT_DIMENSION (patient_num, vitAL_Status_cd, birth_date,death_date, sex_cd, age_in_years_num, race_cd, MARITAL_STATUS_CD,
zip_cd, statecityzip_path,  update_date, download_date, import_date, sourcesystem_cd)
select distinct a.patient_num ,
case when b.deathdate is null then ''A'' else ''D'' end,
b.birthdate,
case when b.deathdate is null then null else b.deathdate end,
b.gender,null, b.race, b.marital, b.zip,b.state ||'' / ''|| b.city || '' / '' || b.zip ,
sysdate,sysdate,sysdate,''SYNTHEA''
from PATIENT_MAPPING a, SYNTHEA_PATIENTS b
where a.patient_ide = b.id';
    COMMIT;

-- load VISIT_DIMENSION
   dbms_output.put_line('loading VISIT_DIMENSION');
    EXECUTE IMMEDIATE 'truncate table VISIT_DIMENSION';
    COMMIT;
    EXECUTE IMMEDIATE 'insert into VISIT_DIMENSION (encounter_num, patient_num, active_status_cd, start_date, end_date,inout_cd, location_cd
, length_of_stay, location_path, update_date, download_date, import_date, sourcesystem_cd)
select distinct  a.encounter_num, b.patient_num, ''A'',c.start_enc,
c.stop,
case 
when c.encounterclass = ''ambulatory'' then ''A''
when c.encounterclass = ''emergency'' then ''E''
when c.encounterclass = ''inpatient'' then ''I''
when c.encounterclass = ''outpatient'' then ''O''
when c.encounterclass =''urgentcare'' then ''U''
when c.encounterclass = ''wellness'' then ''W''
else cast(c.encounterclass as varchar2(1000))
end,d.utilization,
null,
d.name || '' / '' || d.address || '' / ''|| d.state || '' / '' || d.zip,sysdate ,sysdate ,sysdate, ''SYNTHEA''
from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_ENCOUNTERS c, SYNTHEA_ORGANIZATIONS d
where a.encounter_ide = c.id
and a.patient_ide = b.patient_ide
and c.organization = d.id';
    COMMIT;
 
-- load provider_dimension 
    dbms_output.put_line('loading provider_dimension');
   EXECUTE IMMEDIATE 'truncate table provider_dimension';
   COMMIT;
    EXECUTE IMMEDIATE 'insert into provider_dimension (provider_id, provider_path, name_char,  update_date, download_date, import_date, sourcesystem_cd)
SELECT distinct a.Id
      , b.name ||'' / ''|| b.address || '' / ''|| b.state || '' / '' || b.zip
	  , a.name,sysdate ,sysdate ,sysdate, ''SYNTHEA''
  FROM  SYNTHEA_PROVIDERS a,
  SYNTHEA_ORGANIZATIONS b
  where a.organization = b.id';
    COMMIT;
 
-- load facts     
    EXECUTE IMMEDIATE 'truncate table OBSERVATION_FACT';
    commit;
    dbms_output.put_line('loading DEM|Sex');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
         ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  -1, patient_num, ''DEM|SEX:'' || sex_cd, ''@'', BIRTH_DATE, ''@'', 1,
''T'' as valtype_cd,
 sex_cd  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,
null,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''
from PATIENT_DIMENSION
where birth_date is not null';
    COMMIT;
    dbms_output.put_line('loading DEM|Race ');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
       ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct -1, patient_num, 
case when RACE_CD = ''native'' then ''DEM|RACE:NA'' 
 when race_cd = ''other'' then ''DEM|RACE:NI''
 when race_cd = ''white'' then ''DEM|RACE:W''
 when race_cd = ''black'' then ''DEM|RACE:B'' 
 when race_cd = ''asian'' then ''DEM|RACE:AS'' else race_cd end ,
  ''@'', BIRTH_DATE, ''@'', 
1
,
''T'' as valtype_cd,
 race_cd  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,
null,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''
from PATIENT_DIMENSION
where BIRTH_DATE is not null';
    COMMIT;

-- load vital stats
    dbms_output.put_line('loading DEM|vital stats');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
         ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select  distinct -1, patient_num, 
''DEM|VITAL STATUS:D'',
  ''@'', death_DATE, ''@'', 
1
,
''T'' as valtype_cd,
 race_cd  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,
null,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''
from PATIENT_DIMENSION
where DEATH_DATE is not null
and BIRTH_DATE is not null';
    COMMIT;

-- load observations
    dbms_output.put_line('loading observations');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
      ,UNITS_CD
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, ''LOINC:'' || c.code, ''@'',c.date_ob,''@'', 
row_number() over (partition by  a.encounter_num, ''@'',c.code, ''@'',c.date_ob
order by  a.encounter_num, b.patient_num, c.code,c.date_ob),
case when c.type = ''numeric'' then ''N'' else ''T'' end as valtype_cd,
case when c.type = ''text'' then cast(c.value as varchar2(1000)) else ''E'' end as tval_char,
case when c.type = ''numeric'' then cast(c.value as varchar2(1000)) else null end as nval_num,
case when c.type = ''numeric'' then ''@'' else null end as valueflag_cd,
c.units,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''
from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_OBSERVATIONS c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id';
    COMMIT;

-- load medications 
    dbms_output.put_line('loading medications');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT(ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
       ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, ''RXNORM:'' || c.code, ''@'',c.start_med,
''@'', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code, ''@'', c.start_med
order by  a.encounter_num, b.patient_num,  c.code,c.start_med
)
,
''N'' as valtype_cd,
 ''E''  as tval_char,
c.DISPENSES as nval_num,
 ''@''   as valueflag_cd,
null,
c.stop,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''
from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_MEDICATIONS c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id';
    COMMIT;

-- load conditions 
    dbms_output.put_line('loading conditions');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
      ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select  distinct a.encounter_num, b.patient_num, ''ICD10CM:'' || e.maptarget, ''@'', c.start_con, ''@'', 
row_number() over (partition by  a.encounter_num, b.patient_num,  e.maptarget,  c.start_con
order by  a.encounter_num, b.patient_num,  e.maptarget,   c.start_con
),
''T'' as valtype_cd,
 null  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,c.stop,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b
, Synthea_conditions c, SYNTHEA_ENCOUNTERS d, SNOMED_to_ICD10 e
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id
and e.referencedComponentId = c.code
and e.maptarget is not null';
    COMMIT;

-- load careplans 
    dbms_output.put_line('loading careplans');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
      ,UNITS_CD
      ,END_DATE
       ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, ''ICD10CM:'' || e.maptarget, ''@'',c.start_cp, ''@'', 
row_number() over (partition by  a.encounter_num, b.patient_num,  e.maptarget,  c.start_cp
order by  a.encounter_num, b.patient_num,  e.maptarget,   c.start_cp
)
,
''T'' as valtype_cd,
 null  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,c.stop,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_CAREPLANS c, SYNTHEA_ENCOUNTERS d, SNOMED_to_ICD10 e
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id
and e.referencedComponentId = c.REASONCODE
and e.maptarget is not null';
    COMMIT;

-- load immunizations 
    dbms_output.put_line('loading immunizations');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
      ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 
case when c.code = 140 then ''UMLS:C0744062'' 
 when c.code = 72506001	then ''UMLS:C0015357''
else ''SNOMED:'' || cast(c.code as varchar2(1000)) end as concept_cd,
 ''@'',c.date_im,
 ''@'', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code, ''@'',c.date_im
order by  a.encounter_num, b.patient_num,  c.code, c.date_im
)
,
''T'' as valtype_cd,
 null  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,
null,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''
from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_IMMUNIZATIONS c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id';
    COMMIT;

-- load devices 
    dbms_output.put_line('loading devices');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
      ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 
case when c.code = 449071006 then ''UMLS:C0199470'' 
 when c.code = 72506001	then ''UMLS:C0015357''
 when c.code = 705643001	then ''UMLS:C0021925''
 when c.code =706004007	then ''UMLS:C4534306''
 when c.code = 36965003	then ''DRG:475''
else ''SNOMED:'' || cast(c.code as varchar2(1000)) end as concept_cd,
 ''@'',c.start_dev,
 ''@'', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code,c.start_dev 
order by  a.encounter_num, b.patient_num,  c.code,c.start_dev
)
,
''T'' as valtype_cd,
 null  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,
c.stop,
''1'',
 sysdate ,sysdate ,sysdate, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_DEVICES c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id';
    COMMIT;

-- load procedures 
    dbms_output.put_line('loading procedures');
    EXECUTE IMMEDIATE 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
      ,PATIENT_NUM
      ,CONCEPT_CD
      ,PROVIDER_ID
      ,START_DATE
      ,MODIFIER_CD
      ,INSTANCE_NUM
      ,VALTYPE_CD
      ,TVAL_CHAR
      ,NVAL_NUM
      ,VALUEFLAG_CD
      ,UNITS_CD
      ,END_DATE
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, ''SNOMED:'' || cast(c.code as varchar2(1000)), ''@'', c.date_proc,
''@'', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code, c.date_proc
order by  a.encounter_num, b.patient_num,  c.code, c.date_proc
)
,
''T'' as valtype_cd,
 null  as tval_char,
null as nval_num,
 ''@''   as valueflag_cd,
null,
null,
''1'',
sysdate ,sysdate ,sysdate, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_PROCEDURES c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id';
    COMMIT;

--update age_num_in_years
    dbms_output.put_line('updating age_num_in_years');
    UPDATE patient_dimension
    SET
        age_in_years_num =
            CASE
                WHEN death_date IS NULL THEN
                    trunc(((sysdate - birth_date) * 24) / 8766)
                ELSE
                    trunc(((death_date - birth_date) * 24) / 8766)
            END;

    COMMIT;

-- update length of stay
    dbms_output.put_line('updating length of stay');
    UPDATE visit_dimension
    SET
        length_of_stay = trunc(((start_date - end_date) * 24) / 8766);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(sqlerrm);
END;