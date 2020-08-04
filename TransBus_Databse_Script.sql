-- CHASSIS MODEL OBJECT

-- Creating model type.
CREATE TYPE chassis_model_type AS OBJECT(            
            chassis_model_id NUMBER(8),
            length NUMBER(8,2));
/
-- creating corresponding table 
CREATE TABLE chassis_model_table OF chassis_model_type;

-- adding primary key contraint to the chassis_id
ALTER TABLE chassis_model_table ADD CONSTRAINT chassisModelID PRIMARY KEY (chassis_model_id);
-------------------------------------------------------------------------------------

-- MODEL OBJECT

-- Creating model type.
-- model table is a super table 
CREATE TYPE model_type AS OBJECT (
    chassis_ref_id REF chassis_model_type,
    model_id NUMBER(8),
    model_name VARCHAR2(25))
    NOT FINAL;
    /
    
Drop TABLE model_table ;
-- creating corresponding table  
CREATE TABLE model_table OF model_type;
-- adding primary key contraint to the model_id
ALTER TABLE model_table ADD (CONSTRAINT modelID PRIMARY KEY (model_id)); 
------------------------------------------------------------------------------------------


-- TRUCK MODEL OBJECT

-- the following model extends model_type
-- creating truck model type
CREATE TYPE truck_model_type UNDER model_type (
    towing_capacity NUMBER(8),
    no_of_rear_axles NUMBER(2));
    /
    
 -- creating the corresponding table
CREATE TABLE truck_model_table OF truck_model_type;
-- adding primary key contraint to the model_id
ALTER TABLE truck_model_table ADD (CONSTRAINT truckModelID PRIMARY KEY (model_id)); 
-----------------------------------------------------------------------------------


-- BUS VARIANT MODEL OBJECT 

-- the following object extends model_type
-- creating bus variant model type
CREATE TYPE bus_variant_model_type UNDER model_type (
    width NUMBER(8,2),
    engine_model VARCHAR(25),
    transmission_model NUMBER(2));
    /
    
 -- creating the corresponding table
CREATE TABLE bus_variant_model_table OF bus_variant_model_type;
-- adding primary key contraint to the model_id
ALTER TABLE bus_variant_model_table ADD (CONSTRAINT busVariantModelID PRIMARY KEY (model_id)); 
-------------------------------------------------------------------------------------
      
-- ACCESSORY OBJECT

-- creating the accessories model object type
CREATE TYPE accessory_type AS OBJECT(
            bus_variant_model_ref_id REF bus_variant_model_type,
            accessory_id NUMBER(8),
            accessory_type VARCHAR2(25),
            quantity NUMBER(8));
/

-- creating corresponding table
CREATE TABLE accessory_table OF accessory_type;
-- adding primary key constraint to accessory_id
ALTER TABLE accessory_table ADD CONSTRAINT accessoryID PRIMARY KEY (accessory_id);
-----------------------------------------------------------------------------------


-- COMPANY OBJECT

-- creating the accessories model object type
CREATE TYPE company_type AS OBJECT(
            company_id NUMBER(8),
            company_name VARCHAR2(25));
/

-- creating corresponding table
CREATE TABLE company_table OF company_type;
-- adding primary key constraint to company_id
ALTER TABLE company_table ADD CONSTRAINT companyID PRIMARY KEY (company_id);

-- adding member function to display how many buses are owned by each company.

ALTER TYPE company_type
ADD MEMBER FUNCTION NoOfBuses RETURN NUMBER
CASCADE;
/

CREATE OR REPLACE TYPE BODY company_type AS
MEMBER FUNCTION NoOfBuses RETURN NUMBER IS N NUMBER;
BEGIN
SELECT COUNT(B.bus_id) INTO N FROM bus_table B WHERE B.company_ref_id.company_ID = self.company_id;
RETURN N;
END NoOfBuses;
END;
/

--------------------------------------------------------------------------------


-- BUS OBJECT

-- creating the accessories model object type
CREATE TYPE bus_type AS OBJECT(
            company_ref_id REF company_type,
            bus_variant_model_ref_id REF bus_variant_model_type,
            bus_id NUMBER(8),
            manufacturing_date DATE,
            purchase_date DATE,
            registration_no VARCHAR2(15),
            engine_no VARCHAR(25));
/

-- creating corresponding table
CREATE TABLE bus_table OF bus_type;
-- adding primary key constraint to bus_id
ALTER TABLE bus_table ADD CONSTRAINT busID PRIMARY KEY (bus_id);
--------------------------------------------------------------------------------


-- TEST INSERTION

-- inserting into chassis model
INSERT INTO chassis_model_table VALUES
            (1, 4);
            
INSERT INTO chassis_model_table VALUES
            (2, 5);
            
INSERT INTO chassis_model_table VALUES
            (3, 6);
            
INSERT INTO chassis_model_table VALUES
            (4, 4);
            
INSERT INTO chassis_model_table VALUES
            (5, 8);
            
INSERT INTO chassis_model_table VALUES
            (6, 3);

            
-- inserting into truck model table

INSERT INTO truck_model_table
            SELECT REF (c), 1, 'IVECO_587', 3000, 2
            FROM chassis_model_table c WHERE c.chassis_model_id = 2;
            
INSERT INTO truck_model_table
            SELECT REF (c), 2, 'TOYOTA_887', 4000, 1
            FROM chassis_model_table c WHERE c.chassis_model_id = 3;
            
