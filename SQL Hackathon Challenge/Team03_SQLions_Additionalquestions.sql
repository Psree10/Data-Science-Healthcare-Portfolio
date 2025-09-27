								--Team03_SQ(L)ions_Additionalquestions

--1:Write a query to extract the delivery year and month using regular expressions, then categorize and display the expected birth season for each participant?
/* Categorizes the expected birth season based on the extracted month such as Winter, Spring, Summer & Autumn.
   Winter - December (12), January (1), February (2)
   Spring- March (3), April (4), May (5)
   Summer: June (6), July (7), August (8)
   Autumn: September (9), October (10), November (11) */

SELECT participant_id,
	   edd_v1 AS expected_due_date,
  	   regexp_replace(edd_v1::text, '^([0-9]{4})-.*$', '\1') AS delivery_year, -- Extract YEAR from edd_v1
	   regexp_replace(edd_v1::text, '[0-9]{4}-([0-9]{2})-.*$', '\1') AS delivery_month, -- Extract MONTH from edd_v1
-- Determine birth season based on extracted month
CASE
	WHEN regexp_replace(edd_v1::text, '^[0-9]{4}-([0-9]{2})-.*$', '\1') IN ('12', '01', '02') THEN 'Winter'
	WHEN regexp_replace(edd_v1::text, '^[0-9]{4}-([0-9]{2})-.*$', '\1') IN ('03', '04', '05') THEN 'Spring'
	WHEN regexp_replace(edd_v1::text, '^[0-9]{4}-([0-9]{2})-.*$', '\1') IN ('06', '07', '08') THEN 'Summer'
	WHEN regexp_replace(edd_v1::text, '^[0-9]{4}-([0-9]{2})-.*$', '\1') IN ('09', '10', '11') THEN 'Autumn'
	ELSE 'Unknown'
END AS expected_birth_season
FROM pregnancy_info ORDER BY participant_id;

--------------------------------------------------------------------------------------------------------------------------------------
--2:Display the Query Planner to determine the query execution plan to analyze how PostgreSQL performs joins across multiple table when extracting participant data with GDM?

EXPLAIN ANALYZE
SELECT d.participant_id, d.ethnicity, d.age_above_30, g.diagnosed_gdm, g.hba1c_v1
FROM demographics d
JOIN glucose_tests g ON d.participant_id = g.participant_id
WHERE g.diagnosed_gdm = 1;

--------------------------------------------------------------------------------------------------------------------------------------
--3:In Excel visualize the trend of average birth weight over time for participants diagnosed with GDM in Excel, based on data extracted from PostgreSQL?

SELECT
    DATE_TRUNC('month', pi.edd_v1) AS month,
    ROUND(AVG(io.birth_weight)::numeric, 2) AS avg_birth_weight
FROM infant_outcomes io
JOIN glucose_tests gt ON io.participant_id = gt.participant_id
JOIN pregnancy_info pi ON io.participant_id = pi.participant_id
WHERE gt.diagnosed_gdm = 1
  AND pi.edd_v1 IS NOT NULL AND io.birth_weight IS NOT NULL
GROUP BY month ORDER BY month;
-- Export the Query Result to CSV File
-- In Excel, Chart is generated with extracted data.

--------------------------------------------------------------------------------------------------------------------------------------
--4:Display participant_id and JSON object with GDM status and birth weight for the first 10 participants diagnosed with GDM?

SELECT g.participant_id,
  JSON_BUILD_OBJECT('gdm_status', g.diagnosed_gdm,
    				'birth_weight', i.birth_weight) AS gdm_birth_info
FROM glucose_tests g
JOIN infant_outcomes i ON g.participant_id = i.participant_id
WHERE g.diagnosed_gdm = 1 ORDER BY participant_id LIMIT 10;

--------------------------------------------------------------------------------------------------------------------------------------
--5:Create a PostgreSQL custom aggregate function to returns the sum of squares of glucose values for participant with GDM as 1  ?

-- Create function to calculate sum of square 
CREATE OR REPLACE FUNCTION sum_squares_state(state numeric, val numeric)
RETURNS numeric
LANGUAGE sql
AS $$
  SELECT COALESCE(state, 0) + val * val;
$$;

-- Used above transition function to create the aggregate function
CREATE AGGREGATE sum_of_squares(numeric) 
(SFUNC = sum_squares_state, STYPE = numeric, INITCOND = '0');

