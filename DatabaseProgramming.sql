set pagesize 60
set serveroutput on
REM Download this .txt file to your local drive, change the "path" accordingly, then run @" ..."
REM @"path_where_this_file_located_in_your_drive\Oracle_employees_script.txt"
REM you need to physical find out the local path and replace the above "path". 
REM Please read the file "How to create the sample tables" if you have questions.

REM Create the REGIONS table to hold region information for locations
REM HR.LOCATIONS table has a foreign key to this table.

DROP TABLE regions     CASCADE Constraints;
DROP TABLE locations   CASCADE Constraints;
DROP TABLE countries   CASCADE Constraints;
DROP TABLE departments CASCADE Constraints;
DROP TABLE employees   CASCADE Constraints;
DROP TABLE jobs        CASCADE Constraints;
DROP TABLE job_history CASCADE Constraints;
  
CREATE TABLE regions
   ( region_id    NUMBER  CONSTRAINT region_id_nn NOT NULL 
   , region_name  VARCHAR2(25)  );

CREATE UNIQUE INDEX reg_id_pk ON regions (region_id);
ALTER TABLE regions 
         ADD ( CONSTRAINT reg_id_pk    PRIMARY KEY (region_id)  ) ;
REM ********************************************************************
REM Create the COUNTRIES table to hold country information for customers
REM and company locations. 
REM OE.CUSTOMERS table and HR.LOCATIONS have a foreign key to this table.
       
CREATE TABLE countries 
   ( country_id    CHAR(2)   CONSTRAINT country_id_nn NOT NULL 
   , country_name  VARCHAR2(40) 
   , region_id     NUMBER 
   , CONSTRAINT    country_c_id_pk PRIMARY KEY (country_id) 
    )   ORGANIZATION INDEX; 

ALTER TABLE countries
     ADD ( CONSTRAINT countr_reg_fk FOREIGN KEY (region_id) REFERENCES regions(region_id) 
   ) ;
REM ********************************************************************
REM Create the LOCATIONS table to hold address information for company departments.
REM HR.DEPARTMENTS has a foreign key to this table.
       
CREATE TABLE locations
   ( location_id    NUMBER(4)
   , street_address VARCHAR2(40)
   , postal_code    VARCHAR2(12)
   , city           VARCHAR2(30)  CONSTRAINT loc_city_nn NOT NULL
   , state_province VARCHAR2(25)
   , country_id     CHAR(2)
   ) ;

CREATE UNIQUE INDEX loc_id_pk
         ON locations (location_id) ;
ALTER TABLE locations
         ADD ( CONSTRAINT loc_id_pk PRIMARY KEY (location_id)
   , CONSTRAINT loc_c_id_fk FOREIGN KEY (country_id) REFERENCES countries(country_id) 
   ) ;
Rem Useful for any subsequent addition of rows to locations table
Rem Starts with 3300
DROP   SEQUENCE locations_seq;
CREATE SEQUENCE locations_seq  START WITH 3300  INCREMENT BY 100
   MAXVALUE 9900   NOCACHE    NOCYCLE;
REM ********************************************************************
REM Create the DEPARTMENTS table to hold company department information.
REM HR.EMPLOYEES and HR.JOB_HISTORY have a foreign key to this table.
       
CREATE TABLE departments
   ( department_id   NUMBER(4)
   , department_name VARCHAR2(30)  CONSTRAINT dept_name_nn NOT NULL
   , manager_id      NUMBER(6)
   , location_id     NUMBER(4)
   ) ;
CREATE UNIQUE INDEX dept_id_pk
         ON departments (department_id) ;
ALTER TABLE departments
  ADD ( CONSTRAINT dept_id_pk  PRIMARY KEY (department_id)
   , CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) REFERENCES locations (location_id)
   ) ;
Rem Useful for any subsequent addition of rows to departments table
Rem Starts with 280 
DROP   SEQUENCE departments_seq;
CREATE SEQUENCE departments_seq START WITH 280
   INCREMENT BY 10  MAXVALUE 9990    NOCACHE    NOCYCLE;
REM ********************************************************************
REM Create the JOBS table to hold the different names of job roles within the company.
REM HR.EMPLOYEES has a foreign key to this table.
       
CREATE TABLE jobs
   ( job_id      VARCHAR2(10)
   , job_title   VARCHAR2(35)    CONSTRAINT job_title_nn NOT NULL
   , min_salary  NUMBER(6)
   , max_salary  NUMBER(6)
   ) ;
CREATE UNIQUE INDEX job_id_pk           ON jobs (job_id) ;
ALTER TABLE jobs 
         ADD ( CONSTRAINT job_id_pk PRIMARY KEY(job_id)
   ) ;
REM ********************************************************************
REM Create the EMPLOYEES table to hold the employee personnel 
REM information for the company.
REM HR.EMPLOYEES has a self referencing foreign key to this table.
       
CREATE TABLE employees
   ( employee_id    NUMBER(6)
   , first_name     VARCHAR2(20)
   , last_name      VARCHAR2(25)  CONSTRAINT emp_last_name_nn NOT NULL
   , email          VARCHAR2(25)  CONSTRAINT emp_email_nn NOT NULL
   , phone_number   VARCHAR2(20)
   , hire_date      DATE          CONSTRAINT emp_hire_date_nn NOT NULL
   , job_id         VARCHAR2(10)  CONSTRAINT emp_job_nn NOT NULL
   , salary         NUMBER(8,2)
   , commission_pct NUMBER(2,2)
   , manager_id     NUMBER(6)
   , department_id  NUMBER(4)
   , CONSTRAINT     emp_salary_min  CHECK (salary > 0) 
   , CONSTRAINT     emp_email_uk    UNIQUE (email)
   ) ;
CREATE UNIQUE INDEX emp_emp_id_pk
         ON employees (employee_id) ;
       
ALTER TABLE employees
         ADD ( CONSTRAINT emp_emp_id_pk    PRIMARY KEY (employee_id)
   , CONSTRAINT emp_dept_fk   FOREIGN KEY (department_id)  REFERENCES departments
   , CONSTRAINT emp_job_fk      FOREIGN KEY (job_id)       REFERENCES jobs (job_id)
   , CONSTRAINT emp_manager_fk  FOREIGN KEY (manager_id)   REFERENCES employees
   ) ;
ALTER TABLE departments
    ADD ( CONSTRAINT dept_mgr_fk FOREIGN KEY (manager_id) REFERENCES employees (employee_id)
   ) ;
       
Rem Useful for any subsequent addition of rows to employees table
REM Starts with 207 
DROP    SEQUENCE employees_seq;
CREATE SEQUENCE employees_seq  START WITH 207
   INCREMENT BY 1    NOCACHE    NOCYCLE;
REM ********************************************************************
REM Create the JOB_HISTORY table to hold the history of jobs that 
REM employees have held in the past.
REM HR.JOBS, HR_DEPARTMENTS, and HR.EMPLOYEES have a foreign key to this table.
       
CREATE TABLE job_history
   ( employee_id    NUMBER(6)    CONSTRAINT jhist_employee_nn NOT NULL
   , start_date     DATE         CONSTRAINT jhist_start_date_nn NOT NULL
   , end_date       DATE         CONSTRAINT jhist_end_date_nn NOT NULL
   , job_id         VARCHAR2(10) CONSTRAINT jhist_job_nn NOT NULL
   , department_id  NUMBER(4)
   , CONSTRAINT     jhist_date_interval CHECK (end_date > start_date)
   ) ;
CREATE UNIQUE INDEX jhist_emp_id_st_date_pk 
         ON job_history (employee_id, start_date) ;
ALTER TABLE job_history
      ADD ( CONSTRAINT jhist_emp_id_st_date_pk  PRIMARY KEY (employee_id, start_date)
   , CONSTRAINT jhist_job_fk  FOREIGN KEY (job_id)        REFERENCES jobs
   , CONSTRAINT jhist_emp_fk  FOREIGN KEY (employee_id)   REFERENCES employees
   , CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments
   ) ;
REM ********************************************************************
REM Create the EMP_DETAILS_VIEW that joins the employees, jobs, 
REM departments, jobs, countries, and locations table to provide details
REM about employees.
       
CREATE OR REPLACE VIEW emp_details_view
   (employee_id, job_id, manager_id,  department_id, location_id, country_id, first_name, 
    last_name, salary, commission_pct, department_name, job_title, city, state_province, 
    country_name,region_name)
   AS SELECT 
   e.employee_id, e.job_id, e.manager_id, e.department_id, d.location_id, l.country_id, e.first_name,
   e.last_name,  e.salary, e.commission_pct, d.department_name, j.job_title, l.city, l.state_province,
   c.country_name, r.region_name
   FROM  employees e,  departments d, jobs j, locations l, countries c,    regions r
   WHERE e.department_id = d.department_id
     AND d.location_id = l.location_id
     AND l.country_id = c.country_id
     AND c.region_id = r.region_id
     AND j.job_id = e.job_id 
   WITH READ ONLY;
 
COMMIT;
ALTER SESSION SET NLS_LANGUAGE=American; 
REM ***************************insert data into the REGIONS table
INSERT INTO regions VALUES ( 1 , 'Europe'    );
INSERT INTO regions VALUES ( 2 , 'Americas'  );
INSERT INTO regions VALUES ( 3 , 'Asia'       );
INSERT INTO regions VALUES ( 4 , 'Middle East and Africa'   );

REM ***************************insert data into the COUNTRIES table
INSERT INTO countries VALUES  ( 'IT'   , 'Italy'   , 1    );
INSERT INTO countries VALUES  ( 'JP'   , 'Japan'   , 3    );
INSERT INTO countries VALUES  ( 'US'   , 'United States of America'   , 2   );
INSERT INTO countries VALUES  ( 'CA'   , 'Canada'  , 2    );
INSERT INTO countries VALUES  ( 'CN'   , 'China'   , 3    );
INSERT INTO countries VALUES  ( 'IN'   , 'India'   , 3    );
INSERT INTO countries VALUES  ( 'AU'   , 'Australia', 3     );
INSERT INTO countries VALUES  ( 'ZW'   , 'Zimbabwe', 4     );
INSERT INTO countries VALUES  ( 'SG'   , 'Singapore', 3     );
INSERT INTO countries VALUES  ( 'UK'   , 'United Kingdom', 1     );
INSERT INTO countries VALUES  ( 'FR'   , 'France', 1     );
INSERT INTO countries VALUES  ( 'DE'   , 'Germany', 1     );
INSERT INTO countries VALUES  ( 'ZM'   , 'Zambia', 4     );
INSERT INTO countries VALUES  ( 'EG'   , 'Egypt', 4     );
INSERT INTO countries VALUES  ( 'BR'   , 'Brazil', 2     );
INSERT INTO countries VALUES  ( 'CH'   , 'Switzerland', 1     );
INSERT INTO countries VALUES  ( 'NL'   , 'Netherlands', 1     );
INSERT INTO countries VALUES  ( 'MX'   , 'Mexico', 2     );
INSERT INTO countries VALUES  ( 'KW'   , 'Kuwait', 4     );
INSERT INTO countries VALUES  ( 'IL'   , 'Israel', 4     );
INSERT INTO countries VALUES  ( 'DK'   , 'Denmark', 1     );
INSERT INTO countries VALUES  ( 'HK'   , 'HongKong', 3     );
INSERT INTO countries VALUES  ( 'NG'   , 'Nigeria', 4     );
INSERT INTO countries VALUES  ( 'AR'   , 'Argentina', 2     );
INSERT INTO countries VALUES  ( 'BE'   , 'Belgium', 1     ); 
       
REM ***************************insert data into the LOCATIONS table       

INSERT INTO locations VALUES ( 1000, '1297 Via Cola di Rie', '00989', 'Roma', NULL, 'IT');
INSERT INTO locations VALUES ( 1100, '93091 Calle della Testa', '10934', 'Venice', NULL, 'IT');
INSERT INTO locations VALUES ( 1200, '2017 Shinjuku-ku', '1689', 'Tokyo', 'Tokyo Prefecture', 'JP');
INSERT INTO locations VALUES ( 1300, '9450 Kamiya-cho', '6823', 'Hiroshima', NULL, 'JP');
INSERT INTO locations VALUES ( 1400, '2014 Jabberwocky Rd', '26192', 'Southlake', 'Texas', 'US');
INSERT INTO locations VALUES ( 1500, '2011 Interiors Blvd', '99236', 'South San Francisco', 'California', 'US');
INSERT INTO locations VALUES ( 1600, '2007 Zagora St', '50090', 'South Brunswick', 'New Jersey', 'US');
INSERT INTO locations VALUES ( 1700, '2004 Charade Rd', '98199', 'Seattle', 'Washington', 'US');
INSERT INTO locations VALUES ( 1800, '147 Spadina Ave', 'M5V 2L7', 'Toronto', 'Ontario', 'CA');
INSERT INTO locations VALUES ( 1900, '6092 Boxwood St', 'YSW 9T2', 'Whitehorse', 'Yukon', 'CA');
INSERT INTO locations VALUES ( 2000, '40-5-12 Laogianggen', '190518', 'Beijing', NULL, 'CN');
INSERT INTO locations VALUES ( 2100, '1298 Vileparle (E)', '490231', 'Bombay', 'Maharashtra', 'IN');
INSERT INTO locations VALUES ( 2200, '12-98 Victoria Street', '2901', 'Sydney', 'New South Wales', 'AU');
INSERT INTO locations VALUES ( 2300, '198 Clementi North', '540198', 'Singapore', NULL, 'SG');
INSERT INTO locations VALUES ( 2400, '8204 Arthur St', NULL, 'London', NULL, 'UK');
INSERT INTO locations VALUES ( 2500, 'Magdalen Centre, The Oxford Science Park', 'OX9 9ZB', 'Oxford', 'Oxford', 'UK');
INSERT INTO locations VALUES ( 2600, '9702 Chester Road', '09629850293', 'Stretford', 'Manchester', 'UK');
INSERT INTO locations VALUES ( 2700, 'Schwanthalerstr. 7031', '80925', 'Munich', 'Bavaria', 'DE');
INSERT INTO locations VALUES ( 2800, 'Rua Frei Caneca 1360 ', '01307-002', 'Sao Paulo', 'Sao Paulo', 'BR');
INSERT INTO locations VALUES ( 2900, '20 Rue des Corps-Saints', '1730', 'Geneva', 'Geneve', 'CH');
INSERT INTO locations VALUES ( 3000, 'Murtenstrasse 921', '3095', 'Bern', 'BE', 'CH');
INSERT INTO locations VALUES ( 3100, 'Pieter Breughelstraat 837', '3029SK', 'Utrecht', 'Utrecht', 'NL');
INSERT INTO locations VALUES ( 3200, 'Mariano Escobedo 9991', '11932', 'Mexico City', 'Distrito Federal,', 'MX'); 

REM ****************************insert data into the DEPARTMENTS table
REM disable integrity constraint to EMPLOYEES to load data
ALTER TABLE departments     DISABLE CONSTRAINT dept_mgr_fk;