INSERT INTO truck_model_table
            SELECT REF (c), 3, 'SCANIA_562', 8000, 2
            FROM chassis_model_table c WHERE c.chassis_model_id = 2;


-- inserting into bus variant  model table
INSERT INTO bus_variant_model_table
            SELECT REF (c), 4, 'City_5TS', 8000,'EngineModel1', 2
            FROM chassis_model_table c WHERE c.chassis_model_id = 2;
            
INSERT INTO bus_variant_model_table
            SELECT REF (c), 5, 'Rural_7EA', 4000,'EngineModel2', 1
            FROM chassis_model_table c WHERE c.chassis_model_id = 4;
            
INSERT INTO bus_variant_model_table 
            SELECT REF (c), 6, 'Interstate_534', 5000,'EngineModel2', 1
            FROM chassis_model_table c WHERE c.chassis_model_id = 6;
            


-- inserting into company table          

INSERT INTO company_table VALUES(1,'Company1');
INSERT INTO company_table VALUES(2,'Company2');
INSERT INTO company_table VALUES(3,'Company3');


-- inserting into Accessory  table
INSERT INTO accessory_table 
            SELECT REF (c), 1, 'Air Conditioner', 1
            FROM bus_variant_model_table c WHERE c.model_id = 4;
            
INSERT INTO accessory_table 
            SELECT REF (c), 2, 'Stereo', 1
            FROM bus_variant_model_table c WHERE c.model_id = 5;
            
INSERT INTO accessory_table 
            SELECT REF (c), 3, 'Sun Roof', 2
            FROM bus_variant_model_table c WHERE c.model_id = 5;
            
            
-- inserting into Bus  table
INSERT INTO bus_table 
            SELECT REF (d), REF (c), 1, TO_DATE('2000/08/20', 'yyyy/mm/dd'),TO_DATE('2014/05/15', 'yyyy/mm/dd'), 'AA456J', '112233'
            FROM bus_variant_model_table c, company_table d WHERE c.model_id = 4 AND d.company_id = 1;
            
INSERT INTO bus_table 
            SELECT REF (d), REF (c), 2,TO_DATE('2005/05/20', 'yyyy/mm/dd'),TO_DATE('2014/06/17', 'yyyy/mm/dd'), 'BB876L', '458945'
            FROM bus_variant_model_table c, company_table d WHERE c.model_id = 5 AND d.company_id = 2;
            
INSERT INTO bus_table 
            SELECT REF (d), REF (c), 3,TO_DATE('2002/07/20', 'yyyy/mm/dd'),TO_DATE('2017/04/14', 'yyyy/mm/dd'), 'AD488P', '778899'
            FROM bus_variant_model_table c, company_table d WHERE c.model_id = 6 AND d.company_id = 1;
            
INSERT INTO bus_table 
            SELECT REF (d), REF (c), 4,TO_DATE('2011/08/20', 'yyyy/mm/dd'),TO_DATE('2020/05/15', 'yyyy/mm/dd'), 'HH452O', '552211'
            FROM bus_variant_model_table c, company_table d WHERE c.model_id = 4 AND d.company_id = 3;
            
INSERT INTO bus_table 
            SELECT REF (d), REF (c), 5,TO_DATE('2005/08/17', 'yyyy/mm/dd'),TO_DATE('2018/07/17', 'yyyy/mm/dd'), 'FF789U', '447788'
            FROM bus_variant_model_table c, company_table d WHERE c.model_id = 5 AND d.company_id = 2;
            
INSERT INTO bus_table 
            SELECT REF (d), REF (c), 6,TO_DATE('2002/12/11', 'yyyy/mm/dd'),TO_DATE('2019/04/10', 'yyyy/mm/dd'), 'FS784Y', '663322'
            FROM bus_variant_model_table c, company_table d WHERE c.model_id = 6 AND d.company_id = 2;
            
                                    
-- select everything from all the tables          
SELECT * FROM chassis_model_table;

SELECT * FROM truck_model_table;

SELECT * FROM accessory_table;

SELECT *  FROM bus_table;

SELECT p.company_ref_id.company_id AS Company_ID, p.company_ref_id.company_name AS Company_Name,
p.bus_variant_model_ref_id.model_id  AS Model_ID, 
p.bus_id, p.engine_no, p.manufacturing_date, p.purchase_date, p.registration_no
FROM
bus_table p;

SELECT * FROM bus_variant_model_table;

SELECT * FROM company_table;

-- select statement to test the member function
SELECT c.NoOFBuses()AS Number_of_bus_for_companyID_1
FROM company_table c
WHERE c.company_id = 1;

SELECT c.NoOFBuses()AS Number_of_bus_for_companyID_2
FROM company_table c
WHERE c.company_id = 2;

SELECT c.NoOFBuses() AS Number_of_bus_for_companyID_3
FROM company_table c
WHERE c.company_id = 3;


-- delete every record 
DELETE FROM chassis_model_table;

DELETE FROM truck_model_table;

DELETE FROM accessory_table;

DELETE FROM bus_table;

DELETE FROM bus_variant_model_table;

DELETE FROM company_table;


desc accessory_table;
desc accessory_type;

desc bus_variant_model_table;
desc bus_variant_model_type;


desc truck_model_table;
desc truck_model_Type;

desc bus_table;
desc bus_type;

desc company_table;
desc company_type;

desc model_table;