--Calling the aggregate function
SELECT participant_id,
	'0H_OGTT_Value' AS fasting_gloucose,
     sum_of_squares("0H_OGTT_Value"::numeric) AS sum_sq_fasting_glucose
FROM glucose_tests
WHERE diagnosed_gdm = 1 GROUP BY participant_id;

--------------------------------------------------------------------------------------------------------------------------------------
--6:Write a recursive query to calculate and display the gestational age progression in weeks for each participant starting from their first visit up to delivery?
--Used to WITH RECURSIVE function to simulate weekly gestational age and visits for all participants

WITH RECURSIVE gestational_weeks AS (
SELECT participant_id, 
	   1 AS gestational_age,  
	   1 AS visit_number,
	   (edd_v1 - INTERVAL '280 days')::DATE AS visit_date --Start from 1 week till EDD 1 
FROM pregnancy_info WHERE edd_v1 IS NOT NULL
    
UNION ALL
-- Recursive increment gestational age, visit number, and visit date weekly
SELECT participant_id, gestational_age + 1, 
	   visit_number + 1, (visit_date + INTERVAL '7 days')::DATE -- Ensure output is DATE only
FROM gestational_weeks  
WHERE gestational_age + 1 <= 40 -- Stop at full-term pregnancy
)

SELECT participant_id, gestational_age, visit_number, visit_date
FROM gestational_weeks ORDER BY participant_id, gestational_age;

--------------------------------------------------------------------------------------------------------------------------------------
--7:Write query with LEFT JOIN LATERAL to get each participant’s latest vitamin D level, including participants without biomarker data ? 

SELECT d.participant_id,
       vitd."25 OHD_V1" AS latest_25_OHD_V1,
       vitd."25 OHD_V3" AS latest_25_OHD_V3
FROM demographics d
-- All participants are included, even if they have no biomarker data with Left Join
-- LATERAL Fetches the latest vitamin D values per participant
LEFT JOIN LATERAL (
SELECT b."25 OHD_V1", b."25 OHD_V3"
FROM biomarkers b
WHERE b.participant_id = d.participant_id
ORDER BY b."25 OHD_V3" DESC NULLS LAST, b."25 OHD_V1" DESC NULLS LAST
LIMIT 1) AS vitd ON TRUE
ORDER BY d.participant_id;

--------------------------------------------------------------------------------------------------------------------------------------
--8:Find all participants whose screening method contains 'OGTT' ' using REGEXP MATCHES in PostgreSQL for participate with gdm

SELECT s.participant_id, rm.screening_match
FROM screening s
JOIN glucose_tests g ON s.participant_id = g.participant_id
JOIN LATERAL 
(SELECT REGEXP_MATCHES(s.screening_method, 'OGTT') AS screening_match) rm ON TRUE
WHERE g.diagnosed_gdm = 1;
--------------------------------------------------------------------------------------------------------------------------------------
--9:Retrieve participants from the biomarkers table whose albumin level at visit1 is greater than some of those diagnosed with vitamin D deficiency

SELECT participant_id, albumin_v1
FROM biomarkers
WHERE albumin_v1 > SOME (
    SELECT albumin_v1
    FROM biomarkers
    WHERE diagnosed_with_vitd_deficiency = 1)
ORDER BY participant_id;

--------------------------------------------------------------------------------------------------------------------------------------
--10:Visualize the count of participants diagnosed with GDM grouped by birth outcome status (Still-birth from the pregnancy_info table) using a bar chart?

SELECT 
    status.still_birth,
    COUNT(g.participant_id) AS gdm_participant_count
FROM (SELECT 0 AS still_birth
UNION
SELECT 1) status
LEFT JOIN pregnancy_info p ON p."Still-birth" = status.still_birth
LEFT JOIN glucose_tests g ON p.participant_id = g.participant_id AND g.diagnosed_gdm = 1
GROUP BY status.still_birth
ORDER BY status.still_birth;

--Generate bar chart with visuliser

--------------------------------------------------------------------------------------------------------------------------------------
--11. Programmatically delete all user-defined tables along with their dependent objects from the current PostgreSQL database using a single operation?

/*In this question,
CASCADE is used to remove dependent objects like VIEWS, FUNCTIONS, FOREIGN KEYS, TRIGGERS associated with the tables.
*/

DO $$
DECLARE
    r RECORD;
BEGIN
FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
END LOOP;
END $$;