INSERT INTO departments VALUES  ( 10    , 'Administration'    , 200    , 1700 );
INSERT INTO departments VALUES  ( 20    , 'Marketing'         , 201    , 1800 ); 
INSERT INTO departments VALUES  ( 30    , 'Purchasing'        , 114    , 1700 ); 
INSERT INTO departments VALUES  ( 40    , 'Human Resources'   , 203    , 2400 );
INSERT INTO departments VALUES  ( 50    , 'Shipping'          , 121    , 1500 ); 
INSERT INTO departments VALUES  ( 60    , 'IT'                , 103    , 1400 ); 
INSERT INTO departments VALUES  ( 70    , 'Public Relations'  , 204    , 2700 ); 
INSERT INTO departments VALUES  ( 80    , 'Sales'             , 145    , 2500 ); 
INSERT INTO departments VALUES  ( 90    , 'Executive'         , 100    , 1700 );
INSERT INTO departments VALUES  ( 100   , 'Finance'           , 108    , 1700 ); 
INSERT INTO departments VALUES  ( 110   , 'Accounting'        , 205    , 1700 );
INSERT INTO departments VALUES  ( 120   , 'Treasury'          , NULL    , 1700 );
INSERT INTO departments VALUES  ( 130   , 'Corporate Tax'     , NULL    , 1700 );
INSERT INTO departments VALUES  ( 140   , 'Control And Credit'    , NULL    , 1700 );
INSERT INTO departments VALUES  ( 150   , 'Shareholder Services'  , NULL    , 1700 );
INSERT INTO departments VALUES  ( 160   , 'Benefits'          , NULL    , 1700 );
INSERT INTO departments VALUES  ( 170   , 'Manufacturing'     , NULL    , 1700 );
INSERT INTO departments VALUES  ( 180   , 'Construction'      , NULL    , 1700 );
INSERT INTO departments VALUES  ( 190   , 'Contracting'       , NULL    , 1700 );
INSERT INTO departments VALUES  ( 200   , 'Operations'        , NULL    , 1700 );
INSERT INTO departments VALUES  ( 210   , 'IT Support'        , NULL    , 1700 );
INSERT INTO departments VALUES  ( 220   , 'NOC'               , NULL    , 1700 );
INSERT INTO departments VALUES  ( 230   , 'IT Helpdesk'       , NULL    , 1700 );
INSERT INTO departments VALUES  ( 240   , 'Government Sales'  , NULL    , 1700 );
INSERT INTO departments VALUES  ( 250   , 'Retail Sales'      , NULL    , 1700 );
INSERT INTO departments VALUES  ( 260   , 'Recruiting'        , NULL    , 1700 );
INSERT INTO departments VALUES  ( 270   , 'Payroll'           , NULL    , 1700 ); 
       
REM ***************************insert data into the JOBS table
INSERT INTO jobs VALUES ( 'AD_PRES'    , 'President'                        , 20000    , 40000 );    
INSERT INTO jobs VALUES ( 'AD_VP'      , 'Administration Vice President'    , 15000    , 30000 );
INSERT INTO jobs VALUES ( 'AD_ASST'    , 'Administration Assistant'          , 3000    , 6000  );
INSERT INTO jobs VALUES ( 'FI_MGR'     , 'Finance Manager'                  , 8200    , 16000  );
INSERT INTO jobs VALUES ( 'FI_ACCOUNT' , 'Accountant'                        , 4200    , 9000  );
INSERT INTO jobs VALUES ( 'AC_MGR'     , 'Accounting Manager'               , 8200    , 16000  );
INSERT INTO jobs VALUES ( 'AC_ACCOUNT' , 'Public Accountant'                 , 4200    , 9000  );    
INSERT INTO jobs VALUES ( 'SA_MAN'     , 'Sales Manager'                    , 10000    , 20000  );
INSERT INTO jobs VALUES ( 'SA_REP'     , 'Sales Representative'              , 6000    , 12000  );
INSERT INTO jobs VALUES ( 'PU_MAN'     , 'Purchasing Manager'                , 8000    , 15000  );
INSERT INTO jobs VALUES ( 'PU_CLERK'   , 'Purchasing Clerk'                   , 2500    , 5500  );
INSERT INTO jobs VALUES ( 'ST_MAN'     , 'Stock Manager'                      , 5500    , 8500  );   
INSERT INTO jobs VALUES ( 'ST_CLERK'   , 'Stock Clerk'                        , 2000    , 5000  );
INSERT INTO jobs VALUES ( 'SH_CLERK'   , 'Shipping Clerk'                     , 2500    , 5500  );
INSERT INTO jobs VALUES ( 'IT_PROG'    , 'Programmer'                        , 4000    , 10000  );
INSERT INTO jobs VALUES ( 'MK_MAN'     , 'Marketing Manager'                 , 9000    , 15000  );
INSERT INTO jobs VALUES ( 'MK_REP'     , 'Marketing Representative'             , 4000    , 9000);
INSERT INTO jobs VALUES ( 'HR_REP'     , 'Human Resources Representative'     , 4000    , 9000  );
INSERT INTO jobs VALUES ( 'PR_REP'     , 'Public Relations Representative'    , 4500    , 10500  ); 

REM ***************************insert data into the EMPLOYEES table
INSERT INTO employees VALUES (100, 'Steven', 'King', 'SKING',      '515.123.4567', TO_DATE('17-JUN-1987', 'dd-MON-yyyy'), 'AD_PRES' , 24000, NULL, NULL, 90);
INSERT INTO employees VALUES (101, 'Neena', 'Kochhar', 'NKOCHHAR', '515.123.4568', TO_DATE('21-SEP-1989', 'dd-MON-yyyy'), 'AD_VP', 17000, NULL, 100, 90);
INSERT INTO employees VALUES (102, 'Lex', 'De Haan', 'LDEHAAN',    '515.123.4569', TO_DATE('13-JAN-1993', 'dd-MON-yyyy'), 'AD_VP', 17000, NULL, 100, 90);
INSERT INTO employees VALUES (103, 'Alexander', 'Hunold', 'AHUNOLD', '590.423.4567', TO_DATE('03-JAN-1990', 'dd-MON-yyyy'), 'IT_PROG', 9000, NULL, 102, 60);
INSERT INTO employees VALUES (104, 'Bruce', 'Ernst', 'BERNST',     '590.423.4568', TO_DATE('21-MAY-1991', 'dd-MON-yyyy'), 'IT_PROG', 6000, NULL, 103, 60);

INSERT INTO employees VALUES (105, 'David', 'Austin', 'DAUSTIN',   '590.423.4569', TO_DATE('25-JUN-1997', 'dd-MON-yyyy'), 'IT_PROG', 4800, NULL, 103, 60);
INSERT INTO employees VALUES (106, 'Valli', 'Pataballa', 'VPATABAL','590.423.4560', TO_DATE('05-FEB-1998', 'dd-MON-yyyy'), 'IT_PROG', 4800, NULL, 103, 60);
INSERT INTO employees VALUES (107, 'Diana', 'Lorentz', 'DLORENTZ',  '590.423.5567', TO_DATE('07-FEB-1999', 'dd-MON-yyyy'), 'IT_PROG', 4200, NULL, 103, 60);
INSERT INTO employees VALUES (108, 'Nancy', 'Greenberg', 'NGREENBE','515.124.4569', TO_DATE('17-AUG-1994', 'dd-MON-yyyy'), 'FI_MGR', 12000, NULL, 101, 100);
INSERT INTO employees VALUES (109, 'Daniel', 'Faviet', 'DFAVIET',   '515.124.4169', TO_DATE('16-AUG-1994', 'dd-MON-yyyy'), 'FI_ACCOUNT', 9000, NULL, 108, 100);
INSERT INTO employees VALUES (110, 'John', 'Chen', 'JCHEN',        '515.124.4269', TO_DATE('28-SEP-1997', 'dd-MON-yyyy'), 'FI_ACCOUNT', 8200, NULL, 108, 100);
INSERT INTO employees VALUES (111, 'Ismael', 'Sciarra', 'ISCIARRA', '515.124.4369', TO_DATE('30-SEP-1997', 'dd-MON-yyyy'), 'FI_ACCOUNT', 7700, NULL, 108, 100);

INSERT INTO employees VALUES (112, 'Jose Manuel', 'Urman', 'JMURMAN', '515.124.4469', TO_DATE('07-MAR-1998', 'dd-MON-yyyy'), 'FI_ACCOUNT', 7800, NULL, 108, 100);
INSERT INTO employees VALUES (113, 'Luis', 'Popp', 'LPOPP', '515.124.4567', TO_DATE('07-DEC-1999', 'dd-MON-yyyy'), 'FI_ACCOUNT', 6900, NULL, 108, 100);
INSERT INTO employees VALUES (114, 'Den', 'Raphaely', 'DRAPHEAL', '515.127.4561', TO_DATE('07-DEC-1994', 'dd-MON-yyyy'), 'PU_MAN', 11000, NULL, 100, 30);
INSERT INTO employees VALUES (115, 'Alexander', 'Khoo', 'AKHOO', '515.127.4562', TO_DATE('18-MAY-1995', 'dd-MON-yyyy'), 'PU_CLERK', 3100, NULL, 114, 30);
INSERT INTO employees VALUES (116, 'Shelli', 'Baida', 'SBAIDA', '515.127.4563', TO_DATE('24-DEC-1997', 'dd-MON-yyyy'), 'PU_CLERK', 2900, NULL, 114, 30);
INSERT INTO employees VALUES (117, 'Sigal', 'Tobias', 'STOBIAS', '515.127.4564', TO_DATE('24-JUL-1997', 'dd-MON-yyyy'), 'PU_CLERK', 2800, NULL, 114, 30);
INSERT INTO employees VALUES (118, 'Guy', 'Himuro', 'GHIMURO', '515.127.4565', TO_DATE('15-NOV-1998', 'dd-MON-yyyy'), 'PU_CLERK', 2600, NULL, 114, 30);

INSERT INTO employees VALUES (119, 'Karen', 'Colmenares', 'KCOLMENA', '515.127.4566', TO_DATE('10-AUG-1999', 'dd-MON-yyyy'), 'PU_CLERK', 2500, NULL, 114, 30);
INSERT INTO employees VALUES (120, 'Matthew', 'Weiss', 'MWEISS', '650.123.1234', TO_DATE('18-JUL-1996', 'dd-MON-yyyy'), 'ST_MAN', 8000, NULL, 100, 50);
INSERT INTO employees VALUES (121, 'Adam', 'Fripp', 'AFRIPP', '650.123.2234', TO_DATE('10-APR-1997', 'dd-MON-yyyy'), 'ST_MAN', 8200, NULL, 100, 50);
INSERT INTO employees VALUES (122, 'Payam', 'Kaufling', 'PKAUFLIN', '650.123.3234', TO_DATE('01-MAY-1995', 'dd-MON-yyyy'), 'ST_MAN', 7900, NULL, 100, 50);
INSERT INTO employees VALUES (123, 'Shanta', 'Vollman', 'SVOLLMAN', '650.123.4234', TO_DATE('10-OCT-1997', 'dd-MON-yyyy'), 'ST_MAN', 6500, NULL, 100, 50);
INSERT INTO employees VALUES (124, 'Kevin', 'Mourgos', 'KMOURGOS', '650.123.5234', TO_DATE('16-NOV-1999', 'dd-MON-yyyy'), 'ST_MAN', 5800, NULL, 100, 50);
INSERT INTO employees VALUES (125, 'Julia', 'Nayer', 'JNAYER', '650.124.1214', TO_DATE('16-JUL-1997', 'dd-MON-yyyy'), 'ST_CLERK', 3200, NULL, 120, 50);

INSERT INTO employees VALUES (126, 'Irene', 'Mikkilineni', 'IMIKKILI', '650.124.1224', TO_DATE('28-SEP-1998', 'dd-MON-yyyy'), 'ST_CLERK', 2700, NULL, 120, 50);
INSERT INTO employees VALUES (127, 'James', 'Landry', 'JLANDRY', '650.124.1334', TO_DATE('14-JAN-1999', 'dd-MON-yyyy'), 'ST_CLERK', 2400, NULL, 120, 50);
INSERT INTO employees VALUES (128, 'Steven', 'Markle', 'SMARKLE', '650.124.1434', TO_DATE('08-MAR-2000', 'dd-MON-yyyy'), 'ST_CLERK', 2200, NULL, 120, 50);
INSERT INTO employees VALUES (129, 'Laura', 'Bissot', 'LBISSOT', '650.124.5234', TO_DATE('20-AUG-1997', 'dd-MON-yyyy'), 'ST_CLERK', 3300, NULL, 121, 50);
INSERT INTO employees VALUES (130, 'Mozhe', 'Atkinson', 'MATKINSO', '650.124.6234', TO_DATE('30-OCT-1997', 'dd-MON-yyyy'), 'ST_CLERK', 2800, NULL, 121, 50);
INSERT INTO employees VALUES (131, 'James', 'Marlow', 'JAMRLOW', '650.124.7234', TO_DATE('16-FEB-1997', 'dd-MON-yyyy'), 'ST_CLERK', 2500, NULL, 121, 50);
INSERT INTO employees VALUES (132, 'TJ', 'Olson', 'TJOLSON', '650.124.8234', TO_DATE('10-APR-1999', 'dd-MON-yyyy'), 'ST_CLERK', 2100, NULL, 121, 50);

INSERT INTO employees VALUES (133, 'Jason', 'Mallin', 'JMALLIN', '650.127.1934', TO_DATE('14-JUN-1996', 'dd-MON-yyyy'), 'ST_CLERK', 3300, NULL, 122, 50);
INSERT INTO employees VALUES (134, 'Michael', 'Rogers', 'MROGERS', '650.127.1834', TO_DATE('26-AUG-1998', 'dd-MON-yyyy'), 'ST_CLERK', 2900, NULL, 122, 50);
INSERT INTO employees VALUES (135, 'Ki', 'Gee', 'KGEE', '650.127.1734', TO_DATE('12-DEC-1999', 'dd-MON-yyyy'), 'ST_CLERK', 2400, NULL, 122, 50);
INSERT INTO employees VALUES (136, 'Hazel', 'Philtanker', 'HPHILTAN', '650.127.1634', TO_DATE('06-FEB-2000', 'dd-MON-yyyy'), 'ST_CLERK', 2200, NULL, 122, 50);
INSERT INTO employees VALUES (137, 'Renske', 'Ladwig', 'RLADWIG', '650.121.1234', TO_DATE('14-JUL-1995', 'dd-MON-yyyy'), 'ST_CLERK', 3600, NULL, 123, 50);
INSERT INTO employees VALUES (138, 'Stephen', 'Stiles', 'SSTILES', '650.121.2034', TO_DATE('26-OCT-1997', 'dd-MON-yyyy'), 'ST_CLERK', 3200, NULL, 123, 50);
INSERT INTO employees VALUES (139, 'John', 'Seo', 'JSEO', '650.121.2019', TO_DATE('12-FEB-1998', 'dd-MON-yyyy'), 'ST_CLERK', 2700, NULL, 123, 50);

