

CREATE procedure [dbo].[synthea_to_i2b2] as
DROP TABLE ENCOUNTER_MAPPING
;

CREATE TABLE ENCOUNTER_MAPPING ( 
    ENCOUNTER_IDE       	VARCHAR(200)  NOT NULL,
    ENCOUNTER_IDE_SOURCE	VARCHAR(50)  NOT NULL,
    PROJECT_ID              VARCHAR(50) NOT NULL,
    ENCOUNTER_NUM			INT IDENTITY (1,1)  NOT NULL,
    PATIENT_IDE         	VARCHAR(200) NOT NULL,
    PATIENT_IDE_SOURCE  	VARCHAR(50) NOT NULL,
    ENCOUNTER_IDE_STATUS	VARCHAR(50) NULL,
    UPLOAD_DATE         	DATETIME NULL,
    UPDATE_DATE             DATETIME NULL,
    DOWNLOAD_DATE       	DATETIME NULL,
    IMPORT_DATE             DATETIME NULL,
    SOURCESYSTEM_CD         VARCHAR(50) NULL,
    UPLOAD_ID               INT NULL,
    CONSTRAINT ENCOUNTER_MAPPING_PK PRIMARY KEY(ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE, PROJECT_ID, PATIENT_IDE, PATIENT_IDE_SOURCE)
 )
;
CREATE  INDEX EM_IDX_ENCPATH ON ENCOUNTER_MAPPING(ENCOUNTER_IDE, ENCOUNTER_IDE_SOURCE, PATIENT_IDE, PATIENT_IDE_SOURCE, ENCOUNTER_NUM)
;
CREATE  INDEX EM_IDX_UPLOADID ON ENCOUNTER_MAPPING(UPLOAD_ID)
;
CREATE INDEX EM_ENCNUM_IDX ON ENCOUNTER_MAPPING(ENCOUNTER_NUM)
;


-------------------------------------------------------------------------------------
-- create PATIENT_MAPPING table with clustered PK on PATIENT_IDE, PATIENT_IDE_SOURCE
-------------------------------------------------------------------------------------
DROP TABLE PATIENT_MAPPING;

CREATE TABLE PATIENT_MAPPING ( 
    PATIENT_IDE         VARCHAR(200)  NOT NULL,
    PATIENT_IDE_SOURCE	VARCHAR(50)  NOT NULL,
    PATIENT_NUM       	INT IDENTITY (1,1) NOT NULL,
    PATIENT_IDE_STATUS	VARCHAR(50) NULL,
    PROJECT_ID          VARCHAR(50) NOT NULL,
    UPLOAD_DATE       	DATETIME NULL,
    UPDATE_DATE       	DATETIME NULL,
    DOWNLOAD_DATE     	DATETIME NULL,
    IMPORT_DATE         DATETIME NULL,
    SOURCESYSTEM_CD   	VARCHAR(50) NULL,
    UPLOAD_ID         	INT NULL,
    CONSTRAINT PATIENT_MAPPING_PK PRIMARY KEY(PATIENT_IDE, PATIENT_IDE_SOURCE, PROJECT_ID)
 )
;
CREATE  INDEX PM_IDX_UPLOADID ON PATIENT_MAPPING(UPLOAD_ID)
;
CREATE INDEX PM_PATNUM_IDX ON PATIENT_MAPPING(PATIENT_NUM)
;
CREATE INDEX PM_ENCPNUM_IDX ON 
PATIENT_MAPPING(PATIENT_IDE,PATIENT_IDE_SOURCE,PATIENT_NUM) ;

insert into patient_mapping (patient_ide, patient_ide_source, patient_ide_status, project_id, upload_date, update_date, download_date, import_date, sourcesystem_cd)
select distinct id, 'SYNTHEA', 'A', '@', GETDATE() ,GETDATE() ,GETDATE() ,GETDATE() , 'SYNTHEA'
from synthea.patients

insert into encounter_mapping (encounter_ide, encounter_ide_source, encounter_ide_status, patient_ide, patient_ide_source, project_id, upload_date, update_date, download_date, import_date, sourcesystem_cd)
select distinct id, 'SYNTHEA', 'A', patient, 'SYNTHEA', '@', GETDATE() ,GETDATE() ,GETDATE() ,GETDATE() , 'SYNTHEA'
from synthea.encounters

