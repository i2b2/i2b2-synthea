/*Loading synthea files into synthea_tables
synthea tables require data for DATE column to be in DATE format
When importing synthea files with date column format YYYY-MM-DD"T"HH24:MI:SS"Z",
--first import the file into temp table with date column datatype varchar
--Then, load the imported temp table data  into synthea tables using date formatted insert statement
Below are example statements you can use for importing to synthea  tables
Replace the <temp table> with the name of the temp table you have used for importing synthea file*/
/*
insert into synthea_immunizations
select to_char(to_date(date_IM,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,PATIENT,ENCOUNTER,CODE,DESCRIPTION,BASE_COST
FROM <temp table>
INSERT INTO SYNTHEA_DEVICES
select to_char(to_date(START_DEV,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,PATIENT,ENCOUNTER,CODE,DESCRIPTION,UDI from <temp table>
INSERT INTO Synthea_Medications
select to_char(to_date(START_MED,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,PATIENT,PAYER,
ENCOUNTER,CODE ,DESCRIPTION,BASE_COST,PAYER_COVERAGE,DISPENSES,TOTALCOST,REASONCODE,REASONDESCRIPTION FROM <temp table>
INSERT INTO Synthea_conditions
select to_char(to_date(START_CON,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,PATIENT,ENCOUNTER,CODE,DESCRIPTION from <temp table>
INSERT INTO SYNTHEA_PROCEDURES 
select to_char(to_date(DATE_PROC,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
PATIENT,ENCOUNTER,CODE,DESCRIPTION,BASE_COST,REASONCODE,REASONDESCRIPTION from <temp table>
INSERT INTO SYNTHEA_CAREPLANS
select Id, to_char(to_date(START_CP,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,PATIENT,ENCOUNTER,CODE,DESCRIPTION,REASONCODE,        REASONDESCRIPTION from <temp table>
INSERT INTO SYNTHEA_ENCOUNTERS
select Id,to_char(to_date(START_ENC,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,PATIENT,ORGANIZATION,PROVIDER,PAYER,ENCOUNTERCLASS,CODE,DESCRIPTION,
BASE_ENCOUNTER_COST,TOTAL_CLAIM_COST,PAYER_COVERAGE,REASONCODE,REASONDESCRIPTION from <temp table>
INSERT INTO Synthea_observations
 select to_char(to_date(DATE_OB,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
PATIENT, ENCOUNTER,CODE,DESCRIPTION,VALUE,UNITS,TYPE from <temp table>
INSERT INTO Synthea_allergies
select to_char(to_date(START_AL,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,
to_char(to_date(STOP,'YYYY-MM-DD"T"HH24:MI:SS"Z"'),'YYYY-MM-DD')::date,PATIENT, ENCOUNTER,CODE,DESCRIPTION from <temp table>
*/

create or replace
function public.synthea_to_i2b2_postgres(out errormsg text)
returns text
language plpgsql
as $function$
begin

execute 'DROP TABLE IF EXISTS ENCOUNTER_MAPPING CASCADE ';

execute 'DROP TABLE IF EXISTS PATIENT_MAPPING CASCADE ';

raise notice 'creating table ENCOUNTER_MAPPING';

execute 'create table ENCOUNTER_MAPPING (
ENCOUNTER_IDE VARCHAR(200) NOT NULL,
ENCOUNTER_IDE_SOURCE VARCHAR(50) NOT NULL,
PROJECT_ID VARCHAR(50) NOT NULL,
ENCOUNTER_NUM   SERIAL  NOT NULL,
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

execute 'CREATE  INDEX EM_IDX_ENCPATH ON ENCOUNTER_MAPPING(ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE, PATIENT_IDE, PATIENT_IDE_SOURCE, ENCOUNTER_NUM)';

execute 'CREATE  INDEX EM_IDX_UPLOADID ON ENCOUNTER_MAPPING(UPLOAD_ID)';

execute 'CREATE INDEX EM_ENCNUM_IDX ON ENCOUNTER_MAPPING(ENCOUNTER_NUM)';