--Query to display user_defined tables in a database
SELECT tablename
FROM pg_catalog.pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema');

--------------------------------------------------------------------------------------------------------------------------------------

/*12. Create a parent table with columns participant_id and visit date and child table with column reason that inherits parent table.
Insert atleast one record to each table.Show that inherited columns are accessible from the child table? */

/*Breaking down the question,
1. Create a parent table with columns participat_id and visit_date
2. Create a child table with column reason
3. Insert atleast one record to each table.
4. Show that the inherited columns are accessible from the child table*/

-- Step1: Creating a parent table

CREATE TABLE patient_visits (
    participant_id INT,
    visit_date DATE
);

--Step2: Create child table with inheritance

CREATE TABLE visit_reason (
   reason TEXT
) INHERITS (patient_visits);

--Step2: Insert records
INSERT INTO patient_visits (participant_id, visit_date)
VALUES (1, '2025-05-19');

/*Note: 
1. The child table(visit_reason) inherits column from parent table(patient_visits)
2. visit_reason defines only one column (reason) , it inherits the columns participant_id and visit_date from patient_visits*/

INSERT INTO visit_reason (participant_id, visit_date, reason)
VALUES (2, '2025-05-18', 'Glucose Test');

--Query to show child table
SELECT * FROM visit_reason

--------------------------------------------------------------------------------------------------------------------------------------
/*13. In the maternal health dataset, each pregnancy outcome must be recorded using one of the approved delivery types 
(normal, cesarean, stillbirth, miscarriage).Prove that inserting any value outside the allowed list (e.g.home_birth) raises an error?*/

/*Breaking down the question,
1. Create delivery_types using ENUM
2. Create a table maternal_health with this ENUM
3.Insert valid values(normal, cesarean, stillbirth, miscarriage)
4.Insert invalid value(home_birth) and check the output
*/

--Step 1: Create ENUM type for delivery outcomes
CREATE TYPE type_enum AS ENUM (
    'normal','cesarean','stillbirth','miscarriage');

--Step 2: Create the maternal_health table with this ENUM
CREATE TABLE maternal_health (
    participant_id INT,
    delivery_tye type_enum
);

--Step 3: Insert valid values
INSERT INTO maternal_health (participant_id, delivery_tye)
VALUES(1, 'normal'),(2, 'cesarean'), (3, 'miscarriage');

--Step 4:  Insert invalid value
--Since ENUM is used, this will strictly enforces delivery_type must be one of the ENUM values.
INSERT INTO maternal_health (participant_id, delivery_tye)
VALUES (4, 'home_birth');

--------------------------------------------------------------------------------------------------------------------------------------
/*14. Create a table with necessary type to store participant_id, visit_date, and a grouped field that holds both 
systolic and diastolic values.Demonstrate the structure by inserting one sample record?*/

/*Breaking down the question,
1. Create composite type for systolic and diastolic field
2. Create the table using the created type
3. Insert a sample record 
4. Display the result */

--Note: Composite Type is used to create a custom type which can group related data to one logical unit

	--Step 1:Creating composite type
	CREATE TYPE sys_dias_value AS (
	    systolic INT,
	    diastolic INT
	);
	
	--Step 2: Creating table using 'sys_dias_value' type
	CREATE TABLE participant_visit (
	    participant_id INT,
	    visit_date DATE,
	    systolic_diastolic sys_dias_value
	);
	
	--Step 3: Inserting a record
	INSERT INTO participant_visit (participant_id, visit_date, systolic_diastolic)
	VALUES (1, '2025-05-19', (120, 80));
	
	--Step 4: Display the output
	SELECT * FROM participant_visit
	
--------------------------------------------------------------------------------------------------------------------------------------
--15.What is the average hemoglobin change (%) among participants who received nutritional counseling? 

SELECT 
ROUND(AVG(b.hb_change_percent)::numeric, 2) AS avg_hb_change_percent
FROM demographics d
JOIN biomarkers b ON d.participant_id = b.participant_id
WHERE d.nutritional_counselling = 1
AND b.hb_change_percent IS NOT NULL;



--------------------------------------------------------------------------------------------------------------------------------------
--16. Create a domain positive_int and use it in a table for tracking blood test results that must always be non-negative

--Step 1: Create a Domain positive_int