truncate table patient_dimension;

 insert into patient_dimension (patient_num, vitAL_Status_cd, birth_date,death_date, sex_cd, age_in_years_num, race_cd, MARITAL_STATUS_CD,
zip_cd, statecityzip_path,  update_date, download_date, import_date, sourcesystem_cd)
select distinct a.patient_num, case when b.deathdate = '1899-12-30' OR b.deathdate is null then 'A' else 'D' end, b.birthdate,
case when b.deathdate = '1899-12-30' OR b.deathdate is null then null else b.deathdate end, b.gender,
DATEDIFF(hour,b.birthdate,
case when b.deathdate = '1899-12-30' OR b.deathdate is null then getdate() else b.deathdate end

)/8766, b.race, b.marital, b.zip, b.state +' / ' + b.city + ' / ' + b.zip,
GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'
from patient_mapping a, synthea.patients b
where a.patient_ide = b.id

truncate table visit_dimension

insert into visit_dimension (encounter_num, patient_num, active_status_cd, start_date, end_date, inout_cd, location_cd, length_of_stay,  location_path, update_date, download_date, import_date, sourcesystem_cd)
select distinct  a.encounter_num, b.patient_num, 'A', c.start, c.stop,
case 
when c.encounterclass = 'ambulatory' then 'A'
when c.encounterclass = 'emergency' then 'E'
when c.encounterclass = 'inpatient' then 'I'
when c.encounterclass = 'outpatient' then 'O'
when c.encounterclass = 'urgentcare' then 'U'
when c.encounterclass = 'wellness' then 'W'
else c.encounterclass 
end
,
 d.utilization,
 DATEDIFF(hour,c.start,c.stop)/8766 ,
 d.name +' / ' + d.address + ' / '+ d.state + ' / ' + d.zip,
GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'
from encounter_mapping a, patient_mapping b, synthea.encounters c, synthea.organizations d
where a.encounter_ide = c.id
and a.patient_ide = b.patient_ide
and c.organization = d.id

insert into provider_dimension (provider_id, provider_path, name_char,  update_date, download_date, import_date, sourcesystem_cd)
SELECT distinct a.Id
      , b.name +' / ' + b.address + ' / '+ b.state + ' / ' + b.zip
	  , a.name, GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'
  FROM  Synthea.providers a,
  synthea.organizations b
  where a.organization = b.id
  
  truncate table observation_fact

  


  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  -1, patient_num, 'DEM|SEX:' + sex_cd, '@', BIRTH_DATE, '@', 
1
,
'T' as valtype_cd,
 sex_cd  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
null,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'
 from PATIENT_DIMENSION
 where birth_date is not null


 

  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct -1, patient_num, 

case when RACE_CD = 'native' then 'DEM|RACE:NA' 
 when race_cd = 'other' then 'DEM|RACE:NI'
 when race_cd = 'white' then 'DEM|RACE:W'
 when race_cd = 'black' then 'DEM|RACE:B' 
 when race_cd = 'asian' then 'DEM|RACE:AS' else race_cd end ,
  '@', BIRTH_DATE, '@', 
1
,
'T' as valtype_cd,
 race_cd  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
null,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'
 from PATIENT_DIMENSION
 where BIRTH_DATE is not null


 

  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select  distinct -1, patient_num, 
'DEM|VITAL STATUS:D',
  '@', death_DATE, '@', 
1
,
'T' as valtype_cd,
 race_cd  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
null,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'
 from PATIENT_DIMENSION
where DEATH_DATE is not null
and BIRTH_DATE is not null

  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
 --     ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 'LOINC:' + c.code, '@', c.date, '@', 
row_number() over (partition by  a.encounter_num, '@',  c.code, '@', c.date
order by  a.encounter_num, b.patient_num,  c.code,   c.date
)
,
case when c.type = 'numeric' then 'N' else 'T' end as valtype_cd,
case when c.type = 'text' then c.value else 'E' end as tval_char,
case when c.type = 'numeric' then c.value else null end as nval_num,
case when c.type = 'numeric' then '@' else null end as valueflag_cd,
c.units,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'

from encounter_mapping a, patient_mapping b, Synthea.observations c, synthea.encounters d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id

  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 'RXNORM:' + c.code, '@', c.start, '@', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code, '@', c.start
order by  a.encounter_num, b.patient_num,  c.code,   c.start
)
,
'N' as valtype_cd,
 'E'  as tval_char,
c.DISPENSES as nval_num,
 '@'   as valueflag_cd,
null,
c.stop,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'

from encounter_mapping a, patient_mapping b, Synthea.medications c, synthea.encounters d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id




  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select  distinct a.encounter_num, b.patient_num, 'ICD10CM:' + e.maptarget, '@', c.start, '@', 
row_number() over (partition by  a.encounter_num, b.patient_num,  e.maptarget,  c.start
order by  a.encounter_num, b.patient_num,  e.maptarget,   c.start
)
,
'T' as valtype_cd,
 null  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
c.stop,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'

from encounter_mapping a, patient_mapping b, Synthea.conditions c, synthea.encounters d, SNOMED_to_ICD10 e
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id
and e.referencedComponentId = c.code
and e.maptarget is not null


