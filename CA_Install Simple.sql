/********************************************************************************************************************

    CALENDAR Management is a set of tables and views.
    
    The main goal is to know for each day, what is the type of the day and what week day is it.
    In a normal case, we can ask Oracle about it, but in the real life the Holidays and Workdays sometimes swap.
    The user has to enter these swaps, changes only and the Calendar Manager will show the reality.

    The inserted data is an example and shows only the business logic. You can delete them.

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.05 |  1.0    | Ferenc Toth    | Created 

********************************************************************************************************************/


Prompt *************************************
Prompt   CA_DAY_TYPES
Prompt *************************************
/*-------------------------------------------
    CA_DAY_TYPES 
    You can add/mod any day type.
    The pattern will contain the default 
    day types of the week days.
-------------------------------------------*/
CREATE TABLE CA_DAY_TYPES (
    CODE                            VARCHAR2 (   50 )	CONSTRAINT CA_DAY_TYPES_NN1 NOT NULL,
    NAME                            VARCHAR2 (  200 )   CONSTRAINT CA_DAY_TYPES_NN2 NOT NULL
  );
ALTER TABLE CA_DAY_TYPES ADD CONSTRAINT CA_DAY_TYPES_PK  PRIMARY KEY ( CODE );

INSERT INTO CA_DAY_TYPES ( CODE, NAME ) VALUES ( 'W',  'Workday'  );   -- Mandatory and do not change the CODE!
INSERT INTO CA_DAY_TYPES ( CODE, NAME ) VALUES ( 'E',  'Weekend'  );   -- Mandatory and do not change the CODE!
INSERT INTO CA_DAY_TYPES ( CODE, NAME ) VALUES ( 'H',  'Holiday'  );   -- ... or any other whatever you want 
INSERT INTO CA_DAY_TYPES ( CODE, NAME ) VALUES ( 'V',  'Vacation' );
COMMIT;


Prompt *************************************
Prompt   CA_WEEK_DAYS
Prompt *************************************
/*-------------------------------------------
    CA_WEEK_DAYS 
    Specifies the default pattern of the week
    by Calendar Types
-------------------------------------------*/
CREATE TABLE CA_WEEK_DAYS (
    CODE                            VARCHAR2 (   50 )   CONSTRAINT CA_WEEK_DAYS_NN1 NOT NULL,
    SEQ                             NUMBER   (    2 )   CONSTRAINT CA_WEEK_DAYS_NN2 NOT NULL,   
    NAME                            VARCHAR2 (  200 )   CONSTRAINT CA_WEEK_DAYS_NN3 NOT NULL,
    DAY_TYPE_CODE                   VARCHAR2 (   50 )   CONSTRAINT CA_WEEK_DAYS_NN4 NOT NULL
  );
ALTER TABLE CA_WEEK_DAYS ADD CONSTRAINT CA_WEEK_DAYS_PK  PRIMARY KEY ( CODE );
ALTER TABLE CA_WEEK_DAYS ADD CONSTRAINT CA_WEEK_DAYS_FK1 FOREIGN KEY ( DAY_TYPE_CODE      ) REFERENCES CA_DAY_TYPES      ( CODE );

-- the CODE must be 
-- select to_char( sysdate + n, 'DY', 'nls_date_language=american' ) from dual;
-- format. Where n is 1..7 to get:
INSERT INTO CA_WEEK_DAYS ( SEQ, CODE, NAME, DAY_TYPE_CODE ) VALUES ( 1, 'MON',  'Monday'    , 'W' );
INSERT INTO CA_WEEK_DAYS ( SEQ, CODE, NAME, DAY_TYPE_CODE ) VALUES ( 2, 'TUE',  'Tuesday'   , 'W' );
INSERT INTO CA_WEEK_DAYS ( SEQ, CODE, NAME, DAY_TYPE_CODE ) VALUES ( 3, 'WED',  'Wednesday' , 'W' );
INSERT INTO CA_WEEK_DAYS ( SEQ, CODE, NAME, DAY_TYPE_CODE ) VALUES ( 4, 'THU',  'Thursday'  , 'W' );
INSERT INTO CA_WEEK_DAYS ( SEQ, CODE, NAME, DAY_TYPE_CODE ) VALUES ( 5, 'FRI',  'Friday'    , 'W' );
INSERT INTO CA_WEEK_DAYS ( SEQ, CODE, NAME, DAY_TYPE_CODE ) VALUES ( 6, 'SAT',  'Saturday'  , 'E' );
INSERT INTO CA_WEEK_DAYS ( SEQ, CODE, NAME, DAY_TYPE_CODE ) VALUES ( 7, 'SUN',  'Sunday'    , 'E' );
COMMIT;



Prompt *************************************
Prompt   CA_CALENDAR_DAY_CHANGES
Prompt ************************************* 
/*-------------------------------------------
    CA_CALENDAR_DAY_CHANGES 
    Contains the day specifications (by Calendars) what
    differ from the default pattern (CA_WEEK_DAYS).
-------------------------------------------*/
CREATE TABLE CA_CALENDAR_DAY_CHANGES (
    CALENDAR_DAY                    DATE                CONSTRAINT CA_CALENDAR_DAY_CHANGES_NN1 NOT NULL,
    DAY_TYPE_CODE                   VARCHAR2 ( 50 )     CONSTRAINT CA_CALENDAR_DAY_CHANGES_NN2 NOT NULL,
    WEEK_DAY_CODE                   VARCHAR2 ( 50 )     CONSTRAINT CA_CALENDAR_DAY_CHANGES_NN3 NOT NULL
  );

