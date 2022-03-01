CREATE OR REPLACE NONEDITIONABLE PROCEDURE create_synthea_table_oracle IS
    cnt NUMBER;
BEGIN 
 -- drop synthea tables if they exist
     dbms_output.put_line('dropping synthea tables if they exist');
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_ORGANIZATIONS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_ORGANIZATIONS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_ALLERGIES';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_ALLERGIES';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_PATIENTS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_PATIENTS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_DEVICES';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_DEVICES';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_PROVIDERS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_PROVIDERS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_MEDICATIONS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_MEDICATIONS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_PROCEDURES';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_PROCEDURES';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_CONDITIONS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_CONDITIONS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_CAREPLANS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_CAREPLANS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_IMMUNIZATIONS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_IMMUNIZATIONS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_MEDICATIONS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_MEDICATIONS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_ENCOUNTERS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_ENCOUNTERS';
    END IF;
    COMMIT;
    SELECT
        COUNT(*)
    INTO cnt
    FROM
        user_tables
    WHERE
        table_name = 'SYNTHEA_OBSERVATIONS';

    IF cnt <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SYNTHEA_OBSERVATIONS';
    END IF;
    COMMIT;        
 
 -- create synthea tables
    dbms_output.put_line('creating table SYNTHEA_DEVICES');
    EXECUTE IMMEDIATE 'create table SYNTHEA_DEVICES  (
  START_DEV DATE NOT NULL,
	STOP DATE NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ENCOUNTER nvarchar2(50) NOT NULL,
	CODE int NOT NULL,
	DESCRIPTION nvarchar2(100) NOT NULL,
	UDI nvarchar2(100) NOT NULL

)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_ORGANIZATIONS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_ORGANIZATIONS  (
Id nvarchar2(50) NOT NULL,
	NAME nvarchar2(100) NOT NULL,
	ADDRESS nvarchar2(50) NOT NULL,
	CITY nvarchar2(50) NOT NULL,
	STATE nvarchar2(50) NOT NULL,
	ZIP nvarchar2(50) NOT NULL,
	LAT float NOT NULL,
	LON float NOT NULL,
	PHONE nvarchar2(50) NULL,
	REVENUE float NOT NULL,
	UTILIZATION int NOT NULL

)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_PATIENTS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_PATIENTS  (
	id varchar2(1000) NULL,
	birthdate date NULL,
	deathdate date NULL,
	ssn varchar2(100) NULL,
	drivers varchar2(100) NULL,
	passport varchar2(100) NULL,
	prefix varchar2(100) NULL,
	first varchar2(100) NULL,
	last varchar2(100) NULL,
	suffix varchar2(100) NULL,
	maiden varchar2(100) NULL,
	marital varchar2(100) NULL,
	race varchar2(100) NULL,
	ethnicity varchar2(100) NULL,
	gender varchar2(100) NULL,
	birthplace varchar2(100) NULL,
	address varchar2(100) NULL,
	city varchar2(100) NULL,
	state varchar2(100) NULL,
	zip varchar2(100) NULL

)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_PROVIDERS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_PROVIDERS  (

	Id nvarchar2(50) NOT NULL,
	ORGANIZATION nvarchar2(50) NOT NULL,
	NAME nvarchar2(50) NOT NULL,
	GENDER nvarchar2(50) NOT NULL,
	SPECIALITY nvarchar2(50) NOT NULL,
	ADDRESS nvarchar2(50) NOT NULL,
	CITY nvarchar2(50) NOT NULL,
	STATE nvarchar2(50) NOT NULL,
	ZIP nvarchar2(50) NOT NULL,
	LAT float NOT NULL,
	LON float NOT NULL,
	UTILIZATION int NOT NULL

)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_MEDICATIONS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_MEDICATIONS  (
	START_MED DATE NOT NULL,
	STOP DATE NULL,
	PATIENT nvarchar2(50) NOT NULL,
	PAYER nvarchar2(50) NULL,
	ENCOUNTER nvarchar2(50) NOT NULL,
	CODE nvarchar2(50) NOT NULL,
	DESCRIPTION nvarchar2(200) NOT NULL,
	BASE_COST float NULL,
	PAYER_COVERAGE float NULL,
	DISPENSES int NULL,
	TOTALCOST float NULL,
	REASONCODE nvarchar2(50) NULL,
	REASONDESCRIPTION nvarchar2(200) NULL

)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_CONDITIONS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_CONDITIONS  (
	START_CON DATE NOT NULL,
	STOP DATE NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ENCOUNTER nvarchar2(50) NOT NULL,
	CODE float NOT NULL,
	DESCRIPTION nvarchar2(100) NOT NULL

)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_PROCEDURES ');
    EXECUTE IMMEDIATE 'create table SYNTHEA_PROCEDURES  (
    DATE_PROC DATE NOT NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ENCOUNTER nvarchar2(50) NOT NULL,
	CODE nvarchar2(50) NOT NULL,
	DESCRIPTION nvarchar2(150) NOT NULL,
	BASE_COST float NULL,
	REASONCODE nvarchar2(100) NULL,
	REASONDESCRIPTION nvarchar2(150) NULL

)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_CAREPLANS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_CAREPLANS  (
    Id nvarchar2(50) NOT NULL,
	START_CP DATE NOT NULL,
	STOP DATE NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ENCOUNTER nvarchar2(50) NOT NULL,
	CODE float NOT NULL,
	DESCRIPTION nvarchar2(100) NOT NULL,
	REASONCODE float NULL,
	REASONDESCRIPTION nvarchar2(100) NULL
)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_IMMUNIZATIONS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_IMMUNIZATIONS  (
    DATE_IM DATE NOT NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ENCOUNTER nvarchar2(50) NOT NULL,
	CODE int NOT NULL,
	DESCRIPTION nvarchar2(100) NOT NULL,
	BASE_COST float NULL
)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_ENCOUNTERS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_ENCOUNTERS  (
    Id nvarchar2(50) NOT NULL,
	START_ENC  DATE NOT NULL,
	STOP DATE  NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ORGANIZATION nvarchar2(50) NULL,
	PROVIDER nvarchar2(50) NULL,
	PAYER nvarchar2(50) NULL,
	ENCOUNTERCLASS nvarchar2(50) NULL,
	CODE int NULL,
	DESCRIPTION nvarchar2(100) NULL,
	BASE_ENCOUNTER_COST float NULL,
	TOTAL_CLAIM_COST float NULL,
	PAYER_COVERAGE float NULL,
	REASONCODE float NULL,
	REASONDESCRIPTION nvarchar2(100) NULL
)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_OBSERVATIONS');
    EXECUTE IMMEDIATE 'create table SYNTHEA_OBSERVATIONS  (
	DATE_OB DATE NOT NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ENCOUNTER nvarchar2(50) NULL,
	CODE nvarchar2(50) NOT NULL,
	DESCRIPTION nvarchar2(200) NOT NULL,
	VALUE nvarchar2(100) NULL,
	UNITS nvarchar2(50) NULL,
	TYPE nvarchar2(50) NULL
)';
    COMMIT;
    dbms_output.put_line('creating table SYNTHEA_ALLERGIES');
    EXECUTE IMMEDIATE 'create table SYNTHEA_ALLERGIES  (
START_AL DATE NOT NULL,
	STOP DATE NULL,
	PATIENT nvarchar2(50) NOT NULL,
	ENCOUNTER nvarchar2(50) NOT NULL,
	CODE  int NOT NULL,
	DESCRIPTION nvarchar2(50) NOT NULL
)';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(sqlerrm);
END;