/* Note: This creates custom data type from the existing data type(INT,TEXT,DATE..) with
validation rules(values inserted must be greater than or equal to). If the custom data type(domain) 
is used in any table the same constraint is automatically enforced*/

CREATE DOMAIN positive_int AS INT
CHECK (VALUE >= 0);

--Step 2: Create a table using the DOMAIN
CREATE TABLE blood_test (
    participant_id INT,
    test_date DATE,
    glucose_level positive_int
);

--Step 3: Insert values to 
INSERT INTO blood_test(participant_id, test_date, glucose_level)
VALUES (1, '2025-05-19', -50); 

--------------------------------------------------------------------------------------------------------------------------------------
--17. Demonstrate how to display the inserted values in a table immediately after insertion without 
--writing separate SELECT query in documentation_track table.

INSERT INTO documentation_track(participant_id, date_form_signed, withdrew_after_28_weeks,withdrew_before_28_weeks)
VALUES (600, '2025-05-19', 0,1)
RETURNING *;

--------------------------------------------------------------------------------------------------------------------------------------
--18. Find participants who were diagnosed with GDM  but did not receive nutritional counselling ?

--Note: EXCEPT operator removes participants who did receive nutritional counselling = 1.

SELECT participant_id
FROM glucose_tests
WHERE diagnosed_gdm = 1

EXCEPT

SELECT participant_id
FROM demographics
WHERE nutritional_counselling = 1;
--------------------------------------------------------------------------------------------------------------------------------------
--19. Do babies born to GDM mothers have lower birth weights on average?

SELECT 
    gt.diagnosed_gdm,
COUNT(*) AS total_births,
    ROUND(AVG(io.birth_weight)::numeric, 2) AS avg_birth_weight
FROM glucose_tests gt
JOIN infant_outcomes io
ON gt.participant_id = io.participant_id
WHERE io.birth_weight IS NOT NULL
GROUP BY gt.diagnosed_gdm;

/*Note: From the result, On average GDM mothers have lower birth weights
Mothers with GDM	 = 3.42(avg_birth weight)
Mothers without GDM  = 3.54(avg_birth weight)
*/

--------------------------------------------------------------------------------------------------------------------------------------
--20. Display the number of SCBU admissions among mothers who received glucose-lowering therapy and those who did not.

SELECT 
CASE 
WHEN g.glucose_lowering_therapy = 1 THEN 'Therapy Given'
WHEN g.glucose_lowering_therapy = 0 THEN 'No Therapy'
END AS therapy_status,
COUNT(*) FILTER (WHERE m.scbu = 1) AS scbu_admission
FROM glucose_tests g
JOIN maternal_health_info m ON g.participant_id = m.participant_id
WHERE g.glucose_lowering_therapy IS NOT NULL
AND m.scbu IS NOT NULL
GROUP BY g.glucose_lowering_therapy;

--------------------------------------------------------------------------------------------------------------------------------------
--Q21. Create a unique index on the Participant_ID column to ensure no duplicate participant IDs are allowed.

create unique index idx_unique_participantid
on documentation_track(Participant_id);

--------------------------------------------------------------------------------------------------------------------------------------
/*--Q22. Write a SQL query to assign a rank to each participant based on their earliest date_form_signed.  
Participants with the same earliest date should have the same rank. */

Select 
participant_id,
date_form_signed,
dense_rank() over(order by date_form_signed) as signing_rank
from documentation_track;

--------------------------------------------------------------------------------------------------------------------------------------
/*-- Q23. Generate a unique visit code by combining: 
'GA' (prefix for gestational age), 
The padded participant ID, 
The padded gestational age at visit. */

select 
participant_id,
gestational_age_v1,
'GA'|| lpad(cast(participant_id as text), 6, '0')|| '_' || Lpad(cast(gestational_age_v1 as text), 2, '0') as visit_code
from pregnancy_info;
--------------------------------------------------------------------------------------------------------------------------------------
/*--Q24. Create a formatted display column where the edd_estimation_method is right-padded with star (*) 
so that the total length of the string becomes 6 characters.*/

select
participant_id,
edd_estimation_method,
rpad(edd_estimation_method,6, '*') as formatted_method
from
pregnancy_info;

--------------------------------------------------------------------------------------------------------------------------------------
--Q25. Calculate how many days early or late each participant delivered relative to their edd_v1.