INSERT INTO employees VALUES (140, 'Joshua', 'Patel', 'JPATEL', '650.121.1834', TO_DATE('06-APR-1998', 'dd-MON-yyyy'), 'ST_CLERK', 2500, NULL, 123, 50);
INSERT INTO employees VALUES (141, 'Trenna', 'Rajs', 'TRAJS', '650.121.8009', TO_DATE('17-OCT-1995', 'dd-MON-yyyy'), 'ST_CLERK', 3500, NULL, 124, 50);
INSERT INTO employees VALUES (142, 'Curtis', 'Davies', 'CDAVIES', '650.121.2994', TO_DATE('29-JAN-1997', 'dd-MON-yyyy'), 'ST_CLERK', 3100, NULL, 124, 50);
INSERT INTO employees VALUES (143, 'Randall', 'Matos', 'RMATOS', '650.121.2874', TO_DATE('15-MAR-1998', 'dd-MON-yyyy'), 'ST_CLERK', 2600, NULL, 124, 50);
INSERT INTO employees VALUES (144, 'Peter', 'Vargas', 'PVARGAS', '650.121.2004', TO_DATE('09-JUL-1998', 'dd-MON-yyyy'), 'ST_CLERK', 2500, NULL, 124, 50);
INSERT INTO employees VALUES (145, 'John', 'Russell', 'JRUSSEL', '011.44.1344.429268', TO_DATE('01-OCT-1996', 'dd-MON-yyyy'), 'SA_MAN', 14000, .4, 100, 80);
INSERT INTO employees VALUES (146, 'Karen', 'Partners', 'KPARTNER', '011.44.1344.467268', TO_DATE('05-JAN-1997', 'dd-MON-yyyy'), 'SA_MAN', 13500, .3, 100, 80);

INSERT INTO employees VALUES (147, 'Alberto', 'Errazuriz', 'AERRAZUR', '011.44.1344.429278', TO_DATE('10-MAR-1997', 'dd-MON-yyyy'), 'SA_MAN', 12000, .3, 100, 80);
INSERT INTO employees VALUES (148, 'Gerald', 'Cambrault', 'GCAMBRAU', '011.44.1344.619268', TO_DATE('15-OCT-1999', 'dd-MON-yyyy'), 'SA_MAN', 11000, .3, 100, 80);
INSERT INTO employees VALUES (149, 'Eleni', 'Zlotkey', 'EZLOTKEY', '011.44.1344.429018', TO_DATE('29-JAN-2000', 'dd-MON-yyyy'), 'SA_MAN', 10500, .2, 100, 80);
INSERT INTO employees VALUES (150, 'Peter', 'Tucker', 'PTUCKER', '011.44.1344.129268', TO_DATE('30-JAN-1997', 'dd-MON-yyyy'), 'SA_REP', 10000, .3, 145, 80);
INSERT INTO employees VALUES (151, 'David', 'Bernstein', 'DBERNSTE', '011.44.1344.345268', TO_DATE('24-MAR-1997', 'dd-MON-yyyy'), 'SA_REP', 9500, .25, 145, 80);
INSERT INTO employees VALUES (152, 'Peter', 'Hall', 'PHALL', '011.44.1344.478968', TO_DATE('20-AUG-1997', 'dd-MON-yyyy'), 'SA_REP', 9000, .25, 145, 80);
INSERT INTO employees VALUES (153, 'Christopher', 'Olsen', 'COLSEN', '011.44.1344.498718', TO_DATE('30-MAR-1998', 'dd-MON-yyyy'), 'SA_REP', 8000, .2, 145, 80);

INSERT INTO employees VALUES (154, 'Nanette', 'Cambrault', 'NCAMBRAU', '011.44.1344.987668', TO_DATE('09-DEC-1998', 'dd-MON-yyyy'), 'SA_REP', 7500, .2, 145, 80);
INSERT INTO employees VALUES (155, 'Oliver', 'Tuvault', 'OTUVAULT', '011.44.1344.486508', TO_DATE('23-NOV-1999', 'dd-MON-yyyy'), 'SA_REP', 7000, .15, 145, 80);
INSERT INTO employees VALUES (156, 'Janette', 'King', 'JKING', '011.44.1345.429268', TO_DATE('30-JAN-1996', 'dd-MON-yyyy'), 'SA_REP', 10000, .35, 146, 80);
INSERT INTO employees VALUES (157, 'Patrick', 'Sully', 'PSULLY', '011.44.1345.929268', TO_DATE('04-MAR-1996', 'dd-MON-yyyy'), 'SA_REP', 9500, .35, 146, 80);
INSERT INTO employees VALUES (158, 'Allan', 'McEwen', 'AMCEWEN', '011.44.1345.829268', TO_DATE('01-AUG-1996', 'dd-MON-yyyy'), 'SA_REP', 9000, .35, 146, 80);
INSERT INTO employees VALUES (159, 'Lindsey', 'Smith', 'LSMITH', '011.44.1345.729268', TO_DATE('10-MAR-1997', 'dd-MON-yyyy'), 'SA_REP', 8000, .3, 146, 80);
INSERT INTO employees VALUES (160, 'Louise', 'Doran', 'LDORAN', '011.44.1345.629268', TO_DATE('15-DEC-1997', 'dd-MON-yyyy'), 'SA_REP', 7500, .3, 146, 80);

INSERT INTO employees VALUES (161, 'Sarath', 'Sewall', 'SSEWALL', '011.44.1345.529268', TO_DATE('03-NOV-1998', 'dd-MON-yyyy'), 'SA_REP', 7000, .25, 146, 80);
INSERT INTO employees VALUES (162, 'Clara', 'Vishney', 'CVISHNEY', '011.44.1346.129268', TO_DATE('11-NOV-1997', 'dd-MON-yyyy'), 'SA_REP', 10500, .25, 147, 80);
INSERT INTO employees VALUES (163, 'Danielle', 'Greene', 'DGREENE', '011.44.1346.229268', TO_DATE('19-MAR-1999', 'dd-MON-yyyy'), 'SA_REP', 9500, .15, 147, 80);
INSERT INTO employees VALUES (164, 'Mattea', 'Marvins', 'MMARVINS', '011.44.1346.329268', TO_DATE('24-JAN-2000', 'dd-MON-yyyy'), 'SA_REP', 7200, .10, 147, 80);
INSERT INTO employees VALUES (165, 'David', 'Lee', 'DLEE', '011.44.1346.529268', TO_DATE('23-FEB-2000', 'dd-MON-yyyy'), 'SA_REP', 6800, .1, 147, 80);
INSERT INTO employees VALUES (166, 'Sundar', 'Ande', 'SANDE', '011.44.1346.629268', TO_DATE('24-MAR-2000', 'dd-MON-yyyy'), 'SA_REP', 6400, .10, 147, 80);
INSERT INTO employees VALUES (167, 'Amit', 'Banda', 'ABANDA', '011.44.1346.729268', TO_DATE('21-APR-2000', 'dd-MON-yyyy'), 'SA_REP', 6200, .10, 147, 80);

INSERT INTO employees VALUES (168, 'Lisa', 'Ozer', 'LOZER', '011.44.1343.929268', TO_DATE('11-MAR-1997', 'dd-MON-yyyy'), 'SA_REP', 11500, .25, 148, 80);
INSERT INTO employees VALUES (169 , 'Harrison', 'Bloom', 'HBLOOM', '011.44.1343.829268', TO_DATE('23-MAR-1998', 'dd-MON-yyyy'), 'SA_REP', 10000, .20, 148, 80);
INSERT INTO employees VALUES (170, 'Tayler', 'Fox', 'TFOX', '011.44.1343.729268', TO_DATE('24-JAN-1998', 'dd-MON-yyyy'), 'SA_REP', 9600, .20, 148, 80);
INSERT INTO employees VALUES (171, 'William', 'Smith', 'WSMITH', '011.44.1343.629268', TO_DATE('23-FEB-1999', 'dd-MON-yyyy'), 'SA_REP', 7400, .15, 148, 80);
INSERT INTO employees VALUES (172, 'Elizabeth', 'Bates', 'EBATES', '011.44.1343.529268', TO_DATE('24-MAR-1999', 'dd-MON-yyyy'), 'SA_REP', 7300, .15, 148, 80);
INSERT INTO employees VALUES (173, 'Sundita', 'Kumar', 'SKUMAR', '011.44.1343.329268', TO_DATE('21-APR-2000', 'dd-MON-yyyy'), 'SA_REP', 6100, .10, 148, 80);
INSERT INTO employees VALUES (174, 'Ellen', 'Abel', 'EABEL', '011.44.1644.429267', TO_DATE('11-MAY-1996', 'dd-MON-yyyy'), 'SA_REP', 11000, .30, 149, 80);

INSERT INTO employees VALUES (175, 'Alyssa', 'Hutton', 'AHUTTON', '011.44.1644.429266', TO_DATE('19-MAR-1997', 'dd-MON-yyyy'), 'SA_REP', 8800, .25, 149, 80);
INSERT INTO employees VALUES (176, 'Jonathon', 'Taylor', 'JTAYLOR', '011.44.1644.429265', TO_DATE('24-MAR-1998', 'dd-MON-yyyy'), 'SA_REP', 8600, .20, 149, 80);
INSERT INTO employees VALUES (177, 'Jack', 'Livingston', 'JLIVINGS', '011.44.1644.429264', TO_DATE('23-APR-1998', 'dd-MON-yyyy'), 'SA_REP', 8400, .20, 149, 80);
INSERT INTO employees VALUES (178, 'Kimberely', 'Grant', 'KGRANT', '011.44.1644.429263', TO_DATE('24-MAY-1999', 'dd-MON-yyyy'), 'SA_REP', 7000, .15, 149, NULL);
INSERT INTO employees VALUES (179, 'Charles', 'Johnson', 'CJOHNSON', '011.44.1644.429262', TO_DATE('04-JAN-2000', 'dd-MON-yyyy'), 'SA_REP', 6200, .10, 149, 80);
INSERT INTO employees VALUES (180, 'Winston', 'Taylor', 'WTAYLOR', '650.507.9876', TO_DATE('24-JAN-1998', 'dd-MON-yyyy'), 'SH_CLERK', 3200, NULL, 120, 50);
INSERT INTO employees VALUES (181, 'Jean', 'Fleaur', 'JFLEAUR', '650.507.9877', TO_DATE('23-FEB-1998', 'dd-MON-yyyy'), 'SH_CLERK', 3100, NULL, 120, 50);

INSERT INTO employees VALUES (182, 'Martha', 'Sullivan', 'MSULLIVA', '650.507.9878', TO_DATE('21-JUN-1999', 'dd-MON-yyyy'), 'SH_CLERK', 2500, NULL, 120, 50);
INSERT INTO employees VALUES (183, 'Girard', 'Geoni', 'GGEONI', '650.507.9879', TO_DATE('03-FEB-2000', 'dd-MON-yyyy'), 'SH_CLERK', 2800, NULL, 120, 50);
INSERT INTO employees VALUES (184, 'Nandita', 'Sarchand', 'NSARCHAN', '650.509.1876', TO_DATE('27-JAN-1996', 'dd-MON-yyyy'), 'SH_CLERK', 4200, NULL, 121, 50);
INSERT INTO employees VALUES (185, 'Alexis', 'Bull', 'ABULL', '650.509.2876', TO_DATE('20-FEB-1997', 'dd-MON-yyyy'), 'SH_CLERK', 4100, NULL, 121, 50);
INSERT INTO employees VALUES (186, 'Julia', 'Dellinger', 'JDELLING', '650.509.3876', TO_DATE('24-JUN-1998', 'dd-MON-yyyy'), 'SH_CLERK', 3400, NULL, 121, 50);
INSERT INTO employees VALUES (187, 'Anthony', 'Cabrio', 'ACABRIO', '650.509.4876', TO_DATE('07-FEB-1999', 'dd-MON-yyyy'), 'SH_CLERK', 3000, NULL, 121, 50);
INSERT INTO employees VALUES (188, 'Kelly', 'Chung', 'KCHUNG', '650.505.1876', TO_DATE('14-JUN-1997', 'dd-MON-yyyy'), 'SH_CLERK', 3800, NULL, 122, 50);

INSERT INTO employees VALUES (189, 'Jennifer', 'Dilly', 'JDILLY', '650.505.2876', TO_DATE('13-AUG-1997', 'dd-MON-yyyy'), 'SH_CLERK', 3600, NULL, 122, 50);
INSERT INTO employees VALUES (190, 'Timothy', 'Gates', 'TGATES', '650.505.3876', TO_DATE('11-JUL-1998', 'dd-MON-yyyy'), 'SH_CLERK', 2900, NULL, 122, 50);
INSERT INTO employees VALUES (191, 'Randall', 'Perkins', 'RPERKINS', '650.505.4876', TO_DATE('19-DEC-1999', 'dd-MON-yyyy'), 'SH_CLERK', 2500, NULL, 122, 50);
INSERT INTO employees VALUES (192, 'Sarah', 'Bell', 'SBELL', '650.501.1876', TO_DATE('04-FEB-1996', 'dd-MON-yyyy'), 'SH_CLERK', 4000, NULL, 123, 50);
INSERT INTO employees VALUES (193, 'Britney', 'Everett', 'BEVERETT', '650.501.2876', TO_DATE('03-MAR-1997', 'dd-MON-yyyy'), 'SH_CLERK', 3900, NULL, 123, 50);
INSERT INTO employees VALUES (194, 'Samuel', 'McCain', 'SMCCAIN', '650.501.3876', TO_DATE('01-JUL-1998', 'dd-MON-yyyy'), 'SH_CLERK', 3200, NULL, 123, 50);
INSERT INTO employees VALUES (195, 'Vance', 'Jones', 'VJONES', '650.501.4876', TO_DATE('17-MAR-1999', 'dd-MON-yyyy'), 'SH_CLERK', 2800, NULL, 123, 50);

INSERT INTO employees VALUES (196, 'Alana', 'Walsh', 'AWALSH', '650.507.9811', TO_DATE('24-APR-1998', 'dd-MON-yyyy'), 'SH_CLERK', 3100, NULL, 124, 50);
INSERT INTO employees VALUES (197, 'Kevin', 'Feeney', 'KFEENEY', '650.507.9822', TO_DATE('23-MAY-1998', 'dd-MON-yyyy'), 'SH_CLERK', 3000, NULL, 124, 50);
INSERT INTO employees VALUES (198, 'Donald', 'OConnell', 'DOCONNEL', '650.507.9833', TO_DATE('21-JUN-1999', 'dd-MON-yyyy'), 'SH_CLERK', 2600, NULL, 124, 50);
INSERT INTO employees VALUES (199, 'Douglas', 'Grant', 'DGRANT', '650.507.9844', TO_DATE('13-JAN-2000', 'dd-MON-yyyy'), 'SH_CLERK', 2600, NULL, 124, 50);
INSERT INTO employees VALUES (200, 'Jennifer', 'Whalen', 'JWHALEN', '515.123.4444', TO_DATE('17-SEP-1987', 'dd-MON-yyyy'), 'AD_ASST', 4400, NULL, 101, 10);
INSERT INTO employees VALUES (201, 'Michael', 'Hartstein', 'MHARTSTE', '515.123.5555', TO_DATE('17-FEB-1996', 'dd-MON-yyyy'), 'MK_MAN', 13000, NULL, 100, 20);
INSERT INTO employees VALUES (202, 'Pat', 'Fay', 'PFAY', '603.123.6666', TO_DATE('17-AUG-1997', 'dd-MON-yyyy'), 'MK_REP', 6000, NULL, 201, 20);
INSERT INTO employees VALUES (203, 'Susan', 'Mavris', 'SMAVRIS', '515.123.7777', TO_DATE('07-JUN-1994', 'dd-MON-yyyy'), 'HR_REP', 6500, NULL, 101, 40);
INSERT INTO employees VALUES (204, 'Hermann', 'Baer', 'HBAER', '515.123.8888', TO_DATE('07-JUN-1994', 'dd-MON-yyyy'), 'PR_REP', 10000, NULL, 101, 70);
INSERT INTO employees VALUES (205, 'Shelley', 'Higgins', 'SHIGGINS', '515.123.8080', TO_DATE('07-JUN-1994', 'dd-MON-yyyy'), 'AC_MGR', 12000, NULL, 101, 110);
INSERT INTO employees VALUES (206, 'William', 'Gietz', 'WGIETZ', '515.123.8181', TO_DATE('07-JUN-1994', 'dd-MON-yyyy'), 'AC_ACCOUNT', 8300, NULL, 205, 110);
       