-- Care Plan 31 of 89 mapped
  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 'ICD10CM:' + e.maptarget, '@', c.start, '@', 
row_number() over (partition by  a.encounter_num, b.patient_num,  e.maptarget,  c.start
order by  a.encounter_num, b.patient_num,  e.maptarget,   c.start
)
,
'T' as valtype_cd,
 null  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
c.stop,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'

from encounter_mapping a, patient_mapping b, Synthea.careplans c, synthea.encounters d, SNOMED_to_ICD10 e
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id
and e.referencedComponentId = c.REASONCODE
and e.maptarget is not null


-- immunization
  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 

case when c.code = 140 then 'UMLS:C0744062' 
-- when c.code = 72506001	then 'UMLS:C0015357'

else 'SNOMED:' + cast(c.code as varchar) end as concept_cd,
 '@', c.date, '@', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code, '@', c.date
order by  a.encounter_num, b.patient_num,  c.code,  c.date
)
,
'T' as valtype_cd,
 null  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
null,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'

from encounter_mapping a, patient_mapping b, Synthea.immunizations c, synthea.encounters d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id


--TODO devices (6), procedures (177)



  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 

case when c.code = 449071006 then 'UMLS:C0199470' 
 when c.code = 72506001	then 'UMLS:C0015357'
 when c.code = 705643001	then 'UMLS:C0021925'
 when c.code =706004007	then 'UMLS:C4534306'
 when c.code = 36965003	then 'DRG:475'
else 'SNOMED:' + cast(c.code as varchar) end as concept_cd,
 '@', c.start, '@', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code,  c.start
order by  a.encounter_num, b.patient_num,  c.code, c.start
)
,
'T' as valtype_cd,
 null  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
c.stop,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'

from encounter_mapping a, patient_mapping b, Synthea.devices c, synthea.encounters d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id



  insert into observation_fact (ENCOUNTER_NUM
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
     -- ,QUANTITY_NUM
      ,UNITS_CD
      ,END_DATE
  --    ,LOCATION_CD
   --   ,OBSERVATION_BLOB
      ,CONFIDENCE_NUM
      ,UPDATE_DATE
      ,DOWNLOAD_DATE
      ,IMPORT_DATE
      ,SOURCESYSTEM_CD)
select distinct  a.encounter_num, b.patient_num, 'SNOMED:' + cast(c.code as varchar), '@', c.date, '@', 
row_number() over (partition by  a.encounter_num, b.patient_num,  c.code,  c.date
order by  a.encounter_num, b.patient_num,  c.code,  c.date
)
,
'T' as valtype_cd,
 null  as tval_char,
null as nval_num,
 '@'   as valueflag_cd,
null,
null,
'1',
 GETDATE() ,GETDATE() ,GETDATE(), 'SYNTHEA'

from encounter_mapping a, patient_mapping b, Synthea.procedures c, synthea.encounters d
where a.encounter_ide = c.encounter 
and b.patient_ide = c.patient
and c.encounter = d.id


-- New code to update concept_dim
-- select c_dimcode AS modifier_path, c_basecode AS modifier_cd, c_name AS name_char, c_comment AS modifier_blob, update_date, download_date, import_date, sourcesystem_cd, 1 upload_id into modifier_dimension from PCORNET where m_applied_path!='@' and c_tablename='MODIFIER_DIMENSION' and c_columnname='modifier_path' and (c_columndatatype='T' or c_columndatatype='N') and c_synonym_cd = N and m_exclusion_cd is null and and c_basecode is not null;
DECLARE @sqltext NVARCHAR(4000);
declare getsql cursor local for
select 'insert into concept_dimension select c_dimcode AS concept_path, c_basecode AS concept_cd, c_name AS name_char, null AS concept_blob, update_date AS update_date, download_date as download_date, import_date as import_date, sourcesystem_cd as sourcesystem_cd, 1 as upload_id from '
+c_table_name+' where m_applied_path=''@'' and c_tablename=''CONCEPT_DIMENSION'' and c_columnname=''concept_path'' and c_visualattributes not like ''%I%'' and (c_columndatatype=''T'' or c_columndatatype=''N'') and c_synonym_cd = ''N'' and (m_exclusion_cd is null or m_exclusion_cd='''') and c_basecode is not null and c_basecode!='''''
from i2b2metadata.dbo.TABLE_ACCESS where c_visualattributes like '%A%'

begin
delete from concept_dimension;
OPEN getsql;
FETCH NEXT FROM getsql INTO @sqltext;
WHILE @@FETCH_STATUS = 0
BEGIN
	print @sqltext
	exec sp_executesql @sqltext
	FETCH NEXT FROM getsql INTO @sqltext;	
END

CLOSE getsql;
DEALLOCATE getsql;
end