select 
participant_id,
edd_v1,
ga_delivery,
(edd_v1 - Interval '40 weeks'):: date as pregnancy_start_date,
((edd_v1 - Interval '40 weeks') + (ga_delivery || ' weeks') :: interval):: date as simulated_delivery_date
from
pregnancy_info;

--------------------------------------------------------------------------------------------------------------------------------------
-- Q26. For each participant diagnosed with GDM, what is the sequence of insulin/metformin therapies recorded across their glucose tests?

select
participant_id,
string_agg(insulin_metformnin, '->' order by "0H_OGTT_Value") as therapy_sequence
from glucose_tests
where diagnosed_gdm = 1 AND insulin_metformnin is not null
group by participant_id;

--------------------------------------------------------------------------------------------------------------------------------------
-- Q27. Find the average number of diagnosed GDM cases per quarter, based on the EDD date.

select 
(date_trunc('quarter', p.edd_v1):: date) as edd_quarter,
count(*) filter (where g.diagnosed_gdm = 1) as gdm_cases
from pregnancy_info p
join glucose_tests g
on p.participant_id = g.participant_id
where 
p.edd_v1 is not null
group by 
date_trunc('quarter', p.edd_v1)
order by edd_quarter;

--------------------------------------------------------------------------------------------------------------------------------------

/*--Q28. In the infant_outcomes table, which column consumes the most storage space per row on average?
Calculate and compare the average size in bytes of each column. */

select
column_name,
avg(size) as avg_column_size_bytes
from
infant_outcomes,
lateral(
values
(participant_id, pg_column_size(participant_id)),
(apgar_1_min, pg_column_size('apgar_1_min')),
(apgar_3_min, pg_column_size('apgar_3_min')),
(birth_injury_fracture, pg_column_size('birth_injury_fracture')),
("Fetal hypoglycaemia 10", pg_column_size("Fetal hypoglycaemia 10")),
("Fetal jaundice 10", pg_column_size("Fetal jaundice 10"))
)
as sizes (column_name, size)
group by column_name
order by avg_column_size_bytes desc;

--------------------------------------------------------------------------------------------------------------------------------------

--Q29. Find all participants whose BMI is greater than any participant who smokes.

select
participant_id,
bmi_kgm2_v1
from demographics
where bmi_kgm2_v1 > any (select bmi_kgm2_v1 from demographics where smoking = 'Current');

--------------------------------------------------------------------------------------------------------------------------------------
/*--Q30. Find participants who are either current or former 
smokers and whose infants had a birth weight less than 5.5 pounds. */

select
participant_id
from demographics
where smoking = 'Ex' OR smoking = 'Current'

Intersect

select
participant_id
from infant_outcomes
where birth_weight <5.5;

--------------------------------------------------------------------------------------------------------------------------------------
--31. Create a table to store abbreviations of medical terms used in the gdm database and Capitalize the initial letter. 

--Note: Abbreviations of all medical terms have been taken from the current gdm database
CREATE TABLE gdm_abbreviations(
Id SERIAL PRIMARY KEY,
Medical_Abbreviated VARCHAR(10),
Medical_Fullform VARCHAR(255)
);
INSERT INTO gdm_abbreviations (Medical_Abbreviated, Medical_Fullform)
VALUES
('GDM', INITCAP('gestational diabetes mellitus')),
('BMI', INITCAP('Body Mass Index')),
('OHD', INITCAP('Hydroxy Vitamin D'));

SELECT * FROM gdm_abbreviations;
--------------------------------------------------------------------------------------------------------------------------------------
--32. Replace the abbreviated term with full form of medical terms from the gdm dataset.

/*Note: Table is created again and values are inserted to execute this question independently
		 Abbreviations of all medical terms have been taken from the current gdm database*/

CREATE TABLE gdm_abbreviations1(
Id SERIAL PRIMARY KEY,
Medical_Abbreviated VARCHAR(10),
Medical_Fullform VARCHAR(255)
);
INSERT INTO gdm_abbreviations1 (Medical_Abbreviated, Medical_Fullform)
VALUES
('GDM', INITCAP('gestational diabetes mellitus')),
('BMI', INITCAP('Body Mass Index')),
('OHD', INITCAP('Hydroxy Vitamin D'));
 
UPDATE gdm_abbreviations1
SET Medical_Abbreviated = REPLACE(Medical_Abbreviated, 'GDM', 'Gest_Diab')
WHERE Medical_Abbreviated = 'GDM';