REM ********* insert data into the JOB_HISTORY table 
INSERT INTO job_history VALUES (102 , TO_DATE('13-JAN-1993', 'dd-MON-yyyy') , TO_DATE('24-JUL-1998', 'dd-MON-yyyy') , 'IT_PROG'   , 60 );
INSERT INTO job_history VALUES (101 , TO_DATE('21-SEP-1989', 'dd-MON-yyyy') , TO_DATE('27-OCT-1993', 'dd-MON-yyyy') , 'AC_ACCOUNT', 110);
INSERT INTO job_history VALUES (101 , TO_DATE('28-OCT-1993', 'dd-MON-yyyy') , TO_DATE('15-MAR-1997', 'dd-MON-yyyy') , 'AC_MGR'    , 110);
INSERT INTO job_history VALUES (201 , TO_DATE('17-FEB-1996', 'dd-MON-yyyy') , TO_DATE('19-DEC-1999', 'dd-MON-yyyy') , 'MK_REP'    , 20 );
INSERT INTO job_history VALUES (114 , TO_DATE('24-MAR-1998', 'dd-MON-yyyy') , TO_DATE('31-DEC-1999', 'dd-MON-yyyy') , 'ST_CLERK'  , 50 );
INSERT INTO job_history VALUES (122 , TO_DATE('01-JAN-1999', 'dd-MON-yyyy') , TO_DATE('31-DEC-1999', 'dd-MON-yyyy') , 'ST_CLERK'  , 50 );
INSERT INTO job_history VALUES (200 , TO_DATE('17-SEP-1987', 'dd-MON-yyyy') , TO_DATE('17-JUN-1993', 'dd-MON-yyyy') , 'AD_ASST'   , 90 );
INSERT INTO job_history VALUES (176 , TO_DATE('24-MAR-1998', 'dd-MON-yyyy') , TO_DATE('31-DEC-1998', 'dd-MON-yyyy') , 'SA_REP'    , 80 );
INSERT INTO job_history VALUES (176 , TO_DATE('01-JAN-1999', 'dd-MON-yyyy') , TO_DATE('31-DEC-1999', 'dd-MON-yyyy') , 'SA_MAN'    , 80 );
INSERT INTO job_history VALUES (200 , TO_DATE('01-JUL-1994', 'dd-MON-yyyy') , TO_DATE('31-DEC-1998', 'dd-MON-yyyy') , 'AC_ACCOUNT', 90 );

REM enable integrity constraint to DEPARTMENTS
ALTER TABLE departments     ENABLE CONSTRAINT dept_mgr_fk;
COMMIT;

CREATE INDEX emp_department_ix ON employees (department_id);
CREATE INDEX emp_job_ix        ON employees (job_id);
CREATE INDEX emp_manager_ix    ON employees (manager_id);
CREATE INDEX emp_name_ix       ON employees (last_name, first_name);
CREATE INDEX dept_location_ix  ON departments (location_id);
CREATE INDEX jhist_job_ix      ON job_history (job_id);
CREATE INDEX jhist_employee_ix ON job_history (employee_id);
CREATE INDEX jhist_department_ix ON job_history (department_id);
CREATE INDEX loc_city_ix       ON locations (city);
CREATE INDEX loc_state_province_ix  ON locations (state_province);
CREATE INDEX loc_country_ix    ON locations (country_id);
COMMIT;
REM procedure and statement trigger to allow dmls during business hours:
         CREATE OR REPLACE PROCEDURE secure_dml
         IS
         BEGIN
   IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
   OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
   RAISE_APPLICATION_ERROR (-20205, 
   'You may only make changes during normal office hours');
   END IF;
   END secure_dml;
   /
CREATE OR REPLACE TRIGGER secure_employees
   BEFORE INSERT OR UPDATE OR DELETE ON employees
   BEGIN
   secure_dml;
   END secure_employees;
   /
ALTER TRIGGER secure_employees DISABLE;
REM **************************************************************************
REM procedure to add a row to the JOB_HISTORY table and row trigger 
REM to call the procedure when data is updated in the job_id or 
REM department_id columns in the EMPLOYEES table:
CREATE OR REPLACE PROCEDURE add_job_history
   ( p_emp_id job_history.employee_id%type
   , p_start_date job_history.start_date%type
   , p_end_date job_history.end_date%type
   , p_job_id job_history.job_id%type
   , p_department_id job_history.department_id%type 
   )
   IS
   BEGIN
   INSERT INTO job_history (employee_id, start_date, end_date, 
   job_id, department_id)
   VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
   END add_job_history;
   /
CREATE OR REPLACE TRIGGER update_job_history
   AFTER UPDATE OF job_id, department_id ON employees
   FOR EACH ROW
   BEGIN
   add_job_history(:old.employee_id, :old.hire_date, sysdate, 
   :old.job_id, :old.department_id);
   END;
   /
COMMIT;
COMMENT ON TABLE regions 
         IS 'Regions table that contains region numbers and names. Contains 4 rows; references with the Countries table.';
COMMENT ON COLUMN regions.region_id
         IS 'Primary key of regions table.';
COMMENT ON COLUMN regions.region_name
         IS 'Names of regions. Locations are in the countries of these regions.';
COMMENT ON TABLE locations
         IS 'Locations table that contains specific address of a specific office,
         warehouse, and/or production site of a company. Does not store addresses /
         locations of customers. Contains 23 rows; references with the
         departments and countries tables. ';
COMMENT ON COLUMN locations.location_id
         IS 'Primary key of locations table';
COMMENT ON COLUMN locations.street_address
         IS 'Street address of an office, warehouse, or production site of a company.
         Contains building number and street name';
COMMENT ON COLUMN locations.postal_code
         IS 'Postal code of the location of an office, warehouse, or production site 
         of a company. ';
COMMENT ON COLUMN locations.city
         IS 'A not null column that shows city where an office, warehouse, or 
         production site of a company is located. ';
COMMENT ON COLUMN locations.state_province
         IS 'State or Province where an office, warehouse, or production site of a 
         company is located.';
COMMENT ON COLUMN locations.country_id
         IS 'Country where an office, warehouse, or production site of a company is
         located. Foreign key to country_id column of the countries table.';
       
REM *********************************************
COMMENT ON TABLE departments
         IS 'Departments table that shows details of departments where employees 
         work. Contains 27 rows; references with locations, employees, and job_history tables.';
COMMENT ON COLUMN departments.department_id
         IS 'Primary key column of departments table.';
COMMENT ON COLUMN departments.department_name
         IS 'A not null column that shows name of a department. Administration, 
         Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public 
         Relations, Sales, Finance, and Accounting. ';
COMMENT ON COLUMN departments.manager_id
         IS 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of 
         the employee table references this column.';
COMMENT ON COLUMN departments.location_id
         IS 'Location id where a department is located. Foreign key to location_id column of locations table.';
       
REM *********************************************
COMMENT ON TABLE job_history
         IS 'Table that stores job history of the employees. If an employee 
         changes departments within the job or changes jobs within the department, 
         new rows get inserted into this table with old job information of the 
         employee. Contains a complex primary key: employee_id+start_date.
         Contains 25 rows. References with jobs, employees, and departments tables.';
COMMENT ON COLUMN job_history.employee_id
         IS 'A not null column in the complex primary key employee_id+start_date.
         Foreign key to employee_id column of the employee table';
COMMENT ON COLUMN job_history.start_date
         IS 'A not null column in the complex primary key employee_id+start_date. 
         Must be less than the end_date of the job_history table. (enforced by 
         constraint jhist_date_interval)';
COMMENT ON COLUMN job_history.end_date
         IS 'Last day of the employee in this job role. A not null column. Must be 
         greater than the start_date of the job_history table. 
         (enforced by constraint jhist_date_interval)';
COMMENT ON COLUMN job_history.job_id
         IS 'Job role in which the employee worked in the past; foreign key to 
         job_id column in the jobs table. A not null column.';
COMMENT ON COLUMN job_history.department_id
         IS 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table';
       
REM *********************************************
COMMENT ON TABLE countries
         IS 'country table. Contains 25 rows. References with locations table.';
COMMENT ON COLUMN countries.country_id
         IS 'Primary key of countries table.';
COMMENT ON COLUMN countries.country_name
         IS 'Country name';
COMMENT ON COLUMN countries.region_id
         IS 'Region ID for the country. Foreign key to region_id column in the departments table.';
REM *********************************************
COMMENT ON TABLE jobs
         IS 'jobs table with job titles and salary ranges. Contains 19 rows.
         References with employees and job_history table.';
COMMENT ON COLUMN jobs.job_id
         IS 'Primary key of jobs table.';
COMMENT ON COLUMN jobs.job_title
         IS 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';
COMMENT ON COLUMN jobs.min_salary
         IS 'Minimum salary for a job title.';
COMMENT ON COLUMN jobs.max_salary
         IS 'Maximum salary for a job title';
REM *********************************************
COMMENT ON TABLE employees
         IS 'employees table. Contains 107 rows. References with departments, 
         jobs, job_history tables. Contains a self reference.';
COMMENT ON COLUMN employees.employee_id
         IS 'Primary key of employees table.';
COMMENT ON COLUMN employees.first_name
         IS 'First name of the employee. A not null column.';
COMMENT ON COLUMN employees.last_name
         IS 'Last name of the employee. A not null column.';
COMMENT ON COLUMN employees.email
         IS 'Email id of the employee';
COMMENT ON COLUMN employees.phone_number
         IS 'Phone number of the employee; includes country code and area code';
COMMENT ON COLUMN employees.hire_date
         IS 'Date when the employee started on this job. A not null column.';
COMMENT ON COLUMN employees.job_id
         IS 'Current job of the employee; foreign key to job_id column of the 
         jobs table. A not null column.';
COMMENT ON COLUMN employees.salary
         IS 'Monthly salary of the employee. Must be greater 
         than zero (enforced by constraint emp_salary_min)';
COMMENT ON COLUMN employees.commission_pct
         IS 'Commission percentage of the employee; Only employees in sales 
         department elgible for commission percentage';
COMMENT ON COLUMN employees.manager_id
         IS 'Manager id of the employee; has same domain as manager_id in 
         departments table. Foreign key to employee_id column of employees table.
         (useful for reflexive joins and CONNECT BY query)';
COMMENT ON COLUMN employees.department_id
         IS 'Department id where employee works; foreign key to department_id 
         column of the departments table';
COMMIT;

REM HW1
REM Q1. 
SELECT employee_id, Last_name,  First_name, department_id
FROM   Employees 
Where  upper (last_name) like 'ST%' ;

REM Q2.
DESCRIBE Employees;
SELECT employee_id, last_name || ', ' || first_name  AS Full_Name, department_id, salary
FROM Employees
WHERE MANAGER_ID = 145;

REM 03.
SELECT employee_id, last_name || ', ' || first_name  AS Full_Name, department_id, salary, manager_id
FROM Employees, (SELECT Full_Name, select_id
FROM
(SELECT last_name || ', ' || first_name  AS Full_Name, manager_id as select_id
FROM Employees)
WHERE  upper(Full_Name)= 'RUSSELL, JOHN')

WHERE Employees.MANAGER_ID = select_id;


REM 04.
CREATE TABLE new_table as 
(SELECT department_id, COUNT(employee_id) as num_emp
FROM Employees GROUP BY department_id);

SELECT * FROM new_table;

SELECT departments.department_id, departments.department_name, new_table.num_emp
FROM departments, new_table
WHERE departments.department_id = new_table.department_id
ORDER BY num_emp;

SELECT departments.department_id, departments.department_name,new_table.num_emp
FROM departments
FULL OUTER JOIN new_table ON departments.department_id = new_table.department_id
ORDER BY new_table.num_emp;

REM 05.
SELECT last_name || ', ' || first_name  AS Full_Name,salary
FROM employees
WHERE  department_ID IS null;   

REM 06.
SELECT employee_id, last_name, first_name, department_id
FROM Employees
WHERE last_name in 
      (select last_name from employees 
           group by last_name 
           having count(*) > 1);

REM 07.
DESCRIBE employees;
SELECT e.EMPLOYEE_ID, e.last_name, e.first_name, e.department_id, e.manager_id,d.manager_id as deparnment_head
FROM   employees e, departments d
WHERE  e.department_ID = d.department_ID and 
       e.department_id in (60, 70)       and
e.manager_ID != d.manager_id;
             

REM 08.
DECLARE 
  l_name VARCHAR2(20);
  sal NUMBER(8,2);

BEGIN
 l_name :='Jackson';
 sal := 7777;
 DBMS_OUTPUT.PUT_LINE ( ' ' || l_name || q'[']' || 'salary is:'|| TO_CHAR(sal,'$999,999.99'));

END;


REM 09(a).
DECLARE
    v1  boolean := Null;  
Begin 
    IF v1 is null THEN   
       DBMS_OUTPUT.PUT_LINE ('Value of v1 is NULL.');
    END IF;
END;

REM 09.(b)
DECLARE
    v2  boolean := FALSE; 
Begin 
    IF v2 = False THEN   
       DBMS_OUTPUT.PUT_LINE ('Value of v2 is False' );
   END IF;
END;

REM 10.
<<outer_a>>
DECLARE
counter integer := 101;
v1  varchar2 (30) := 'Adams';
BEGIN
DECLARE 
counter integer := 55;
BEGIN
 DBMS_OUTPUT.PUT_LINE (' counter not from outer_b = ' || counter ||'.');
 DBMS_OUTPUT.PUT_LINE (' counter from outer_a = ' || outer_a.counter ||'.');
 
END;
DBMS_OUTPUT.PUT_LINE (' v1 value from outer_a =' || v1 || '.');
END outer_a;


REM. HW2
REM. Q1
DROP TABLE departments_temp; 
CREATE TABLE departments_temp as
SELECT department_id, department_name, manager_id, location_id
FROM   departments;
SELECT * from departments_temp;
-- 

DECLARE
dp_id		departments_temp.department_id %TYPE := 111;
dp_name 	departments_temp.department_name %TYPE := 'Forest';
mg_id		departments_temp.manager_id%TYPE :=100;
loc_id 		departments_temp.location_id %TYPE :=1700;


BEGIN
INSERT INTO departments_temp (department_id, department_name, manager_id, location_id)
VALUES (dp_id, dp_name, mg_id, loc_id);

DBMS_OUTPUT.PUT_LINE ('New record department with ID = ' || dp_id ||  ', name is ' || dp_name || ', manager id is ' || mg_id || ', location id is ' || loc_id || '.');


END;

REM.Q2
DECLARE

dp_name 	departments_temp.department_name %TYPE;
mg_id		departments_temp.manager_id %TYPE;


BEGIN
DELETE FROM departments_temp
WHERE department_id = 111 and department_name = 'Forest'
RETURNING department_name, manager_id	  -- PL/SQL Special
INTO dp_name, mg_id;		

DBMS_OUTPUT.PUT_LINE ('After DELETION: the record deleted had department name : ' || dp_name || ', manager id : ' || mg_id ||'.');