raise notice 'creating table PATIENT_MAPPING';

execute 'create table PATIENT_MAPPING (
PATIENT_IDE         VARCHAR(200)  NOT NULL,
PATIENT_IDE_SOURCE	VARCHAR(50)  NOT NULL,
PATIENT_NUM     SERIAL  NOT NULL,
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

execute 'CREATE  INDEX PM_IDX_UPLOADID ON PATIENT_MAPPING(UPLOAD_ID)';

execute 'CREATE INDEX PM_PATNUM_IDX ON PATIENT_MAPPING(PATIENT_NUM)';

execute 'CREATE INDEX PM_ENCPNUM_IDX ON PATIENT_MAPPING(PATIENT_IDE,PATIENT_IDE_SOURCE,PATIENT_NUM)';

raise notice 'load patient_mapping';

execute 'insert into PATIENT_MAPPING(patient_ide, patient_ide_source, patient_ide_status, project_id, upload_date, update_date, download_date, import_date, sourcesystem_cd)
select distinct id, ''SYNTHEA'', ''A'', ''@'', CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE , ''SYNTHEA''
from SYNTHEA_PATIENTS';

raise notice 'load ENCOUNTER_MAPPING';

execute 'insert into ENCOUNTER_MAPPING(encounter_ide, encounter_ide_source, encounter_ide_status, patient_ide, patient_ide_source, project_id, upload_date, update_date, download_date, import_date, sourcesystem_cd)
select distinct id, ''SYNTHEA'', ''A'', patient, ''SYNTHEA'', ''@'', CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''
from SYNTHEA_ENCOUNTERS';

raise notice 'truncate PATIENT_DIMENSION';

execute 'truncate PATIENT_DIMENSION';

insert
into
PATIENT_DIMENSION (patient_num,
vitAL_Status_cd,
birth_date,
death_date,
sex_cd,
age_in_years_num,
race_cd,
MARITAL_STATUS_CD,
zip_cd,
statecityzip_path,
update_date,
download_date,
import_date,
sourcesystem_cd)
select
distinct a.patient_num ,
case
when b.deathdate is null then 'A'
else 'D'
end,
b.birthdate,
case
when b.deathdate is null then null
else b.deathdate
end,
b.gender,
0,
b.race,
b.marital,
b.zip,
b.state || ' / ' || b.city || ' / ' || b.zip ,
CURRENT_DATE,
CURRENT_DATE,
CURRENT_DATE,
'SYNTHEA'
from
PATIENT_MAPPING a,
SYNTHEA_PATIENTS b
where
a.patient_ide = b.id;

raise notice 'truncate  VISIT_DIMENSION';

execute 'truncate  VISIT_DIMENSION';

raise notice 'load VISIT_DIMENSION';

execute 'insert into VISIT_DIMENSION (encounter_num, patient_num, active_status_cd, start_date, end_date,inout_cd, location_cd
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
else cast(c.encounterclass as varchar(1000))
end,d.utilization,
0,
d.name || '' / '' || d.address || '' / ''|| d.state || '' / '' || d.zip,CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''
from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_ENCOUNTERS c, SYNTHEA_ORGANIZATIONS d
where a.encounter_ide = c.id
and a.patient_ide = b.patient_ide
and c.organization = d.id';

raise notice 'truncate provider_dimension';

execute 'truncate provider_dimension';

raise notice 'load provider_dimension';

execute 'insert into provider_dimension (provider_id, provider_path, name_char,  update_date, download_date, import_date, sourcesystem_cd)
SELECT distinct a.Id
, b.name ||'' / ''|| b.address || '' / ''|| b.state || '' / '' || b.zip
, a.name,CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''
FROM  SYNTHEA_PROVIDERS a,
SYNTHEA_ORGANIZATIONS b
where a.organization = b.id';

raise notice 'truncate OBSERVATION_FACT';

execute 'truncate OBSERVATION_FACT';

raise notice 'loading DEM|Sex facts';