SELECT * FROM gdm_abbreviations1;
--------------------------------------------------------------------------------------------------------------------------------------
--33. Find greatest and lowest value of hba1c from all the visits 
SELECT participant_id, hba1c_v1, hba1c_v2, hba1c_v3,
GREATEST (hba1c_v1, hba1c_v2, hba1c_v3) AS highest_hbA,
LEAST(hba1c_v1, hba1c_v2, hba1c_v3) AS least_hbA
FROM glucose_tests
ORDER BY participant_id;

--------------------------------------------------------------------------------------------------------------------------------------
--34. Use REPEAT() in the table to repeat the description of the medical term 

/*Note: Table is created again and values are inserted to execute this question independently
		 Abbreviations of all medical terms have been taken from the current gdm database*/
CREATE TABLE gdm_abbreviations3(
Id SERIAL PRIMARY KEY,
Medical_Abbreviated VARCHAR(10),
Medical_Fullform VARCHAR(255)
);
INSERT INTO gdm_abbreviations3 (Medical_Abbreviated, Medical_Fullform)
VALUES
('GDM', INITCAP('gestational diabetes mellitus')),
('BMI', INITCAP('Body Mass Index')),
('OHD', INITCAP('Hydroxy Vitamin D'));

SELECT REPEAT(medical_fullform, 2) AS repeated_term
FROM gdm_abbreviations3;

--------------------------------------------------------------------------------------------------------------------------------------
--35. Display the Substring from the medical description.

/*Note: Table is created again and values are inserted to execute this question independently
		 Abbreviations of all medical terms have been taken from the current gdm database*/
		 
CREATE TABLE gdm_abbreviations4(
Id SERIAL PRIMARY KEY,
Medical_Abbreviated VARCHAR(10),
Medical_Fullform VARCHAR(255)
);
INSERT INTO gdm_abbreviations4 (Medical_Abbreviated, Medical_Fullform)
VALUES
('GDM', INITCAP('gestational diabetes mellitus')),
('BMI', INITCAP('Body Mass Index')),
('OHD', INITCAP('Hydroxy Vitamin D'));

SELECT SUBSTRING(medical_fullform, 1, 7) AS medical_shortform
FROM gdm_abbreviations4;
--------------------------------------------------------------------------------------------------------------------------------------
--36. Display the size of the table in bytes.
SELECT pg_relation_size('pregnancy_info');

--------------------------------------------------------------------------------------------------------------------------------------
--37. Display the size of the table using KB, MB, GB.
SELECT pg_size_pretty(pg_total_relation_size('pregnancy_info'));

--------------------------------------------------------------------------------------------------------------------------------------
--38. Convert a given number of days into months and days.
SELECT JUSTIFY_DAYS(interval '60 days');-- It converts into months (30 days), it doesn't include hours. 

SELECT JUSTIFY_DAYS(interval '100 days');

--------------------------------------------------------------------------------------------------------------------------------------
--39. Convert a given number of hours into months, days and hours.
SELECT JUSTIFY_INTERVAL(interval '1500 hours'); --It converts into months, days and hours.

--------------------------------------------------------------------------------------------------------------------------------------
--40. Find the cumulative distribution of hba1c_v1.
--Returns the cumulative distribution, that is (number of partition rows preceding 
--or peers with current row) / (total partition rows).
--The value thus ranges from 1/N to 1. 
--Example for 1st row = 1/600 = 0.00166666666666667
SELECT participant_id, hba1c_v1, 
CUME_DIST()OVER (ORDER BY hba1c_v1)AS cumulative_distribution,
PERCENT_RANK()OVER (ORDER BY hba1c_v1)AS percent_rank
FROM glucose_tests
ORDER BY hba1c_v1;

--------------------------------------------------------------------------------------------------------------------------------------
--41.Retrieve the latest 10 rows in pregnancy info without using limit
select * from pregnancy_info
order by participant_id desc
fetch first 10 rows only

--------------------------------------------------------------------------------------------------------------------------------------
--42.create a cursor for fetching participant info mentioning with yes for the age>30 from the demographics table 
do $$
declare
    -- 1. Declare cursor for participant demographics
    participant_cursor cursor for
        select participant_id, ethnicity, age_above_30
        from demographics
        limit 5;  -- Just fetch first 5 for demonstration
    
    -- 2. Variables to hold fetched data
    p_id TEXT;
    p_ethnicity TEXT;
    p_age_above_30 BOOLEAN;