END;

REM. Q3

DECLARE
dp_name 	departments_temp.department_name %TYPE;

BEGIN
UPDATE departments_temp
SET manager_ID = 103
WHERE department_id = 230
RETURNING department_name	  
INTO dp_name;		

DBMS_OUTPUT.PUT_LINE ('After updated: the record deleted had department name : ' || dp_name || '.');

END;

REM. Q4
DECLARE

num_emoloyees NUMBER(6);
dept_size varchar2(20);

BEGIN
SELECT    count(*)
    INTO  num_emoloyees 	-- pay attention to “INTO” 
FROM    employees
WHERE	 department_id = 80; 		-- condition for unique row returned

CASE 
WHEN num_emoloyees >30 THEN dept_size:= 'LARGE';
WHEN num_emoloyees <30 and  num_emoloyees >8 THEN dept_size:= 'MEDIUM';
ELSE dept_size:= 'SMALL';
END CASE;
DBMS_OUTPUT.PUT_LINE ('For department 80, the size of employees is ' || dept_size || '.');

END;


REM. Q5

DECLARE

    emp_id employees.employee_id%TYPE;
    emp_salary employees.salary%TYPE;
    emp_YEARS NUMBER(10);
    total_bonus NUMBER(10);
    work_year_bonus NUMBER(10);
    range_bonus NUMBER(10);

BEGIN

    SELECT 	employee_id, salary, floor (months_between (sysdate, hire_date)/12) YEARS
    INTO  emp_id,  emp_salary, emp_YEARS
    FROM  employees 
    where employee_id =206;


    IF emp_salary >= 25 and emp_salary < 27 
     THEN work_year_bonus := 500;
        ELSIF emp_YEARS  >= 27 THEN work_year_bonus := 700;
    END IF;

        
CASE 
WHEN emp_salary	> 10000 THEN range_bonus:= 1100;
WHEN emp_salary	<=10000 and  emp_salary	>=5000 
    THEN range_bonus:= 1000;
ELSE     range_bonus:= 900;
END CASE;

 	
  total_bonus := 1000 + work_year_bonus+ range_bonus;

  DBMS_OUTPUT.PUT_LINE ('For employee with ID 206, his bonus is ' || TO_CHAR (total_bonus, '$999,999') || '.');

End;


Column  salary format $99,999
SELECT 	employee_id, salary, 
		floor (months_between (sysdate, hire_date)/12) Years
FROM 	employees 
where employee_id in ( 128, 192, 206);


REM. Q6
DECLARE
  x NUMBER := 15; 		-- the program needs to manage the counter  
BEGIN

END;
-- for loop 
BEGIN
FOR i IN 15 .. 17 LOOP	-- i is dummy index, no need to declare
      DBMS_OUTPUT.PUT_LINE ('i is: ' || TO_CHAR(i));
   END LOOP;
END;

--while loop 
DECLARE x Number := 15;
BEGIN
WHILE x < 18 LOOP
DBMS_OUTPUT.PUT_LINE ('x = ' || TO_CHAR(x));
x := x + 1;
END LOOP;

END;



REM. Q7
BEGIN 
   FOR i IN 1..9 LOOP 
      DBMS_OUTPUT.PUT_LINE('|');
      
      FOR j IN 1..9 LOOP 
         DBMS_OUTPUT.PUT(' ' || i || j || ' '); 
      END loop; 
      
      DBMS_OUTPUT.PUT_LINE('|');
   END loop; 
END;

-- while loop
DECLARE 
i number := 1;
j number := 1;
BEGIN

WHILE 
    i < 10 LOOP
    DBMS_OUTPUT.PUT_LINE('|');
    
   WHILE 
   j < 10 LOOP
   DBMS_OUTPUT.PUT(' ' || i || j || ' '); 
   j := j+1;
   
  
   
   END LOOP;
   DBMS_OUTPUT.PUT_LINE('|');
   i := i+1;
   j :=1;
END LOOP;
END;
REM. Q8
DROP TABLE EMP_TEST;
CREATE TABLE EMP_TEST as select * from employees 
           where department_id in (20, 30, 60);
SELECT * from EMP_TEST; -- to check if that works, 


DECLARE
     CURSOR cursor_update IS 
     SELECT salary, employee_id,Department_id             -- In simple case only one table 
        FROM EMP_TEST
        FOR UPDATE OF salary; -- With FOR UPDATE OF request
        
        salary    EMP_TEST.salary%TYPE;
        Employee_id  EMP_TEST.employee_id%TYPE;
        Department_id EMP_TEST.department_id%TYPE;

BEGIN
    
OPEN cursor_update;
    LOOP
     	FETCH cursor_update INTO salary, employee_id, Department_id;
        EXIT WHEN cursor_update%NOTFOUND;
	IF SALARY <= 3000 and Department_id =30 THEN
		salary := salary * 1.1;

	   DBMS_OUTPUT.put_line('current row number ' || cursor_update%ROWCOUNT||
          ': '|| Employee_id || ': ' || TO_CHAR (salary, '$999,999'));
	END IF;
    END LOOP;
    CLOSE cursor_update;
END;




BEGIN

   DELETE FROM EMP_TEST WHERE department_id = 20;
   DBMS_OUTPUT.PUT_LINE('Number of employees deleted: ' || TO_CHAR(SQL%ROWCOUNT));


END;

REM Q9.
DECLARE
    CURSOR cemp  IS
     	SELECT   employee_id, last_name || ', ' || first_name  AS Full_Name, salary
    	FROM     employees 
	WHERE	   department_id = 30;
    Emp_id      employees.employee_id%TYPE;
    Emp_name   	VARCHAR2(40); 	-- variable to store the value of column
    salary   	employees.salary%TYPE;
BEGIN
    OPEN cemp;
    LOOP
     	FETCH cemp INTO emp_id, Emp_name, salary; 	-- INTO list of variables
EXIT WHEN cemp%NOTFOUND;		-- Control EXIT
DBMS_OUTPUT.put_line 
 ('current row number is '|| cemp%ROWCOUNT ||   ':  ' ||
 emp_name || ': ' ||TO_CHAR (salary, '$999,999'));
    END LOOP;
    CLOSE cemp;
END;


REM HW3.
REM Q1.

--original code
DECLARE
    CURSOR c  IS
     	SELECT   last_name ||', ' || first_name Full_name, salary, 
               department_ID
    	FROM     employees 
      WHERE	   salary < 2500  
    	ORDER BY salary DESC;
    Emp_Name   varchar2 (46); 	
    sal   	   employees.salary%TYPE;
    deptid     employees.department_id%TYPE;

BEGIN
    DBMS_OUTPUT.put_line  
        (' No      Emp Full Name            Salary       Dept ID');    
    DBMS_OUTPUT.put_line  
        ('----  ----------------------    --------     ---------');    

    OPEN c;
    LOOP
     	FETCH c INTO Emp_Name, sal, deptid ; 	
      EXIT WHEN c%NOTFOUND;
       
      DBMS_OUTPUT.put_line (rpad ( c%ROWCOUNT, 7) ||
          RPAD (Emp_Name, 25) || to_char (sal, '$99,999') 
                ||'        '|| deptid);
    END LOOP;
    CLOSE c;
END;


-- for loop 
DECLARE
    CURSOR c  IS
     	SELECT   last_name ||', ' || first_name Full_name, salary, department_ID
    	FROM     employees 
      WHERE	   salary < 2500  
    	ORDER BY salary DESC;
  --  Emp_Name   varchar2 (46); 	
   -- sal   	   employees.salary%TYPE;
   -- deptid     employees.department_id%TYPE;

BEGIN
   DBMS_OUTPUT.put_line (' No      Emp Full Name            Salary       Dept ID');    
  DBMS_OUTPUT.put_line('----  ----------------------    --------     ---------');    

    FOR indx in c LOOP
     	
       
      DBMS_OUTPUT.put_line ( c%ROWCOUNT || '        '||
         RPAD(indx.Full_name,25) || to_char (indx.salary, '$99,999') 
                || '        '|| indx.department_ID);
    END LOOP;

END;

REM Q2.
DESCRIBE employees;
DECLARE
    CURSOR c  IS
     	SELECT   EMPLOYEE_ID, salary, commission_pct 
    	FROM     employees 
        WHERE	   department_id = 80;
    signle_bonus   employees.salary%TYPE;	
    bonus_total  	   employees.salary%TYPE := 0;


BEGIN
 
    FOR indx in c LOOP
      
 
        IF indx.commission_pct >= 0.25 THEN 
             IF indx.salary >= 10000 then signle_bonus := 1000;
             ELSIF indx.salary >= 7000  and indx.salary  < 10000 then signle_bonus := 800;
             ELSIF indx.salary < 7000 then signle_bonus := 600;
             END IF;
        ELSIF indx.commission_pct < 0.25 AND indx.commission_pct >= 0.15 THEN
             IF indx.salary >= 10000 then signle_bonus := 700;
             ELSIF indx.salary >= 7000  and indx.salary  < 10000 then signle_bonus := 600;
             ELSIF indx.salary < 7000 then signle_bonus := 500;
             END IF;
        ELSE 
             signle_bonus := 450;
        END IF;
        
        bonus_total := bonus_total + signle_bonus;
        signle_bonus :=0;
             
       
      
    END LOOP;
    
    DBMS_OUTPUT.put_line ( 'The total amount of the bonuses is :'|| to_char (bonus_total, '$99,999') );

END;

REM Q3.
Column table_name format A25
Column column_name format A25
Column data_type format A15


DECLARE 
      CURSOR c1 ( owner_in IN varchar2, table_in IN varchar2) IS
          select column_name, data_type, data_length 
          from   all_tab_columns
          where  owner = owner_in and table_name = table_in;
 
          
BEGIN 
      -- retrieve from employees
      DBMS_OUTPUT.PUT_LINE('-------------------------------' );
      DBMS_OUTPUT.put_line ('In table EMPLOYEES: ');
      FOR dummy_indx in c1 (USER, 'EMPLOYEES') LOOP
    
      
      DBMS_OUTPUT.put_line ( 'Column name: '|| dummy_indx.column_name );
      DBMS_OUTPUT.put_line('Data type: ' || dummy_indx.data_type);
      DBMS_OUTPUT.PUT_LINE('The length of data is :' || dummy_indx.data_length );
      
      END LOOP;
      DBMS_OUTPUT.PUT_LINE('-------------------------------' );

      -- retrieve from departments
      DBMS_OUTPUT.put_line ('In table DEPARTMENTS: ');
      FOR dummy_indx in c1 (USER, 'DEPARTMENTS') LOOP
    
      
      DBMS_OUTPUT.put_line ( 'Column name: '|| dummy_indx.column_name );
      DBMS_OUTPUT.put_line('Data type: ' || dummy_indx.data_type);
      DBMS_OUTPUT.PUT_LINE('The length of data is :' || dummy_indx.data_length );
      
      END LOOP;
      
  
      
END; 

REM Q4.

DECLARE
     CURSOR cursor_update IS 
     SELECT employee_id, salary, Department_id,  COMMISSION_PCT         -- In simple case only one table 
        FROM employees
        FOR UPDATE OF salary; -- With FOR UPDATE OF request
        
        old_salary    employees.salary%TYPE;
        new_salary    employees.salary%TYPE;
        Emp_id  employees.employee_id%TYPE;
        Dept_id employees.department_id%TYPE;
        COMMISSION employees.COMMISSION_PCT%TYPE;

BEGIN
    DBMS_OUTPUT.put_line( ' ----------------------');
OPEN cursor_update;
    LOOP
     	FETCH cursor_update INTO Emp_id, old_salary, Dept_id,COMMISSION;
        EXIT WHEN cursor_update%NOTFOUND;
	IF old_salary <= 2450 and commission IS NULL  THEN
		new_salary := old_salary * 1.1;
        UPDATE employees 
		SET salary = new_salary 
            WHERE employee_id = Emp_id;

        
	   DBMS_OUTPUT.put_line('Employee ID:' || Emp_id || ' updated salary' || TO_CHAR (new_salary, '$999,999') || ' old salary: ' || TO_CHAR (old_salary, '$999,999'));
	END IF;
    END LOOP;
    CLOSE cursor_update;
END;
rollback;  

--set serveroutput on

REM Q5.
DECLARE 

TYPE empcurtyp IS REF CURSOR RETURN employees%ROWTYPE; 
Emp_curvar empcurtyp;
deptid     employees.department_id%TYPE :=30;
--emp_id     employees.employee_id%TYPE;
--fname      employees.first_name%TYPE;
--lname  	   employees.last_name%TYPE;
v_employees  employees%ROWTYPE; 
BEGIN
        OPEN Emp_curvar FOR
            SELECT * --employee_id, first_name, last_name  
            FROM employees
            WHERE department_id = deptid
            ORDER BY last_name;
        LOOP 
             FETCH Emp_curvar INTO v_employees;
            EXIT WHEN Emp_curvar%NOTFOUND;
            DBMS_OUTPUT.put_line('Employee ID:' || v_employees.employee_id || ' First name:' || RPAD(v_employees.first_name,15) || ' Last name:' || RPAD(v_employees.last_name,15) );
        END LOOP;
        CLOSE Emp_curvar;
        DBMS_OUTPUT.PUT_LINE('-------------------');
        OPEN EMp_curvar FOR 
            SELECT *  FROM employees
            WHERE commission_pct is null and salary > 15000
            ORDER BY employee_id ;
        LOOP 
             FETCH Emp_curvar INTO v_employees;
            EXIT WHEN Emp_curvar%NOTFOUND;
            DBMS_OUTPUT.put_line('Employee ID:' || v_employees.employee_id || ' First name:' || RPAD(v_employees.first_name,15) 
            || ' Last name:' || RPAD(v_employees.last_name,15) || ' Salary: ' || to_char(v_employees.salary, '$99,999'));
        END LOOP;

        CLOSE Emp_curvar;
END;


REM. HW4
REM. Q4
DECLARE 
Exceed_Limit   EXCEPTION;	 -- declare exception with name Exceed_Limit   
PRAGMA EXCEPTION_INIT (Exceed_Limit , -20000);
x number :=1;

BEGIN
   

   LOOP
      DBMS_OUTPUT.PUT_LINE('x =' || TO_CHAR(x));
      x := x + 2;           -- manage the counter
      IF x > 10 THEN 
          RAISE_APPLICATION_ERROR (-20000, 'x is greater than 10.');
					-- instead of "RAISE” 
      END IF;
    
END LOOP;
EXCEPTION
	  WHEN Exceed_Limit    THEN 			-- handle exception
	  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20000)));
END;

REM Q4.

DECLARE
TYPE empcurtyp IS REF CURSOR RETURN employees%ROWTYPE; 
Emp_curvar empcurtyp; 
v_employees  employees%ROWTYPE;

Sal_Below_Min   EXCEPTION;	 -- declare exception with name Exceed_Limit   
PRAGMA EXCEPTION_INIT (Sal_Below_Min , -20001);

BEGIN
OPEN Emp_curvar FOR
            SELECT *
            FROM Employees
            WHERE job_id = 'IT_PROG';
     LOOP
     BEGIN
        FETCH Emp_curvar INTO v_employees;
            EXIT WHEN Emp_curvar%NOTFOUND;
        IF v_employees.salary<5000 THEN
             RAISE_APPLICATION_ERROR (-20001, 'The salary of the following employee is less than $5,000.');
					-- instead of "RAISE” 
        END IF;
        
        EXCEPTION
	  WHEN Sal_Below_Min    THEN 			-- handle exception
	  DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20001)));
      DBMS_OUTPUT.put_line('Employee ID:' || v_employees.employee_id || '  Salary is:' || to_char(v_employees.salary,'$999,999.99'));
      END;
    END LOOP;
 CLOSE Emp_curvar;
    