insert
into
OBSERVATION_FACT (ENCOUNTER_NUM
,
PATIENT_NUM
,
CONCEPT_CD
,
PROVIDER_ID
,
START_DATE
,
MODIFIER_CD
,
INSTANCE_NUM
,
VALTYPE_CD
,
TVAL_CHAR
,
NVAL_NUM
,
VALUEFLAG_CD
,
UNITS_CD
,
END_DATE
,
CONFIDENCE_NUM
,
UPDATE_DATE
,
DOWNLOAD_DATE
,
IMPORT_DATE
,
SOURCESYSTEM_CD)
select
distinct -1,
patient_num,
'DEM|SEX:' || sex_cd,
'@',
BIRTH_DATE,
'@',
1,
'T' as valtype_cd,
sex_cd as tval_char,
0 as nval_num,
'@' as valueflag_cd,
null,
cast(null as timestamp) ,
1,
CURRENT_DATE ,
CURRENT_DATE ,
CURRENT_DATE,
'SYNTHEA'
from
PATIENT_DIMENSION
where
birth_date is not null;

raise notice 'loading DEM|Race facts';

insert
into
OBSERVATION_FACT (ENCOUNTER_NUM
,
PATIENT_NUM
,
CONCEPT_CD
,
PROVIDER_ID
,
START_DATE
,
MODIFIER_CD
,
INSTANCE_NUM
,
VALTYPE_CD
,
TVAL_CHAR
,
NVAL_NUM
,
VALUEFLAG_CD
,
UNITS_CD
,
END_DATE
,
CONFIDENCE_NUM
,
UPDATE_DATE
,
DOWNLOAD_DATE
,
IMPORT_DATE
,
SOURCESYSTEM_CD)
select
distinct -1,
patient_num,
case
when RACE_CD = 'native' then 'DEM|RACE:NA'
when race_cd = 'other' then 'DEM|RACE:NI'
when race_cd = 'white' then 'DEM|RACE:W'
when race_cd = 'black' then 'DEM|RACE:B'
when race_cd = 'asian' then 'DEM|RACE:AS'
else race_cd
end ,
'@',
BIRTH_DATE,
'@',
1
,
'T' as valtype_cd,
race_cd as tval_char,
0 as nval_num,
'@' as valueflag_cd,
null,
cast(null as timestamp),
1,
CURRENT_DATE ,
CURRENT_DATE ,
CURRENT_DATE,
'SYNTHEA'
from
PATIENT_DIMENSION
where
BIRTH_DATE is not null;

raise notice 'loading vital stats';

insert
into
OBSERVATION_FACT (ENCOUNTER_NUM
,
PATIENT_NUM
,
CONCEPT_CD
,
PROVIDER_ID
,
START_DATE
,
MODIFIER_CD
,
INSTANCE_NUM
,
VALTYPE_CD
,
TVAL_CHAR
,
NVAL_NUM
,
VALUEFLAG_CD
,
UNITS_CD
,
END_DATE
,
CONFIDENCE_NUM
,
UPDATE_DATE
,
DOWNLOAD_DATE
,
IMPORT_DATE
,
SOURCESYSTEM_CD)
select
distinct -1,
patient_num,
'DEM|VITAL STATUS:D',
'@',
death_DATE,
'@',
1
,
'T' as valtype_cd,
race_cd as tval_char,
0 as nval_num,
'@' as valueflag_cd,
null,
cast(null as timestamp),
1,
CURRENT_DATE ,
CURRENT_DATE ,
CURRENT_DATE,
'SYNTHEA'
from
PATIENT_DIMENSION
where
DEATH_DATE is not null
and BIRTH_DATE is not null;

raise notice 'loading observations';

execute 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
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
case when c.type = ''text'' then cast(c.value as varchar(1000)) else ''E'' end as tval_char,
case when c.type = ''numeric'' then cast(c.value as decimal)  else 0 end as nval_num,
case when c.type = ''numeric'' then ''@'' else null end as valueflag_cd,
c.units,
1,
CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''
from encounter_mapping a, patient_mapping b, Synthea_observations c, synthea_encounters d
where a.encounter_ide = c.encounter
and b.patient_ide = c.patient
and c.encounter = d.id';