begin
    -- 3. Open the cursor
    open participant_cursor;
    
    raise notice 'Fetching participant demographics...';
    raise notice '----------------------------------';
    
    -- 4. Fetch and process rows
    loop
        fetch participant_cursor into p_id, p_ethnicity, p_age_above_30;
        exit when not found;
        
        -- Display the fetched data
        raise notice 'Participant ID: %', p_id;
        raise notice 'Ethnicity: %', p_ethnicity;
        raise notice 'Age above 30: %', 
            case when p_age_above_30 then 'Yes' else 'No' end;
        raise notice '----------------------------------';
    end loop;
    
    -- 5. Close the cursor
    close participant_cursor;
    
    raise notice 'Finished fetching participant data';
end $$;


----------------------------------------------------------------------------------------------------------------------------------------
--43. Use ntile() for the participants from demographics table based on BMI, limit 10
select 
participant_id,
bmi_kgm2_v1 as bmi,
ntile(3) over (order by bmi_kgm2_v1) as bmi_tier,
case ntile(3) over (order by bmi_kgm2_v1)
 when 1 then 'Low BMI group'
 when 2 then 'Medium BMI group'
 when 3 then 'High BMI group'
end as bmi_category
from demographics
where bmi_kgm2_v1 is not null
order by bmi_kgm2_v1
limit 10;
-------------------------------------------------------------------------------------------------------------------------------------------
--44.How would you calculate the absolute change in blood pressure between visits without using the pre-calculated change columns?
--hint use: Lag

select participant_id,
diastolic_bp_v1,
diastolic_bp_v3,
diastolic_bp_v3 - diastolic_bp_v1 as actual_change,
lag(diastolic_bp_v3 - diastolic_bp_v1, 1) over(order by participant_id)
as prev_participant_change
from vital_signs
where diastolic_bp_v1 is not null and diastolic_bp_v3 is not null


----------------------------------------------------------------------------------------------------------------------------------------
--45.calculate a 3-point moving average of systolic blood pressure (systolic_bp_v1) from the vital_signs
--table that includes each participant's value along with their immediate neighbors? 


select 
    participant_id,  
    systolic_bp_v1,
    avg(systolic_bp_v1) over (
       order by participant_id
        rows between 1 preceding AND 1 following
    ) as moving_avg_bp
from vital_signs;


----------------------------------------------------------------------------------------------------------------------------------------
--46.How would you create a JSON summary of all biomarker changes for each participant?use jsonb agg()
select 
    participant_id,
    jsonb_agg(
        json_build_object(
            'biomarker', 'ALT',
            'visit1', alt_v1,
            'visit3', alt_v3,
            'change', alt_change_percent
        )
    ) as biomarker_changes
from biomarkers
group by participant_id;
----------------------------------------------------------------------------------------------------------------------------------------
 --47.Generate a summary report showing BMI ranges and distinct age groups for each ethnicity in our patient demographics?
select 
    ethnicity,
    array_agg(distinct age_above_30) as age_groups,
    min(bmi_kgm2_v1) as min_bmi,
    max(bmi_kgm2_v1) as max_bmi
from demographics
group by ethnicity;

---------------------------------------------------------------------------------------------------------------------------------------
--48.Find the median HbA1c change percentage?
--within group enables statistical calculations like median on ordered sets.

select 
    percentile_cont(0.5) within group (order by hba1c_change_percent) as median_hba1c_change
from glucose_tests
where hba1c_change_percent is not null;
----------------------------------------------------------------------------------------------------------------------------------------
--49.Generate a report showing BMI statistics by ethnicity, with subtotals for each age group and a grand total

select 
    ethnicity,
    case when age_above_30 = 1 then 'Over 30' else '30 or under' end as age_group,
    count(*) as participants,
    avg(bmi_kgm2_v1) as avg_bmi
from demographics
group by rollup(ethnicity, age_above_30);
---------------------------------------------------------------------------------------------------------------------------------------
--50.Generate hashtext values for ethnicity, age_above_30 for demographics table
/*hashtext function that creates a 32-bit hash value (integer) from any text input. 
It's a quick way to generate a consistent numeric fingerprint for text data.*/

SELECT 
    participant_id,
    HASHTEXT(ethnicity) AS ethnicity_hash,
    HASHTEXT(age_above_30::text) AS age_hash
FROM demographics
LIMIT 5;