END;


REM Q5.
DROP TABLE log_error; -- in case you have that table created, otherwise ignore this.

CREATE TABLE log_error (
  Occur_date  DATE DEFAULT SYSDATE,
  Username    VARCHAR2 (15) DEFAULT USER,
  Err_code    NUMBER,
  Err_msg     VARCHAR2 (255));


  --  ** Note, we can use "SYSDATE" for Occur_date, "USER"  for username.
Declare 
   empno   number (6)  := 104;  
   v_code 	NUMBER;
   v_errm 	VARCHAR2(64);


BEGIN
   BEGIN
      delete from employees where employee_id = empno;

     EXCEPTION
         

         WHEN OTHERS THEN
           v_code := SQLCODE;
           v_errm := SUBSTR(SQLERRM, 1, 64); -- returns substring from 1st of length 64 
           DBMS_OUTPUT.PUT_LINE ('This Exception Error Code = ' ||
              TO_CHAR(v_code) ||'; Error Message: '|| v_errm);
            
            INSERT INTO log_error(Err_code,Err_msg) VALUES(v_code,v_errm);
        End;
        
    empno := 123;
  BEGIN
   delete from employees where employee_id = empno ;

   EXCEPTION
      WHEN OTHERS THEN
        v_code := SQLCODE;
        v_errm := SUBSTR(SQLERRM, 1, 64); -- returns substring from 1st of length 64 
        DBMS_OUTPUT.PUT_LINE ('This Exception Error Code = ' ||
              TO_CHAR(SQLCODE) ||'; Error Message: '|| SQLERRM);
        ROLLBACK;
    INSERT INTO log_error(Err_code,Err_msg) VALUES(v_code,v_errm);
  END;

END;
ROLLBACK;




SELECT * FROM employees where employee_id = 123;

SELECT * FROM log_error;



REM. Midterm
REM. Q1 basic loop
DECLARE
     str  varchar2 (80);
BEGIN
   FOR i IN 1 .. 9 LOOP    -- outer loop 
      
      FOR j IN 1 .. 9 LOOP      -- inner loop 
         str := str || '  ' ||  i || j  ;
      END LOOP;                  -- end of inner loop
   
      DBMS_OUTPUT.PUT_LINE ( '|' || str ||' |' );
                                  -- print out one line 
      str := null;     -- re-set the line to null for next line/next i 
   END loop;
END;



DECLARE
     str  varchar2 (80);
     x NUMBER := 1;
     y NUMBER := 1;
BEGIN
   LOOP     -- outer loop 
      LOOP     -- inner loop 
         str := str || '  ' ||  x || y  ;
         EXIT WHEN y > 8;   
         y := y+1;
       END LOOP;                  -- end of inner loop
   
      DBMS_OUTPUT.PUT_LINE ( '|' || str ||' |' );
                                  -- print out one line 
      str := null;     -- re-set the line to null for next line/next i 
      y :=1;
   EXIT WHEN x > 8 ;   
         x := x+1;
   END LOOP;                  -- end of outer loop
END;

REM Q2
DECLARE
    min_sal   	NUMBER;
    CURSOR cemp  IS
     	SELECT   employee_id, last_name || ', ' || first_name  AS Full_Name, salary
    	FROM     employees 
	WHERE	   salary <min_sal;
    Emp_id      employees.employee_id%TYPE;
    Emp_name   	VARCHAR2(40); 	-- variable to store the value of column
    salary   	employees.salary%TYPE;
BEGIN
    min_sal := 2600;
    DBMS_OUTPUT.put_line('The employee whose salary is less than ' || TO_CHAR(min_sal,'$999,999') || ':');
    OPEN cemp;
    LOOP
     	FETCH cemp INTO emp_id, Emp_name, salary; 	-- INTO list of variables
EXIT WHEN cemp%NOTFOUND;		-- Control EXIT
DBMS_OUTPUT.put_line 
 ('current row number is '|| RPAD(cemp%ROWCOUNT,3) ||   ':  ' ||
 RPAD(emp_name,25) || ': ' ||TO_CHAR (salary, '$999,999'));
    END LOOP;
    CLOSE cemp;
    DBMS_OUTPUT.put_line('------------------');
    
    min_sal := 2500;
    DBMS_OUTPUT.put_line('The employee whose salary is less than ' || TO_CHAR(min_sal,'$999,999') || ':');
    OPEN cemp;
    LOOP
     	FETCH cemp INTO emp_id, Emp_name, salary; 	-- INTO list of variables
EXIT WHEN cemp%NOTFOUND;		-- Control EXIT
DBMS_OUTPUT.put_line 
 ('current row number is '|| RPAD(cemp%ROWCOUNT,3) ||   ':  ' ||
 RPAD(emp_name,25) || ': ' ||TO_CHAR (salary, '$999,999'));
    END LOOP;
    CLOSE cemp;
END;

REM Q3
DESCRIBE employees;
DECLARE
    --emp_YEARS NUMBER(10);
    CURSOR c  IS
     	SELECT   EMPLOYEE_ID, salary, floor (months_between (sysdate, hire_date)/12) YEARS 
    	FROM     employees 
        WHERE	   department_id = 60;
    signle_bonus   employees.salary%TYPE;	
    bonus_total  	   employees.salary%TYPE := 0;
   


BEGIN
 
    FOR indx in c LOOP
      
 
        IF indx.years >= 29 THEN 
             IF indx.salary >= 8000 then signle_bonus := 3000;
             ELSIF indx.salary >= 5000  and indx.salary  < 8000 then signle_bonus := 2000;
             ELSIF indx.salary < 5000 then signle_bonus := 1500;
             END IF;
        ELSIF indx.years >= 24 AND indx.years <29 THEN
             IF indx.salary >= 8000 then signle_bonus := 2000;
             ELSIF indx.salary >= 4000  and indx.salary  < 8000 then signle_bonus := 1500;
             ELSIF indx.salary < 4000 then signle_bonus := 1000;
             END IF;
        ELSIF indx.years >= 23 AND indx.years <24 THEN
             IF indx.salary >= 7000 then signle_bonus := 1500;
             ELSIF indx.salary >= 5000  and indx.salary  < 7000 then signle_bonus := 1200;
             ELSIF indx.salary < 5000 then signle_bonus := 900;
             END IF;
        ELSE 
             signle_bonus := 500;
        END IF;
        DBMS_OUTPUT.put_line( 'ID ' || indx.EMPLOYEE_ID || ': '|| 'Years: ' || RPAD(indx.YEARS,2) || ' current salary: ' ||TO_CHAR (indx.salary, '$999,999') || ' bonus: ' || TO_CHAR (signle_bonus, '$999,999'));
        bonus_total := bonus_total + signle_bonus;
        signle_bonus :=0;
             
      
    END LOOP;
    
    DBMS_OUTPUT.put_line('----------------------------------');
    DBMS_OUTPUT.put_line ( 'The total amount of the bonuses is :'|| to_char (bonus_total, '$99,999') );

END;

REM Q4.
DROP TABLE log_error; -- in case you have that table created, otherwise ignore this.

CREATE TABLE log_error (
  Occur_date  DATE DEFAULT SYSDATE,
  Username    VARCHAR2 (15) DEFAULT USER,
  Err_code    NUMBER,
  Err_msg     VARCHAR2 (255));


  --  ** Note, we can use "SYSDATE" for Occur_date, "USER"  for username.
Declare 
   --empno   number (6)  := 104;  
   v_code 	NUMBER;
   v_errm 	VARCHAR2(64);


BEGIN
   
      INSERT INTO departments VALUES  ( 120    , 'Future'    , null    , 1700 );

     EXCEPTION
         

         WHEN OTHERS THEN
           v_code := SQLCODE;
           v_errm := SUBSTR(SQLERRM, 1, 64); -- returns substring from 1st of length 64 
           DBMS_OUTPUT.PUT_LINE ('This Exception Error Code = ' ||
              TO_CHAR(v_code) ||'; Error Message: '|| v_errm);
            
            INSERT INTO log_error(Err_code,Err_msg) VALUES(v_code,v_errm);
        
        
   
END;
ROLLBACK;

SELECT * FROM log_error;

REM Q5.
describe departments;


DECLARE 

TYPE DeptTyp IS REF CURSOR RETURN departments%ROWTYPE; 

dep_curvar DeptTyp;

v_dept  departments%ROWTYPE; 



BEGIN
        DBMS_OUTPUT.put_line('The departments that their location ID is not 1700 :' );
        OPEN dep_curvar FOR
            SELECT * 
            FROM departments
            WHERE  location_id != 1700;
        LOOP 
            FETCH dep_curvar INTO v_dept;
            EXIT WHEN dep_curvar%NOTFOUND;
            DBMS_OUTPUT.put_line('Department ID: ' || RPAD(v_dept.department_id,4) || ' name: ' || RPAD(v_dept.department_name,20) || ' Manager ID: ' || v_dept.Manager_ID);
        END LOOP;
        CLOSE dep_curvar;
        DBMS_OUTPUT.PUT_LINE('-------------------');

        DBMS_OUTPUT.put_line('The departments that has a manager assigned to it :' );
        OPEN dep_curvar FOR 
            SELECT * FROM departments
	WHERE  manager_id is NOT null ;

        LOOP 
             FETCH dep_curvar INTO v_dept;
            EXIT WHEN dep_curvar%NOTFOUND;
            DBMS_OUTPUT.put_line('Department ID: ' || RPAD(v_dept.department_id,4) || ' name: ' || RPAD(v_dept.department_name,20) || ' Manager ID: ' || v_dept.Manager_ID);
        END LOOP;

        CLOSE dep_curvar;

END;


REM  Q6

DECLARE
    TYPE Lastname_list IS Table OF employees.last_name%TYPE ;
    Lname Lastname_list := Lastname_list ();
    counter  integer := 1;
 	
    CURSOR c IS
      	SELECT 	last_name
        FROM    employees
        Where   department_id = 20 or department_id = 30;
 
BEGIN
    --1,2
     FOR indx IN c LOOP
       Lname.extend;
       Lname (counter) := indx.last_name;
      	 
       DBMS_OUTPUT.PUT_LINE (RPAD (counter, 4)|| Lname (counter));
       counter := counter + 1 ;
         END LOOP;
    -- 3
    --DBMS_OUTPUT.PUT_LINE('The current first index value is: '|| Lname.first);
    DBMS_OUTPUT.PUT_LINE('The current last index value is: '|| Lname.last);
    --DBMS_OUTPUT.PUT_LINE('Currently the number of elements is: '|| Dname.count);
    -- 4
    Lname.extend;
    Lname(counter)  := 'Lincoln' ;
    
    --DBMS_OUTPUT.PUT_LINE('After added one element, last index value is: '|| Dname.last);
    -- 5, 6    
    Lname.delete (4, 5) ;
    DBMS_OUTPUT.PUT_LINE ( ' ');
    DBMS_OUTPUT.PUT_LINE ('After deleting elements 4, 5: ' );
    DBMS_OUTPUT.PUT_LINE('The current size: '|| Lname.count );
    
    -- 7
    
    DBMS_OUTPUT.PUT_LINE ( ' ');
    DBMS_OUTPUT.PUT_LINE('After added one element, last index value is: '|| Lname.last);
    
    -- 8
    DBMS_OUTPUT.PUT_LINE ( ' ');
    DBMS_OUTPUT.PUT_LINE ('the current existing elements:' );
    
    counter := Lname.first ;
    While counter is not null loop
      DBMS_OUTPUT.PUT_LINE (RPAD (counter, 4)|| Lname (counter));
      counter := Lname.next (counter) ;
    END loop;
End;


REM A05
REM Q1

DECLARE
    TYPE	Constrnt IS RECORD
    (   T_name      varchar2 (30), -- correspondent to table_name
    const_name  varchar2 (30), -- correspondent to constraint_name
    Const_type  char (1)      -- correspondent to constraint_type 
    );
    
    Cursor c 
      IS
      select  table_name, constraint_name , constraint_type 
      from    user_constraints 
      where   upper (table_name) in ( 'EMPLOYEES' , 'DEPARTMENTS')
      order by 1;
      
      --Type  Constrnt_NT IS table of Constrnt;
      const Constrnt;
      
BEGIN
     OPEN c;
     LOOP 
            FETCH c INTO const;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.put_line('Table name: ' || RPAD(const.T_name,10)
            || ' constraint_name: '
            || RPAD(const.const_name,10)
            || ' constraint_type:' 
            || RPAD(const.Const_type,2));
        END LOOP;
        CLOSE c;
END;


REM Q2
DECLARE
    TYPE	DEPT_INFO  IS RECORD
    (   dept_id departments.department_id%type,
   dept_name departments.department_name%type, 
   total_emp integer --it should be the number ( how many) employees work in this department_id, 
   --the info should be retrieved from employees table
    );
    dept_info_var DEPT_INFO;
    Cursor c
    IS
       select e.department_id , d.department_name, count (e.employee_id) total
    from   employees e, departments d
    where  e.department_id = d.department_id and e.department_id = 60
    group by e.department_id , d.department_name;    



BEGIN
    OPEN c;
    LOOP 
       FETCH c INTO dept_info_var;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.put_line('Department ID: ' || RPAD(dept_info_var.dept_id,10)
            || ' Department Name: ' || RPAD(dept_info_var.dept_name,10) 
            || ' Total employees: ' || dept_info_var.total_emp);
    END LOOP;
    CLOSE c;
END;

REM 3.
DECLARE
    TYPE	DEPT_INFO  IS RECORD
    (   dept_id departments.department_id%type,
   dept_name departments.department_name%type, 
   total_emp integer --it should be the number ( how many) employees work in this department_id, 
   --the info should be retrieved from employees table
    );
   -- dept_info_var DEPT_INFO;
    
    Type  DEPT_INFO_NT IS table of DEPT_INFO;   
    List  DEPT_INFO_NT := DEPT_INFO_NT( ) ;       -- constructor
    
    Cursor c1 IS 
   select e.department_id , d.department_name dname, count(e.employee_id) total
    from   employees e, departments d
    where  e.department_id = d.department_id and d.manager_id is not null
    group by e.department_id, d.department_name
    order by 1;

    i  integer := 1;

    
BEGIN

    DBMS_OUTPUT.PUT_LINE 
    ('Dept ID   Dept Name          Total Emp' );
   DBMS_OUTPUT.PUT_LINE 
   ('-------  -------------------- ----------- ' );
   LIST.extend (15);

      For indx in c1 loop		-- cursor for loop
      
      LIST(i).dept_id    := indx.department_id;
      LIST(i).dept_name    := indx.dname;
      LIST(i).total_emp    := indx.total;
      i := i + 1;         
      
      END LOOP;
      
      For ind in LIST.first .. LIST.last LOOP

       DBMS_OUTPUT.put_line(RPAD(LIST(ind).dept_id, 10) 
      || RPAD(LIST(ind).dept_name, 20) 
      || LIST(ind).total_emp );
       End loop;

END;


REM Q4.
DECLARE 

    DepartmentID NUMBER := 60; 
    Dept_Head_fullname VARCHAR2(30);
   