ALTER TABLE CA_CALENDAR_DAY_CHANGES ADD CONSTRAINT CA_CALENDAR_DAY_CHANGES_PK  PRIMARY KEY ( CALENDAR_DAY );
ALTER TABLE CA_CALENDAR_DAY_CHANGES ADD CONSTRAINT CA_CALENDAR_DAY_CHANGES_FK1 FOREIGN KEY ( DAY_TYPE_CODE ) REFERENCES CA_DAY_TYPES ( CODE );




Prompt *************************************
Prompt   CA_CALENDAR_DAYS
Prompt ************************************* 
/*-------------------------------------------
    CA_CALENDAR_DAYS 
    Contains +/- 2000 days from now.
-------------------------------------------*/
CREATE OR REPLACE VIEW CA_CALENDAR_DAYS AS
SELECT  /*+ RESULT_CACHE */ TRUNC( SYSDATE + OFFSET ) AS CALENDAR_DAY  
  FROM ( SELECT ROWNUM - 2000 AS OFFSET FROM DUAL CONNECT BY LEVEL <= 4000 );



Prompt *************************************
Prompt   CA VIEWS
Prompt *************************************
/*-------------------------------------------
    CA_CALENDAR_ORIG_VW
    Shows the default, original patterns
-------------------------------------------*/
CREATE OR REPLACE VIEW CA_CALENDAR_ORIG_VW AS
SELECT CA_CALENDAR_DAYS.CALENDAR_DAY    AS CALENDAR_DAY 
     , CA_WEEK_DAYS.DAY_TYPE_CODE       AS DAY_TYPE_CODE
     , CA_WEEK_DAYS.CODE                AS WEEK_DAY_CODE
     , CA_WEEK_DAYS.NAME                AS WEEK_DAY_NAME
  FROM CA_CALENDAR_DAYS
     , CA_WEEK_DAYS
 WHERE CA_WEEK_DAYS.CODE = TRIM( TO_CHAR( CA_CALENDAR_DAYS.CALENDAR_DAY , 'DY', 'NLS_DATE_LANGUAGE=AMERICAN' ) )
;


/*-------------------------------------------
    CA_CALENDAR_REAL_VW
    Shows the real, modified patterns
-------------------------------------------*/
CREATE OR REPLACE VIEW CA_CALENDAR_REAL_VW AS
SELECT CA_CALENDAR_ORIG_VW.CALENDAR_DAY        AS CALENDAR_DAY 
     , NVL( CA_CALENDAR_DAY_CHANGES.DAY_TYPE_CODE, CA_CALENDAR_ORIG_VW.DAY_TYPE_CODE ) AS DAY_TYPE_CODE
     , NVL( CA_CALENDAR_DAY_CHANGES.WEEK_DAY_CODE, CA_CALENDAR_ORIG_VW.WEEK_DAY_CODE ) AS WEEK_DAY_CODE
  FROM CA_CALENDAR_ORIG_VW
     , CA_CALENDAR_DAY_CHANGES
 WHERE CA_CALENDAR_ORIG_VW.CALENDAR_DAY = CA_CALENDAR_DAY_CHANGES.CALENDAR_DAY (+)
;


/*-------------------------------------------
    CA_CALENDAR_ORIG_AND_REAL_VW
    Shows both original and the real
    patterns together
-------------------------------------------*/
CREATE OR REPLACE VIEW CA_CALENDAR_ORIG_AND_REAL_VW AS
SELECT CA_CALENDAR_ORIG_VW.CALENDAR_DAY        AS CALENDAR_DAY 
     , CA_CALENDAR_ORIG_VW.DAY_TYPE_CODE       AS ORIG_DAY_TYPE_CODE
     , CA_CALENDAR_ORIG_VW.WEEK_DAY_CODE       AS ORIG_WEEK_DAY_CODE
     , CA_CALENDAR_REAL_VW.DAY_TYPE_CODE       AS REAL_DAY_TYPE_CODE
     , CA_CALENDAR_REAL_VW.WEEK_DAY_CODE       AS REAL_WEEK_DAY_CODE
  FROM CA_CALENDAR_ORIG_VW
     , CA_CALENDAR_REAL_VW
 WHERE CA_CALENDAR_ORIG_VW.CALENDAR_DAY   = CA_CALENDAR_REAL_VW.CALENDAR_DAY 
;


/*-------------------------------------------
    CA_CALENDAR_CHANGES_VW
    Shows only the differences
-------------------------------------------*/
CREATE OR REPLACE VIEW CA_CALENDAR_CHANGES_VW AS
SELECT CALENDAR_DAY 
     , ORIG_DAY_TYPE_CODE
     , ORIG_WEEK_DAY_CODE
     , REAL_DAY_TYPE_CODE
     , REAL_WEEK_DAY_CODE
  FROM CA_CALENDAR_ORIG_AND_REAL_VW
 WHERE ORIG_DAY_TYPE_CODE != REAL_DAY_TYPE_CODE
    OR ORIG_WEEK_DAY_CODE != REAL_WEEK_DAY_CODE
;