raise notice 'loading medications';

execute 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
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
0,
c.stop,
1,
CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''
from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_MEDICATIONS c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter
and b.patient_ide = c.patient
and c.encounter = d.id';
-- load conditions
raise notice 'loading conditions ';

execute 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
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
0 as nval_num,
''@''   as valueflag_cd,
0,c.stop,
1,
CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b
, Synthea_conditions c, SYNTHEA_ENCOUNTERS d, SNOMED_to_ICD10 e
where a.encounter_ide = c.encounter
and b.patient_ide = c.patient
and c.encounter = d.id
and e.referencedComponentId = c.code
and e.maptarget is not null';

raise notice 'loading careplans  ';

execute 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
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
0 as nval_num,
''@''   as valueflag_cd,
0,c.stop,
1,
CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_CAREPLANS c, SYNTHEA_ENCOUNTERS d, SNOMED_to_ICD10 e
where a.encounter_ide = c.encounter
and b.patient_ide = c.patient
and c.encounter = d.id
and e.referencedComponentId = c.REASONCODE
and e.maptarget is not null';

raise notice 'loading immunizations  ';

execute 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
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
else ''SNOMED:'' || cast(c.code as varchar(1000)) end as concept_cd,
''@'',c.date_im,
''@'',
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code, ''@'',c.date_im
order by  a.encounter_num, b.patient_num,  c.code, c.date_im
)
,
''T'' as valtype_cd,
null  as tval_char,
0 as nval_num,
''@''   as valueflag_cd,
0,
CURRENT_DATE,
1,
CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''
from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_IMMUNIZATIONS c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter
and b.patient_ide = c.patient
and c.encounter = d.id';

raise notice 'loading devices  ';

execute 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
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
else ''SNOMED:'' || cast(c.code as varchar(1000)) end as concept_cd,
''@'',c.start_dev,
''@'',
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code,c.start_dev
order by  a.encounter_num, b.patient_num,  c.code,c.start_dev
)
,
''T'' as valtype_cd,
null  as tval_char,
0 as nval_num,
''@''   as valueflag_cd,
0,
c.stop,
1,
CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_DEVICES c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter
and b.patient_ide = c.patient
and c.encounter = d.id';

raise notice 'loading procedures  ';

execute 'insert into OBSERVATION_FACT (ENCOUNTER_NUM
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
select distinct  a.encounter_num, b.patient_num, ''SNOMED:'' || cast(c.code as varchar(1000)), ''@'', c.date_proc,
''@'',
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code, c.date_proc
order by  a.encounter_num, b.patient_num,  c.code, c.date_proc
)
,
''T'' as valtype_cd,
null  as tval_char,
0 as nval_num,
''@''   as valueflag_cd,
CURRENT_DATE,
CURRENT_DATE,
1,
CURRENT_DATE ,CURRENT_DATE ,CURRENT_DATE, ''SYNTHEA''

from ENCOUNTER_MAPPING a, PATIENT_MAPPING b, SYNTHEA_PROCEDURES c, SYNTHEA_ENCOUNTERS d
where a.encounter_ide = c.encounter
and b.patient_ide = c.patient
and c.encounter = d.id';
--update age_num_in_years
raise notice 'update age_num_in_years ';

begin
update
PATIENT_DIMENSION
set
AGE_IN_YEARS_NUM =
case
when DEATH_DATE is null then
trunc(extract(
EPOCH from (now() - (birth_date)
)/ 3600)/ 8766)
else trunc(extract(
EPOCH from (death_date - (birth_date)
)/ 3600)/ 8766)
end;
-- update length of stay
raise notice 'update length of stay';

begin
update
VISIT_DIMENSION
set
length_of_stay = trunc(extract(
EPOCH from (end_date - (start_date))/ 3600)/ 24);
end;
end;

exception
when others then
raise exception 'An error was encountered - % -ERROR- %',
sqlstate,
sqlerrm;
end;

$function$
;