PROCEDURE Dept_Head_Name (
    DepartmentID IN NUMBER,
    Dept_Head_fullname   OUT VARCHAR2
    )IS	var1 varchar2(30) :='error';						
    BEGIN 
         for c in ( SELECT  first_name ||' '|| last_name  as dept_headname
             FROM    employees    WHERE   employee_id = 
             (select  manager_id  from departments   where  department_id = DepartmentID))
         loop
              dbms_output.put_line(DepartmentID);
              dbms_output.put_line('full name is: '|| c.dept_headname);
              Dept_Head_fullname :=c.dept_headname;
         end loop;        
    END Dept_Head_Name;	
    
   

BEGIN
     Dept_Head_Name(DepartmentID,Dept_Head_fullname);

     DBMS_OUTPUT.PUT_LINE(Dept_Head_fullname);  
    
END;

REM Q5.
CREATE OR REPLACE PROCEDURE Dept_Head_Name (
    DepartmentID IN NUMBER,
    Dept_Head_fullname   OUT VARCHAR2
    )IS	var1 varchar2(30) :='error';						
    BEGIN 
         for c in ( SELECT  first_name ||' '|| last_name  as dept_headname
             FROM    employees    WHERE   employee_id = 
             (select  manager_id  from departments   where  department_id = DepartmentID))
         loop
              --dbms_output.put_line(DepartmentID);
              --dbms_output.put_line('full name is: '|| c.dept_headname);
              Dept_Head_fullname :=c.dept_headname;
         end loop;        
    END Dept_Head_Name;	
DECLARE 

    DepartmentID NUMBER := 60; 
    Dept_Head_fullname VARCHAR2(30);
   
BEGIN
     Dept_Head_Name(DepartmentID,Dept_Head_fullname);

     DBMS_OUTPUT.PUT_LINE(Dept_Head_fullname);  
    
END;


REM Q6.

   

DECLARE 

    Department_ID PLS_INTEGER := 60; 
    Dept_Head_fullname VARCHAR2(30);
    
    
     Cursor c1 IS 
   select e.department_id 
    from   employees e, departments d
    where  e.department_id = d.department_id and d.manager_id is not null
    group by e.department_id, d.department_name
    order by 1;
   


BEGIN
     OPEN c1;
     LOOP 
        FETCH c1 INTO Department_ID;
        EXIT WHEN c1%NOTFOUND;
        Dept_Head_Name(Department_ID,Dept_Head_fullname);

        DBMS_OUTPUT.PUT_LINE(Dept_Head_fullname);  
     END LOOP;
     CLOSE c1;
    
END;



REM HW6
REM Q1(a)
describe employees;
DECLARE 


    Salary NUMBER;
    Comm_var NUMBER;
    Bonus_var Number;
    E_ID NUMBER;
    
     Cursor c1 IS 
    select EMPLOYEE_ID
    from   employees
    where  department_id = 80;
   
PROCEDURE Emp_bonus (
    emp_ID IN NUMBER,
    Sal   OUT NUMBER,
    Comm  OUT NUMBER,
    Bonus OUT NUMBER
    )IS	--var1 varchar2(30) :='error';						
    BEGIN 
       SELECT 	salary, NVL (commission_pct, 0) comm_rate
       INTO     sal,    comm   -- sal and comm are your local variables 
       FROM     employees 
       Where    employee_ID = emp_ID;  -- emp_id or anything you declare

    IF comm >= .25 THEN			
	   IF sal >= 10000   THEN  	bonus := 1000;
	   ELSIF sal >= 7000 THEN	bonus := 800;
	   ELSE		 	  	bonus := 600;
	   END IF; 			-- end of nested IF

     ELSIF (comm < .25 and comm > 0)  THEN   
	   IF    sal >= 10000 THEN  bonus := 700;
	   ELSIF sal >= 7000  THEN  bonus := 600;
	   ELSE			    bonus := 500;
	   END IF; 
     ELSE          -- or ELSIF comm = 0 THEN
	   IF    sal >= 10000 THEN  bonus := 1500;
	   ELSIF sal >= 7000  THEN  bonus := 1200;
	   ELSE			    bonus := 1100;
	   END IF; 
     END IF;    
      
    END Emp_bonus;	
    
   
    

BEGIN
     DBMS_OUTPUT.PUT_LINE('EID   Salary       Comm     Bonus');
     DBMS_OUTPUT.PUT_LINE('----  ----------   -----    ----------');
     OPEN c1;
     LOOP 
        FETCH c1 INTO E_ID;
        EXIT WHEN c1%NOTFOUND;
        Emp_bonus(E_ID,Salary,Comm_var,Bonus_var);

        DBMS_OUTPUT.PUT_LINE(E_ID || ' ' || TO_CHAR(Salary,'$999,999.99') || '   ' 
        || RPAD(Comm_var,3) || '    ' 
        ||  TO_CHAR(Bonus_var,'$999,999.99'));  
     END LOOP;
     CLOSE c1;
END;


REM Q1(b)
CREATE OR REPLACE PROCEDURE Emp_bonus (
    emp_ID IN NUMBER,
    Sal   OUT NUMBER,
    Comm  OUT NUMBER,
    Bonus OUT NUMBER
    )IS	--var1 varchar2(30) :='error';						
    BEGIN 
       SELECT 	salary, NVL (commission_pct, 0) comm_rate
       INTO     sal,    comm   -- sal and comm are your local variables 
       FROM     employees 
       Where    employee_ID = emp_ID;  -- emp_id or anything you declare

    IF comm >= .25 THEN			
	   IF sal >= 10000   THEN  	bonus := 1000;
	   ELSIF sal >= 7000 THEN	bonus := 800;
	   ELSE		 	  	bonus := 600;
	   END IF; 			-- end of nested IF

     ELSIF (comm < .25 and comm > 0)  THEN   
	   IF    sal >= 10000 THEN  bonus := 700;
	   ELSIF sal >= 7000  THEN  bonus := 600;
	   ELSE			    bonus := 500;
	   END IF; 
     ELSE          -- or ELSIF comm = 0 THEN
	   IF    sal >= 10000 THEN  bonus := 1500;
	   ELSIF sal >= 7000  THEN  bonus := 1200;
	   ELSE			    bonus := 1100;
	   END IF; 
     END IF;    
      
END Emp_bonus;	
    
DECLARE 


    Salary NUMBER;
    Comm_var NUMBER;
    Bonus_var Number;
    E_ID NUMBER;
    
     Cursor c1 IS 
    select EMPLOYEE_ID
    from   employees
    where  department_id = 80;
   


BEGIN
     DBMS_OUTPUT.PUT_LINE('EID   Salary       Comm     Bonus');
     DBMS_OUTPUT.PUT_LINE('----  ----------   -----    ----------');
     OPEN c1;
     LOOP 
        FETCH c1 INTO E_ID;
        EXIT WHEN c1%NOTFOUND;
        Emp_bonus(E_ID,Salary,Comm_var,Bonus_var);

        DBMS_OUTPUT.PUT_LINE(E_ID || ' ' || TO_CHAR(Salary,'$999,999.99') || '   ' 
        || RPAD(Comm_var,3) || '    ' 
        ||  TO_CHAR(Bonus_var,'$999,999.99'));  
     END LOOP;
     CLOSE c1;
END;

REM Q1(c)
CREATE OR REPLACE FUNCTION F_Emp_Bonus
    ( emp_ID IN NUMBER)
    RETURN NUMBER
    IS 
     Bonus NUMBER;
     salary NUMBER;
     comm_rate NUMBER;
    
    
    BEGIN 

       SELECT 	salary, NVL (commission_pct, 0) comm_rate
       INTO     salary,comm_rate   -- sal and comm are your local variables 
       FROM     employees 
       Where    employee_ID = emp_ID;  -- emp_id or anything you declare

    IF comm_rate >= .25 THEN			
	   IF salary >= 10000   THEN  	bonus := 1000;
	   ELSIF salary >= 7000 THEN	bonus := 800;
	   ELSE		 	  	bonus := 600;
	   END IF; 			-- end of nested IF

     ELSIF (comm_rate < .25 and comm_rate > 0)  THEN   
	   IF    salary >= 10000 THEN  bonus := 700;
	   ELSIF salary >= 7000  THEN  bonus := 600;
	   ELSE			    bonus := 500;
	   END IF; 
     ELSE          -- or ELSIF comm = 0 THEN
	   IF    salary >= 10000 THEN  bonus := 1500;
	   ELSIF salary >= 7000  THEN  bonus := 1200;
	   ELSE			    bonus := 1100;
	   END IF; 
     END IF; 
    
    RETURN Bonus;
    END F_Emp_Bonus;
/
    
DECLARE 


   
    Bonus_var Number;
    E_ID NUMBER;
    
    Cursor c1 IS 
    select EMPLOYEE_ID
    from   employees
    where  department_id = 80;
   


BEGIN
     DBMS_OUTPUT.PUT_LINE('EID   Bonus');
     DBMS_OUTPUT.PUT_LINE('----  ----------');
     OPEN c1;
     LOOP 
        FETCH c1 INTO E_ID;
        EXIT WHEN c1%NOTFOUND;
        Bonus_var := F_Emp_Bonus(E_ID);

        DBMS_OUTPUT.PUT_LINE(E_ID || ' ' ||  TO_CHAR(Bonus_var,'$999,999.99'));  
     END LOOP;
     CLOSE c1;
END;



REM Q2.
DECLARE 

  TYPE	E_bonus IS RECORD
    (   Emp_ID   number (6),                  -- correspondent to employee_id
        Sal      number (8, 2),             -- as salary
        Comm     number (2, 2),              -- as commission_pct
        Bonus    number (6)                   -- the result of calculated bonus
    );
    
    ebonus_var1 E_bonus;
    Emp_ID NUMBER;
    bonus NUMBER;
     salary NUMBER;
     comm_rate NUMBER;
     
     Cursor c1 IS 
    select EMPLOYEE_ID
    from   employees
    where  department_id = 80;
    
    
FUNCTION F_Emp_Bonus
    (emp_ID NUMBER)
    RETURN E_bonus
    IS 
     ebonus_var  E_bonus;
     
    
    
    BEGIN 

       SELECT 	salary, NVL (commission_pct, 0) comm_rate
       INTO     salary,comm_rate   -- sal and comm are your local variables 
       FROM     employees 
       Where    employee_ID = emp_ID;  -- emp_id or anything you declare

    IF comm_rate >= .25 THEN			
	   IF salary >= 10000   THEN  	bonus := 1000;
	   ELSIF salary >= 7000 THEN	bonus := 800;
	   ELSE		 	  	bonus := 600;
	   END IF; 			-- end of nested IF

     ELSIF (comm_rate < .25 and comm_rate > 0)  THEN   
	   IF    salary >= 10000 THEN  bonus := 700;
	   ELSIF salary >= 7000  THEN  bonus := 600;
	   ELSE			    bonus := 500;
	   END IF; 
     ELSE          -- or ELSIF comm = 0 THEN
	   IF    salary >= 10000 THEN  bonus := 1500;
	   ELSIF salary >= 7000  THEN  bonus := 1200;
	   ELSE			    bonus := 1100;
	   END IF; 
     END IF; 
    
    ebonus_var.Emp_ID := emp_ID;
    ebonus_var.Sal := salary;
    ebonus_var.comm := comm_rate;
    ebonus_var.Bonus := bonus;
    
    RETURN ebonus_var;
END F_Emp_Bonus;
    
BEGIN
     DBMS_OUTPUT.PUT_LINE('EID   Salary       Comm     Bonus');
     DBMS_OUTPUT.PUT_LINE('----  ----------   -----    ----------');
     
     
     OPEN c1;
     LOOP 
        FETCH c1 INTO Emp_ID;
        EXIT WHEN c1%NOTFOUND;
        
        ebonus_var1 :=F_Emp_Bonus(Emp_ID);
    

        DBMS_OUTPUT.PUT_LINE(Emp_ID || ' ' || TO_CHAR(ebonus_var1.Sal,'$999,999.99') || '   ' 
        || RPAD(ebonus_var1.Comm,3) || '    ' 
        ||  TO_CHAR(ebonus_var1.Bonus,'$999,999.99'));  
     END LOOP;
     CLOSE c1;
     
END;

REM Q3.

Declare
   Dpt_id    employees.department_id%TYPE := 60;
   dept_name varchar2 (30) := 'IT' ;
   Dpt_head_fname    varchar2 (47);
   
  Function Dept_Head_FName 
   ( Deptno      IN   number)
    RETURN varchar2
   IS
    Dept_Head_fullname varchar2 (47);
    
    BEGIN
    
        SELECT  first_name ||' '|| last_name  
        INTO Dept_Head_fullname
             FROM    employees    WHERE   employee_id = 
             (select  manager_id  from departments   where  department_id = Deptno); 
    RETURN Dept_Head_fullname;

   END Dept_Head_FName ;

  Function Dept_Head_FName 
   ( Dept_name     IN   varchar2)
    RETURN varchar2
   IS
    Dept_Head_fullname   varchar2 (47);
   	
   BEGIN
	 SELECT  first_name ||' '|| last_name  
     INTO Dept_Head_fullname
     FROM    employees    WHERE   employee_id = (select  manager_id  from departments   where  department_name = Dept_name); 
    RETURN Dept_Head_fullname;

   END Dept_Head_FName ;

BEGIN

    Dpt_head_fname := Dept_Head_FName(Dpt_id);
    DBMS_OUTPUT.PUT_LINE('Return from Dpt_id as an input: ' || Dpt_head_fname);
    
    
    Dpt_head_fname := Dept_Head_FName(dept_name);
    DBMS_OUTPUT.PUT_LINE('Return from dept_name as an input: ' || Dpt_head_fname);

END;



REM Q4.


DECLARE
  TYPE emp_name IS RECORD (
    f_name varchar2(20),
    l_name varchar2(25)
    );
   emp1   emp_name;
   emp2   emp_name;
   emp3   emp_name;

 FUNCTION emp_name_eq ( rec1 IN emp_name, rec2 IN emp_name)
  RETURN boolean  
     IS
  ret boolean ; 
  Begin 
     IF ( rec1.f_name =  rec2.f_name and rec1.l_name =  rec2.l_name) THEN
       ret := true;
     else 
       ret := false; 
     END IF;
     return ret;
  END emp_name_eq;

 BEGIN
 
    select first_name, last_name
    INTO emp1.f_name, emp1.l_name
    from employees
    where employee_id = 202;
    
    emp2 :=emp1;
    
    
    emp3.f_name := 'Winston';
    emp3.l_name := 'Taylor';
  
  IF emp_name_eq (emp1, emp2) THEN
     DBMS_OUTPUT.PUT_LINE('The two records emp1 '''|| emp1.f_name || 
     ' ' || emp1.l_name ||''' and emp2 '''|| emp2.f_name || ' ' || 
     emp2.l_name || ''' are same.' );
    ELSE
       DBMS_OUTPUT.PUT_LINE('The two records emp1 '''|| emp1.f_name || 
     ' ' || emp1.l_name ||''' and emp2 '''|| emp2.f_name || ' ' || 
     emp2.l_name || ''' are different.' );
  END IF;

  
  IF emp_name_eq (emp1, emp3) THEN
     DBMS_OUTPUT.PUT_LINE('The two records emp1 '''|| emp1.f_name || 
     ' ' || emp1.l_name ||''' and emp3 '''|| emp3.f_name || ' ' || 
     emp3.l_name || ''' are same.' );
  ELSE
       DBMS_OUTPUT.PUT_LINE('The two records emp1 '''|| emp1.f_name || 
     ' ' || emp1.l_name ||''' and emp3 '''|| emp3.f_name || ' ' || 
     emp3.l_name || ''' are different.' );
  END IF;
END;
/


REM HW7.
REM Q1.
--DROP TABLE Emp_stmt;
CREATE TABLE      Empl_log(
   Updated_Date	DATE default SYSDATE,
   Updated_By	Varchar2 (15) default USER,
   Action         Varchar2 (30)
);

CREATE OR REPLACE TRIGGER Empl_delete 
AFTER DELETE ON employees
BEGIN
  INSERT INTO Empl_log (Updated_date, Updated_By, Action)
    VALUES (SYSDATE, User, 'employees deleted');
END Empl_delete;
/
DELETE employees where employee_id = 105;
SELECT * FROM Empl_log;
rollback;

REM Q2
DROP TABLE Empl_Del_log;

CREATE TABLE Empl_Del_log (
   Old_Empno     number (6),
   OLD_fname   Varchar2 (20),
   OLD_lname   varchar2 (25),
   OLD_sal     number (8, 2),
   OLD_mgrno   number  (6),  
   Updated_Date	DATE,
   Updated_By	Varchar2 (15),
   Action         Varchar2 (30)
);
DESCRIBE EMPLOYEES;


CREATE OR REPLACE TRIGGER Empl_Del_Row  
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
  INSERT INTO Empl_Del_log 
    VALUES (:Old.EMPLOYEE_ID, :Old.FIRST_NAME,:Old.LAST_NAME,:OLD.SALARY,
  :OLD.MANAGER_ID, Sysdate, user, '1 row deleted.');
END Empl_Del_Row;
/
delete Employees where manager_id =  103;

SELECT * FROM Empl_Del_log;
rollback;

REM Q3.
CREATE TABLE      Dept_log(
   OLD_Deptno     number (4),
   NEW_Deptno     number (4),
   OLD_Deptname   Varchar2 (30),
   NEW_Deptname   Varchar2 (30),
   OLD_MgrID      number (6),
   NEW_MgrID      number (6),
   OLD_LocID      number (4),
   NEW_LocID      number (4),
   Updated_Date	DATE,
   Updated_By	Varchar2 (15),
   Action         Varchar2 (25)
);

--DESCRIBE departments;
CREATE OR REPLACE TRIGGER Dept_Change  
AFTER INSERT OR UPDATE OR DELETE OF  MANAGER_ID, LOCATION_ID ON departments 
FOR EACH ROW
BEGIN
    IF INSERTING THEN
         INSERT INTO Dept_log VALUES
         (:OLD.DEPARTMENT_ID, :NEW.DEPARTMENT_ID,:OLD.DEPARTMENT_NAME,:NEW.DEPARTMENT_NAME,
         :OLD.MANAGER_ID,:NEW.MANAGER_ID,:OLD.LOCATION_ID,:NEW.LOCATION_ID,
 Sysdate, user, '1 row inserted.');
    ELSIF DELETING THEN
         INSERT INTO Dept_log VALUES
         (:OLD.DEPARTMENT_ID, :NEW.DEPARTMENT_ID,:OLD.DEPARTMENT_NAME,:NEW.DEPARTMENT_NAME,
         :OLD.MANAGER_ID,:NEW.MANAGER_ID,:OLD.LOCATION_ID,:NEW.LOCATION_ID,
 Sysdate, user, '1 row deleted.');
    ELSIF UPDATING ('MANAGER_ID') THEN
         INSERT INTO Dept_log VALUES
         (:OLD.DEPARTMENT_ID, :NEW.DEPARTMENT_ID,:OLD.DEPARTMENT_NAME,:NEW.DEPARTMENT_NAME,
         :OLD.MANAGER_ID,:NEW.MANAGER_ID,:OLD.LOCATION_ID,:NEW.LOCATION_ID,
 Sysdate, user, 'MANAGER_ID changed.');
    ELSIF UPDATING ('LOCATION_ID') THEN
         INSERT INTO Dept_log VALUES
         (:OLD.DEPARTMENT_ID, :NEW.DEPARTMENT_ID,:OLD.DEPARTMENT_NAME,:NEW.DEPARTMENT_NAME,
         :OLD.MANAGER_ID,:NEW.MANAGER_ID,:OLD.LOCATION_ID,:NEW.LOCATION_ID,
 Sysdate, user, 'LOCATION_ID changed.');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Something goes wrong.');
    END IF;
END Dept_Change;
/





Column OLD_Deptname format A10
Column NEW_Deptname format A10

SELECT * from Dept_log ;

INSERT INTO departments VALUES (290, 'Test', null, 1700);

UPDATE departments set manager_id = 103   WHERE department_id = 290;
UPDATE departments set location_id = 1800 WHERE department_id = 290;

DELETE departments where department_id = 290;
SELECT * from Dept_log ;

rollback;

REM Q4.
CREATE OR REPLACE PACKAGE Pkg_Dept_Head 
IS
    Function Dept_Head_FName 
   (Deptno      IN   number)
    RETURN varchar2;
    
    Function Dept_Head_FName 
   ( Dept_name     IN   varchar2)
    RETURN varchar2;


END Pkg_Dept_Head;

/

CREATE OR REPLACE PACKAGE BODY Pkg_Dept_Head
IS                   -- just copy and paste the whole function codes
    Function Dept_Head_FName 
   ( Deptno      IN   number)
    RETURN varchar2
   IS
    Dept_Head_fullname   varchar2 (47);
   	
   BEGIN
	
    SELECT  first_name ||' '|| last_name INTO Dept_Head_fullname
    FROM    employees    WHERE   employee_id = 
    (select manager_id     from   departments   where  department_id = Deptno);
    RETURN Dept_Head_fullname;

   END Dept_Head_FName ;


  Function Dept_Head_FName 
   ( Dept_name     IN   varchar2)
    RETURN varchar2
   IS
    Dept_Head_fullname   varchar2 (47);
   	
   BEGIN
	
    SELECT  first_name ||' '|| last_name INTO Dept_Head_fullname
    FROM    employees    WHERE   employee_id = 
    (select manager_id     from   departments   
     where  upper (department_name) = upper (Dept_name));
    RETURN Dept_Head_fullname;

   END Dept_Head_FName ;
BEGIN
   null;
END Pkg_Dept_Head;
/

Declare
   Dpt_id    employees.department_id%TYPE := 60;
   dept_name varchar2 (30) := 'IT' ;
   Dpt_head_fname    varchar2 (47);
   

BEGIN
    Dpt_head_fname := Pkg_Dept_Head.Dept_Head_FName ( Dpt_id);
 
    DBMS_OUTPUT.PUT_LINE( 'For the department with ID '|| dpt_id ||':'||
       CHR (10)|| 'its dept head name is: '|| Dpt_head_fname || '.');

    Dpt_head_fname := Pkg_Dept_Head.Dept_Head_FName ( dept_name );
 
    DBMS_OUTPUT.PUT_LINE( 'For the department with name '|| Dept_name ||':'||
     CHR (10)|| 'its dept head name is: '|| Dpt_head_fname || '.');
END;


DROP TRIGGER  Dept_Change;
DROP TRIGGER  Empl_Del_Row;
DROP TRIGGER  Empl_delete;


REM. FINAL

REM Q1.

describe employees;
describe departments;
DECLARE 


    M_ID NUMBER;
    M_name VARCHAR2(30);
    E_name VARCHAR2(30);
    E_ID NUMBER;
    
     Cursor c1 IS 
    select EMPLOYEE_ID
    from   employees
    where  salary <= 2300;
   
PROCEDURE Emp_boss (
    empno IN NUMBER,
    lname   OUT VARCHAR2,
    m_id  OUT NUMBER,
    m_lname OUT VARCHAR2
    )IS	--var1 varchar2(30) :='error';						
    BEGIN 
       SELECT 	LAST_NAME, MANAGER_ID 
       INTO     lname, m_id   
       FROM     employees 
       Where    employee_ID = empno; 
       
       
       
       SELECT 	LAST_NAME
       INTO     m_lname
       FROM     employees 
       Where    employee_ID = m_id;  

       
       EXCEPTION 				   -- Exception-handling part begins
            WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE ('There is an error.');

       
    END Emp_boss;	
    
   
    

BEGIN
     DBMS_OUTPUT.PUT_LINE('E_LName        Manager_ID       M_LName');
     DBMS_OUTPUT.PUT_LINE('-------------  ----------       -------------');
     OPEN c1;
     LOOP 
        FETCH c1 INTO E_ID;
        EXIT WHEN c1%NOTFOUND;
        Emp_boss(E_ID,E_name,M_ID,M_name);
        
        
        
        DBMS_OUTPUT.PUT_LINE( RPAD(E_name,20) 
        || RPAD(M_ID,3) || '         ' 
        || RPAD(M_name,20) );  
     END LOOP;
     CLOSE c1;
END;

REM Q2.

DECLARE 


    SAL NUMBER;
    L_name VARCHAR2(30);
    E_ID NUMBER :=100;
    Email_add VARCHAR2(30) :='SKING';
    
 
   
  
  PROCEDURE Emp_data ( 
    id_in IN NUMBER,
    lastname    OUT VARCHAR2,
    salary  OUT NUMBER 
    )IS						
    BEGIN 
       SELECT 	LAST_NAME, SALARY 
       INTO     lastname, salary   
       FROM     employees 
       Where    employee_ID = id_in; 
       
       EXCEPTION 				   -- Exception-handling part begins
            WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE ('There is an error.');    
    END Emp_data;	
    
    
    PROCEDURE Emp_data (  -- overloading
    email_in IN VARCHAR2,
    lastname    OUT VARCHAR2,
    salary  OUT NUMBER 
    )IS						
    BEGIN 
       SELECT 	LAST_NAME, SALARY 
       INTO     lastname, salary   
       FROM     employees 
       Where    EMAIL = email_in;  
       
       EXCEPTION 				   -- Exception-handling part begins
            WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE ('There is an error.');    
    END Emp_data;	
   
    

BEGIN
     
     Emp_data(E_ID,L_name,SAL);
     Emp_data(Email_add,L_name,SAL);  
           
     DBMS_OUTPUT.PUT_LINE('Employee id: ' || E_ID 
     || ', ' || ', Last name: ' || L_name || ', Salary: '
     || TO_CHAR(SAL,'$999,999.99'));  
     
     DBMS_OUTPUT.PUT_LINE('Email address: ' || Email_add 
     || ', ' || ', Last name: ' || L_name || ', Salary: '
     || TO_CHAR(SAL,'$999,999.99'));  

END;


REM Q3.
describe departments;
CREATE OR REPLACE PACKAGE Pkg_EMP_info 
IS

    TYPE EMP_Name_dname  IS RECORD
    (   empno   employees.employee_id%type,                 
        full_name      employees.first_name%type,            
        dept_name    departments.DEPARTMENT_NAME%type          
    );
    
    
    Function Emp_Name_Dept 
   ( id_in     IN   number)
    RETURN EMP_Name_dname;


END Pkg_EMP_info;

/

CREATE OR REPLACE PACKAGE BODY Pkg_EMP_info
IS                   -- just copy and paste the whole function codes


  Function Emp_Name_Dept 
   ( id_in     IN   number)
    RETURN EMP_Name_dname
   IS
    EMP_INFO EMP_Name_dname;
   	
   BEGIN
	
    SELECT  first_name ||' '|| last_name
    INTO EMP_INFO.full_name
    FROM    employees    WHERE   employee_id = id_in;
    
    SELECT  department_name
    INTO EMP_INFO.dept_name
    FROM    departments    WHERE   department_id = (
    select department_Id
    FROM employees
    where employee_id = id_in);
    
    EMP_INFO.empno := id_in;
    
    RETURN EMP_INFO;

   END Emp_Name_Dept ;
   
   
BEGIN
   null;
END Pkg_EMP_info;
/



Declare
   Dpt_id    employees.department_id%TYPE := 60;
   dept_name varchar2 (30);
   e_id    employees.employee_id%TYPE := 60;
   e_info Pkg_EMP_info.EMP_Name_dname;
   
   
   Cursor c1 IS 
    select EMPLOYEE_ID
    from   employees
    where  department_id = Dpt_id;
   

BEGIN
    
    SELECT department_name
    INTO dept_name
    FROM departments
    WHERE department_id = Dpt_id;
     DBMS_OUTPUT.PUT_LINE( 'For the department with ID : '|| dpt_id || ', employees info: ');
     DBMS_OUTPUT.PUT_LINE('E_ID       Full Name               Department name');
     DBMS_OUTPUT.PUT_LINE('-------  -----------------       ---------------');
    
    
    OPEN c1;
    LOOP 
      FETCH c1 INTO e_id;
      EXIT WHEN c1%NOTFOUND;
      e_info := Pkg_EMP_info.Emp_Name_Dept(e_id);
 
    DBMS_OUTPUT.PUT_LINE( RPAD(e_info.empno,10)
       || RPAD(e_info.full_name,25) || e_info.dept_name);
    END LOOP;
    CLOSE c1;
   
END;




REM Q4.
DROP TABLE Empl_log;
CREATE TABLE Empl_log (
   Old_Empno     number (6),
   NEW_Empno     number (6),
   OLD_mgrno   number  (6),  
   NEW_mgrno     number (6),
   Updated_Date	DATE,
   Updated_By	Varchar2 (15),
   Action         Varchar2 (30)
);


CREATE OR REPLACE TRIGGER Employee_trg  
AFTER INSERT OR UPDATE OF manager_id ON employees 
FOR EACH ROW
BEGIN

  IF INSERTING THEN
    INSERT INTO Empl_log 
    VALUES (:OLD.EMPLOYEE_ID,:NEW.EMPLOYEE_ID, :OLD.MANAGER_ID,:NEW.MANAGER_ID,
   Sysdate, user, '1 row inserted.');
   ELSIF UPDATING ('MANAGER_ID') THEN 
   
      INSERT INTO Empl_log 
    VALUES (:OLD.EMPLOYEE_ID,:NEW.EMPLOYEE_ID, :OLD.MANAGER_ID,:NEW.MANAGER_ID,
   Sysdate, user, '1 row updated.');
   ELSE 
        DBMS_OUTPUT.PUT_LINE('Something goes wrong.');
    END IF;
END Employee_trg;



/
UPDATE employees set manager_id = 120 WHERE department_id = 90;
INSERT INTO employees VALUES 
(300, 'Fred', 'Adams', 'Fadams', '515.123.5555', '11-MAY-2022', 'IT_PROG', 50000, NULL, NULL, 60);
 

SELECT * FROM Empl_log;
rollback;

DROP TRIGGER Employee_trg;

delete FROM employees where employee_id = 300;



REM Q5.

DECLARE
   sqlstring VARCHAR2(1000);
   count_num number;
   m_id number :=103;
BEGIN
   sqlstring :=
     'select  count (*) from employees   where manager_id = :x'; 
             
   EXECUTE IMMEDIATE sqlstring  
   INTO count_num-- placeholder name does not matter
      USING m_id;	-- “using” clause with literal values in “execute imm ...”
     DBMS_OUTPUT.put_line('The total number of the employees with manager id '|| m_id
     || ' is : ' || count_num );
END;
/




















