						--Team03_SQLions_Main80questions--

/*1. Display the duplicate participant_id and total number of duplicate records, if present in any table. 
Delete the duplicate records from that table.*/

/* Breaking down the question,
1. Display tables which has duplicate records
2. Delete the duplicate records present in any table
3. Display the table after deleting duplicate records
*/

/* In this question, 
1.format() is used to generate SQL query dynamically with the placeholders %L and %I
2.for loop is used to iterate over the array of table
3.function() is used to reuse the logic
4.%I - Idendtifiers(table names, column names, schema names, alias names)
5.%L - Literals(strings, numbers, dates)
6.Array is used to store all tables 
6.unnest() is used to convert array into rows where for loop iterates over each row */

--Step1 : Creating a reusable function to display and delete any duplicate records present in any table
CREATE OR REPLACE FUNCTION display_then_delete_duplicates()
RETURNS TABLE(tables_name TEXT, participant_id INT, total_record BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
	tbl_name TEXT;
	display_query  TEXT;
	delete_query  TEXT;

-- Displays the duplicate records if present in any table	
BEGIN
FOR tbl_name IN 
SELECT unnest(ARRAY[
	'demographics', 'biomarkers', 'body_compositions','documentation_track', 'glucose_tests', 'infant_outcomes',
	'kidney_function', 'maternal_health_info', 'pregnancy_info','screening', 'vital_signs'
     ])
LOOP
     display_query := format(
     'SELECT %L AS tables_name, participant_id::INT, COUNT(participant_id) AS total_record
      FROM %I 
	  GROUP BY participant_id
      HAVING COUNT(participant_id) > 1',
      tbl_name, tbl_name
       );
RAISE NOTICE 'Executing Display SQL Query: %', display_query ;
RETURN QUERY EXECUTE display_query;
END LOOP;

-- Delete the duplicate records if present in any table	
 FOR tbl_name IN 
 SELECT unnest(ARRAY[
	'demographics', 'biomarkers', 'body_compositions',
    'documentation_track', 'glucose_tests', 'infant_outcomes',
    'kidney_function', 'maternal_health_info', 'pregnancy_info',
    'screening', 'vital_signs'
     ])
LOOP
    delete_query := format(
    'DELETE FROM %I
     WHERE ctid NOT IN (
     SELECT MIN(ctid) FROM %I GROUP BY participant_id
     )',
     tbl_name, tbl_name
     );
RAISE NOTICE 'Executing Delete SQL Query: %', display_query ;
RAISE NOTICE 'Deleted duplicates from table: %', tbl_name;
EXECUTE delete_query ;
END LOOP;

END;
$$;

--Step 2: Execute this query to display the tables with duplicate participant_id and delete the duplicate value
SELECT * FROM display_then_delete_duplicates()
ORDER BY tables_name, participant_id ASC;

--Step 3: Query to check the table after deleting the duplicate records
SELECT 'body_compositions' AS table_name, participant_id, COUNT(*) AS total_record
FROM body_compositions
GROUP BY participant_id
ORDER BY participant_id ASC;

-- Query to  delete the FUNCTION if needed
DROP FUNCTION IF EXISTS display_then_delete_duplicates();

--------------------------------------------------------------------------------------------------------------------------------------

--2. Create a view and extract the calcium trend between the visits on gdm patients.

-- Step 1: Creating a view with inner join to create a logic for calcium trend
CREATE OR REPLACE VIEW gdm_calcium_trend AS
SELECT
    b.participant_id,
	g.diagnosed_gdm,
    b.calcium_v1,
    b.calcium_v3,
    ROUND((b.calcium_v3 - b.calcium_v1)::numeric, 3) AS calcium_change,
CASE
WHEN b.calcium_v3 > b.calcium_v1 THEN 'Increased'
WHEN b.calcium_v3 < b.calcium_v1 THEN 'Decreased'
ELSE 'No Change'
END AS calcium_trend_status
FROM
    biomarkers b
JOIN
    glucose_tests g ON b.participant_id = g.participant_id
WHERE
	g.diagnosed_gdm = 1
    AND b.calcium_v1 IS NOT NULL
    AND b.calcium_v3 IS NOT NULL;

-- Step 2: Using the view to display calcium trend
SELECT * FROM gdm_calcium_trend ORDER BY participant_id;

-- Query to delete the VIEW, if needed
DROP VIEW IF EXISTS gdm_calcium_trend;

--------------------------------------------------------------------------------------------------------------------------------------

--3. Provide the number of patients aggregated by year based on forms they signed

/*In this question, 
1.Extract() is used to extract year from date
2.COUNT() is used to return number of rows  
*/

SELECT EXTRACT(YEAR FROM date_form_signed) AS year_signed,
COUNT(participant_id) AS total_patients
FROM
    documentation_track
WHERE
    date_form_signed IS NOT NULL
GROUP BY
EXTRACT(YEAR FROM date_form_signed)
ORDER BY year_signed;

--------------------------------------------------------------------------------------------------------------------------------------

--4. Calculate % of gdm diagnosed patients whose age is above 30

/* In this question, 
1.'FILTER' is used to apply 'WHERE' clause along with aggregate function 'COUNT'.
2. Formula Used to calculate percentage is
percentage = (GDM patients with age > 30)*100÷Total GDM patients */

SELECT 
COUNT(*) AS total_gdm,
COUNT(*) FILTER (WHERE d.age_above_30 =1) AS gdm_above_30,
ROUND(
COUNT(*) FILTER (WHERE d.age_above_30 = 1) * 100.0 / COUNT(*), 2) 
AS gdm_percent_above_30
FROM 
  glucose_tests g
JOIN 
  demographics d ON g.participant_id = d.participant_id
WHERE 
  g.diagnosed_gdm = 1;

--------------------------------------------------------------------------------------------------------------------------------------

--5. Create a trigger on the Demographics table that monitors and logs all INSERT, UPDATE, and DELETE operations performed on the table.

/*Breaking down the question,
1. Create a log table to all the actions performed in 'demographics' table
2. Create the TRIGGER to do INSERT,UPDATE, DELETE actions'
3. Bind the TRIGGER with 'demographics table'
4. Write INSERT/UPDATE/DELETE query to test the TRIGGER
5. Verify the log table */

/*In this question, 
1. AFTER INSERT OR UPDATE OR DELETE TRIGGER is used to execute the trigger after actual data change taken place in 'demographics' table
2. to_jsonb(NEW) and to_jsonb(OLD) are used to convert a row into a JSONB format
3. NEW refers to the new set of data inserted/updated
4. OLD refers to the existing data before changes*/

-- Step 1: Create the log table for demographics table
CREATE TABLE demographics_log (
    log_id SERIAL PRIMARY KEY,
	action_type TEXT,    
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	user_name VARCHAR(50),
	 participant_id INT,
    old_data JSONB,
    new_data JSONB
);

-- Step 2: Create FUNCTION to update the log table on INSERT/UPDATE/DELETE actions performed on 'demographics' table
CREATE OR REPLACE FUNCTION Trigger_demographics()
RETURNS TRIGGER AS $$
BEGIN
IF TG_OP  = 'INSERT' THEN
INSERT INTO demographics_log(action_type,user_name, participant_id, new_data)
VALUES ('INSERT',CURRENT_USER,NEW.participant_id, to_jsonb(NEW));
RETURN NEW;

ELSIF TG_OP  = 'UPDATE' THEN
INSERT INTO demographics_log(action_type,user_name, participant_id, old_data, new_data)
VALUES ('UPDATE',CURRENT_USER, NEW.participant_id, to_jsonb(OLD), to_jsonb(NEW));
RETURN NEW;

ELSIF TG_OP  = 'DELETE' THEN
INSERT INTO demographics_log(action_type,user_name, participant_id, old_data)
VALUES ('DELETE',CURRENT_USER, OLD.participant_id, to_jsonb(OLD));
RETURN OLD;

END IF;
RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create and bind the TRIGGER with demographics table
CREATE TRIGGER after_action
AFTER INSERT OR UPDATE OR DELETE ON demographics
FOR EACH ROW
EXECUTE FUNCTION Trigger_demographics();

-- Step 4: Queries to test the TRIGGER
-- INSERT
INSERT INTO demographics (participant_id, ethnicity, age_above_30, height_m, bmi_kgm2_v1,smoking,alcohol_intake,family_history,highrisk,medications,nutritional_counselling)
VALUES (1000, 'Brown',1, 1.64,29.93,'Never',0,0,0,0,1);

--UPDATE
UPDATE demographics SET ethnicity ='Black' WHERE participant_id = 1000;

--DELETE
DELETE FROM demographics WHERE participant_id = 1000;

-- Step5: Query to verify log table after the TRIGGER 
SELECT * FROM demographics_log

--Query to drop the TRIGGER, if needed
DROP TRIGGER IF EXISTS after_action ON demographics;

--Query to drop the FUNCTION, if needed
DROP FUNCTION IF EXISTS Trigger_demographics();

--------------------------------------------------------------------------------------------------------------------------------------

/*6. There is a requirement to extract a list of GDM patients  Since this is very frequent extraction,
can you provide a solution to store this data for frequent usage by avoiding repetitive use of database resources .
 				Hint:No new Table creation required. */
 
-- In this question Materialized View can be used since it stores result of a query physically

-- Step 1: Creating the materialized view to extract a list of GDM patients
CREATE MATERIALIZED VIEW mat_gdm_patients AS
SELECT 
    d.participant_id,
    d.ethnicity,
	d.age_above_30,
    g.diagnosed_gdm
FROM 
    demographics d
JOIN 
    glucose_tests g ON d.participant_id = g.participant_id
WHERE 
    g.diagnosed_gdm = 1
WITH DATA;

-- Step 2: Using the view to lists the GDM patients
SELECT * FROM mat_gdm_patients ORDER BY participant_id;

-- Query to refresh the VIEW when there are changes happen in the table associated with this view
REFRESH MATERIALIZED VIEW mat_gdm_patients ;

-- Query to drop the MATERIALIZED VIEW, if needed
DROP MATERIALIZED VIEW IF EXISTS mat_gdm_patients; 

--------------------------------------------------------------------------------------------------------------------------------------

--7. Display progression/Remission of diabetes using HbA1c values in gdm patients

/*Breaking down the question,
1. First  clinical interpreting  the status from HbA1c values of visit1 and visit3
  If HbA1c < 39     then normal
  	 HbA1c	39 - 36 then prediabetes
	 HbA1c	>=48	then diabetes
2. Then determining progression/Remission/stable with interpreted results*/

/*In this question,
1. CTE is used within VIEW to interpret clinical status(normal,prediabetes,diabetes) from hba1c values for visit1 and visit3
2. VIEW uses this interpreted status to determine the diabetes trend(progression, remission, stable)*/

-- Step 1: Creating a CTE inside VIEW to calculate progression/Remission of diabetes from interpreted clinical status
CREATE OR REPLACE VIEW hba1c_trend AS
WITH hba1c_clinical_status AS (
SELECT 
    participant_id,
    diagnosed_gdm,
    hba1c_v1,
    hba1c_v2,
    hba1c_v3,

-- Clinical interpretation for Visit 1
CASE 
WHEN hba1c_v1 >= 48 THEN 'Diabetes'
WHEN hba1c_v1 BETWEEN 39 AND 47 THEN 'Prediabetes'
ELSE 'Normal'
END AS clinical_status_v1,
-- Clinical interpretation for Visit 3
CASE 
WHEN hba1c_v3 >= 48 THEN 'Diabetes'
WHEN hba1c_v3 BETWEEN 39 AND 47 THEN 'Prediabetes'
ELSE 'Normal'
END AS clinical_status_v3

FROM glucose_tests
WHERE diagnosed_gdm = 1
AND hba1c_v1 IS NOT NULL
AND hba1c_v3 IS NOT NULL
)
SELECT 
  participant_id,
  hba1c_v1,
  hba1c_v2,
  hba1c_v3,
  clinical_status_v1,
  clinical_status_v3,
-- Determine overall diabetes status like remission/progression/stable or fluctuating
CASE 
WHEN clinical_status_v1 = 'Diabetes' AND clinical_status_v3 IN ('Normal', 'Prediabetes') THEN 'Remission'
WHEN clinical_status_v1 = 'Prediabetes' AND clinical_status_v3 ='Normal' THEN 'Remission'
WHEN clinical_status_v1 = 'Normal' AND clinical_status_v3 IN ('Prediabetes','Diabetes') THEN 'Progression'
WHEN clinical_status_v1 = 'Prediabetes' AND clinical_status_v3 ='Diabetes' THEN 'Progression'
ELSE 'Stable'
END AS diabetes_clinical_status
FROM hba1c_clinical_status;

--Step 2: Using the view to display HbA1c trend(progression/Remission)
SELECT * FROM hba1c_trend WHERE diabetes_clinical_status IN ('Progression', 'Remission') ORDER BY participant_id;

--Query to drop the view, if needed
DROP VIEW IF EXISTS hba1c_trend;

--------------------------------------------------------------------------------------------------------------------------------------

--8. Calculate New Gestational Age as number of days column  using gestational_age_v1 Hint:(Gestational age is mentioned in Weeks+days)

/* In this question SPLIT_PART() is used to split the text into parts and pick a specific part
For example week+day= 12+5, It splits the text to
						week - 12
						day - 5 */ 

SELECT 
participant_id,
gestational_age_v1,
CASE 
WHEN gestational_age_v1 LIKE '%+%' THEN 
(CAST(SPLIT_PART(gestational_age_v1, '+', 1) AS INT) * 7) +
CAST(SPLIT_PART(gestational_age_v1, '+', 2) AS INT)
ELSE 
CAST(gestational_age_v1 AS INT) * 7
END AS gestational_days
FROM pregnancy_info 
ORDER BY participant_id

--------------------------------------------------------------------------------------------------------------------------------------

--9. Display participants with a significant increase (greater than 20%) in both creatinine and urine albumin levels between visit 1 and visit 3.

/* Breaking down the question,
1. Calculate change in percentage of albumin between visit 1 and visit 3, since change in albumin percent is not available in the table
2. With change in percent of both creatinine and albumin levels between visits, display significant increase(greater than 20%)*/

/* In this question, general function 'calculate_percentage_change' is created to calculate change in percentage  */

-- Step 1: Creating a general reusable function to calculate change in percentage, so wherever neccessary this function can be called.
CREATE OR REPLACE FUNCTION calculate_percentage_change(old_value NUMERIC, new_value NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
IF old_value IS NULL OR new_value IS NULL OR old_value = 0 THEN
RETURN NULL;
END IF;

RETURN ROUND(((new_value - old_value) / old_value) * 100, 2);
END;
$$ LANGUAGE plpgsql;

--Step 2: Query to display participants with a significant increase (greater than 20%) in both creatinine and urine albumin levels between visit 1 and visit 3
SELECT
  participant_id,
  creatinine_V1,
  creatinine_V3,
  "U Albumin_V1",
  "U Albumin_V3",
  creatinine_change_percent,
  --Calling reusable function to calculate change in percent between visits
  calculate_percentage_change("U Albumin_V1"::NUMERIC, "U Albumin_V3"::NUMERIC) AS albumin_change_percent
FROM
  kidney_function
WHERE
  creatinine_change_percent > 20
AND calculate_percentage_change("U Albumin_V1"::NUMERIC, "U Albumin_V3"::NUMERIC) > 20;

--Query to drop the function ,if needed
DROP FUNCTION IF EXISTS calculate_percentage_change(NUMERIC, NUMERIC);


--------------------------------------------------------------------------------------------------------------------------------------

--10. Select only odd rows from demographics table using Windows function and derived subquery

-- In this question, ROW_NUMBER() assigns a unique sequential number to each row in the result

SELECT * FROM (
SELECT *, ROW_NUMBER() OVER (ORDER BY participant_id) AS rank_rows
FROM demographics) 
AS numbered_rows
WHERE rank_rows % 2 = 1;

--------------------------------------------------------------------------------------------------------------------------------------

--11. Create a table where a column automatically populates with decrementing values. Demonstrate how the values decrease over time.

/*Breaking down the question,
1. Create a table with automatically populating column with decrementing value 	
2. Insert value with time delay
3. Display the output*/

/* In this question,
1. GENERATED ALWAYS AS is used to populate a column automatically and its value will be automatically calculated from other columns
2. Inserts 5 rows using a FOR loop, with a 3-second delay between each insert using `pg_sleep(3)`.
3. Each inserted row has,
   - A fixed base value (100),
   - An auto-decrementing value (100 - id * 5),
   - A timestamp reflecting when the row was inserted */


-- Step 1: Creating a table where a column auto populates with a decrement value logic 
CREATE TABLE decrement_table (
id SERIAL PRIMARY KEY, 
	base_value INT, 
	decrementing_value INT GENERATED ALWAYS AS (base_value - (id * 5)) STORED,
	 timestamp TIMESTAMP DEFAULT clock_timestamp());

-- Step 2: Inserting 5 rows with 3 seconds delay for each insert
DO $$
BEGIN
FOR i IN 1..5 LOOP
INSERT INTO decrement_table (base_value)
VALUES (100);  
PERFORM pg_sleep(3); 
END LOOP;
END $$;

--Step 3: Displaying the query output
SELECT * FROM decrement_table ORDER BY id;

--Query to drop the table, if needed
DROP TABLE IF EXISTS decrement_table;

--------------------------------------------------------------------------------------------------------------------------------------

--12. Create materialized view, calculate and categorize MAP for all participants. Display the ranking and analyze the distribution across MAP categories.
/*
Breaking down the Question,
1. Calculate MAP for each visit and categorize MAP for all participants
2. Displaying the category based on the calculated MAP value
3. Display Rank
4. Analyze the distribution across MAP category*/
/* In this question,
1. Formula used to calculate MAP is MAP =  (systolic+2*diastolic)/3
2. For better raking and combined analysis of both visit, null values are not excluded .  
3. CASE is used to mark the rank as 'unranked' if the calculated MAP value is Null. 
4. Because for visit 1 there are no null values but for visit 3 there are null values*/
*/

select * from vital_signs
-- Step 1: Creating MATERIALIZED VIEW to calculate MAP for each visit and categorize for all participants

CREATE MATERIALIZED VIEW map_clac_rank_analysis AS
SELECT
	participant_id,
--Calculating and categorizing MAP for visit 1
    ROUND((systolic_bp_v1 + 2 * diastolic_bp_v1) / 3.0, 2) AS map_v1,
CASE
WHEN systolic_bp_v1 IS NULL OR diastolic_bp_v1 IS NULL THEN 'Missing Value'
WHEN (systolic_bp_v1 + 2 * diastolic_bp_v1) / 3.0 < 70 THEN 'Low'
WHEN (systolic_bp_v1 + 2 * diastolic_bp_v1) / 3.0 < 100 THEN 'Normal'
WHEN (systolic_bp_v1 + 2 * diastolic_bp_v1) / 3.0 < 110 THEN 'Prehypertension'
ELSE 'Hypertension'
END AS map_category_v1,

--Calculating and categorizing MAP for visit 3
    ROUND((systolic_bp_v3 + 2 * diastolic_bp_v3) / 3.0, 2) AS map_v3,
CASE
WHEN systolic_bp_v3 IS NULL OR diastolic_bp_v3 IS NULL THEN 'Missing Value'
WHEN (systolic_bp_v3 + 2 * diastolic_bp_v3) / 3.0 < 70 THEN 'Low'
WHEN (systolic_bp_v3 + 2 * diastolic_bp_v3) / 3.0 < 100 THEN 'Normal'
WHEN (systolic_bp_v3 + 2 * diastolic_bp_v3) / 3.0 < 110 THEN 'Prehypertension'
ELSE 'Hypertension'
END AS map_category_v3
FROM vital_signs

-- Step 2: Displaying the category based on MAP value
SELECT * FROM map_clac_rank_analysis ORDER BY participant_id

--Step 3: Display rank based on MAP value on each visit 

SELECT *,
RANK() OVER (ORDER BY map_v1 DESC) AS rank_v1,
RANK() OVER (ORDER BY map_v3 DESC) AS rank_v3
FROM map_clac_rank_analysis
WHERE map_v1 IS NOT NULL AND map_v3 IS NOT NULL ORDER BY rank_v3;

-- Step4: Analyze the distribution across MAP categories
SELECT 
COALESCE(v1.map_category_v1, v3.map_category_v3) AS map_category,
    v1.participants_v1,
    v3.participants_v3
FROM
(SELECT map_category_v1, COUNT(*) AS participants_v1
FROM map_clac_rank_analysis
GROUP BY map_category_v1) v1
FULL OUTER JOIN
(SELECT map_category_v3, COUNT(*) AS participants_v3
FROM map_clac_rank_analysis
GROUP BY map_category_v3) v3
ON v1.map_category_v1 = v3.map_category_v3;

-- To refresh MATERIALIZED VIEW
REFRESH MATERIALIZED VIEW map_clac_rank_analysis;

-- To drop the MATERIALIZED VIEW
DROP MATERIALIZED VIEW IF EXISTS map_clac_rank_analysis;

--------------------------------------------------------------------------------------------------------------------------------------

--13. How many participants were admitted in the present month of any year.

SELECT TO_CHAR(CURRENT_DATE, 'Month') AS present_month,
COUNT(*) AS participants_admitted_in_present_month
FROM documentation_track
WHERE EXTRACT(MONTH FROM date_form_signed) = EXTRACT(MONTH FROM CURRENT_DATE);

--------------------------------------------------------------------------------------------------------------------------------------

--14. Generate random age  between 18 and 50 for all participants. Calculate birth year for all participants using stored procedure. 

/*Breaking down the Question,
In the stored procedure
1. Creating the temporary table to generate random age for all participants  without altering the existing table
2. Generating the random age between 18 and 50 for all participants
3. Calculating the birth year from the generated age
*/
/*In this question,
1. Formula used to calculate Random_Integer is
Random_Integer=Floor(RANDOM()×(max−min+1)+min)
2. Floor() - rounds a number down to the nearest whole integer regardless of its decimal value 
3. Temporary table within a stored procedure is created to store the result of a query for further processing */

--Step 1: Creating the stored procedure which has the logic to generate random age and extract birth year
CREATE OR REPLACE PROCEDURE generate_random_age_and_birth_year()
LANGUAGE plpgsql
AS $$
BEGIN
CREATE TEMP TABLE temp_participant_age AS
SELECT 
	participant_id,
	age,
EXTRACT(YEAR FROM CURRENT_DATE)::INT - age AS birth_year
FROM (
SELECT 
	participant_id,
FLOOR(RANDOM() * (50 - 18 + 1) + 18)::INT AS age
FROM demographics);
END;
$$;

--Step 2: Call the stored procedure to randomly generate age and extract birth year for all participants
CALL generate_random_age_and_birth_year();
;
--Step 3:Display the result of the query  
SELECT * FROM temp_participant_age ORDER BY participant_id ;

--------------------------------------------------------------------------------------------------------------------------------------

--15. Show the GDM prevalence by race.
/*Formula used to calculate gdm_prevalence is
gdm_prevalence = (Number of participants with GDM in an ethnic group/Total number of participants in that Ethnic group)*100
*/

SELECT 
    d.ethnicity,
COUNT(*) FILTER (WHERE g.diagnosed_gdm = 1) AS gdm_positive_count,
COUNT(*) AS total_participants,
	ROUND(100.0 * COUNT(*) FILTER (WHERE g.diagnosed_gdm = 1) / COUNT(*), 2)
AS gdm_prevalence
FROM 
    demographics d
INNER JOIN 
    glucose_tests g ON d.participant_id = g.participant_id
GROUP BY 
    d.ethnicity
ORDER BY 
gdm_prevalence ;

--------------------------------------------------------------------------------------------------------------------------------------

--16. Query to show total number of columns from all tables in database along with data types for each table.
-- In this question, STRING_AGG() is used to combine values from multiple rows into one string

SELECT 
    table_schema,
    table_name,
    COUNT(*) AS total_columns,
    STRING_AGG(column_name || ' (' || data_type || ')', E'\n') AS column_details
FROM 
    information_schema.columns
WHERE 
    table_schema NOT IN ('information_schema', 'pg_catalog')
GROUP BY 
    table_schema, table_name
ORDER BY 
    table_schema, table_name;

--------------------------------------------------------------------------------------------------------------------------------------

--17. "Generate a new attribute ""High risk pregnancy"" to demographics table. 

SELECT * FROM demographics;
--Adding new attribute
ALTER TABLE demographics
ADD COLUMN high_risk_pregnancy BOOLEAN DEFAULT FALSE;

--Create a trigger function to automatically populates the existing records.
--Hint: Consider age,smoking,high risk ."
CREATE OR REPLACE FUNCTION update_high_risk_pregnancy()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
--Evaluate factors age,smoking,high risk 
IF NEW.age_above_30 = 1 OR NEW.smoking = 'Current' OR NEW.highrisk = 1
THEN NEW.high_risk_pregnancy = 'True';
ELSE NEW.high_risk_pregnancy = 'False';
END IF;
RETURN NEW;
END;
$$;

--Create a trigger that automatically populates the existing records.
CREATE OR REPLACE TRIGGER high_risk_pregnancy_trigger
BEFORE INSERT OR UPDATE ON demographics
FOR EACH ROW
EXECUTE FUNCTION update_high_risk_pregnancy();

--Update the existing records
UPDATE demographics
SET high_risk_pregnancy = True
WHERE age_above_30 = 1 OR smoking= 'Current' OR highrisk = 1;
--View the records
SELECT 	age_above_30, smoking, highrisk, high_risk_pregnancy FROM demographics;

--------------------------------------------------------------------------------------------------------------------------------------

--18. Write a query to find the number of Participants by expected date of delivery month (Display with month name only)
SELECT * FROM pregnancy_info;

SELECT TO_CHAR (edd_v1, 'Month') AS Expected_Delivery_Month,
COUNT (*) AS Participants_count
FROM pregnancy_info
GROUP BY Expected_Delivery_Month
ORDER BY Participants_count;

--------------------------------------------------------------------------------------------------------------------------------------

--19. Create a view without using any schema or table and check the created view using a select statement.
CREATE VIEW hackathon_view AS
SELECT 'THIS IS SQL HACKATHON MAY 2025!' AS MESSAGE;  

SELECT MESSAGE FROM hackathon_view;

--------------------------------------------------------------------------------------------------------------------------------------

--20. Find the count of patients who have both gestational diabetes and anemia.

SELECT COUNT(*), g.diagnosed_gdm AS gestational_diabetes,
CASE  
WHEN b.hb_v1 <12 OR b.hb_v3 <12 THEN TRUE ELSE FALSE
END AS anemia
FROM glucose_tests AS g
JOIN biomarkers b ON g.participant_id = b.participant_id
WHERE diagnosed_gdm = 1
AND (b.hb_v1 <12 OR b.hb_v3 <12 )
GROUP BY gestational_diabetes, anemia; 

--------------------------------------------------------------------------------------------------------------------------------------

--21. Create a function that converts HBA1c levels from IFCC units to DCCT units, evaluates the HBA1c level during the first visit, and notifies whether it requires attention.

SELECT participant_id, hba1c_v1, hba1c_v2, hba1c_v3 FROM glucose_tests;

CREATE OR REPLACE FUNCTION evaluate_hba1c(hba1c_v1 NUMERIC)
RETURNS TABLE (dcct_value NUMERIC, requires_attention BOOLEAN)
LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY 
	SELECT ROUND(hba1c_v1/10.93 + 2.35) AS DCCT_value,
	CASE
	WHEN DCCT_value > 6.4 THEN TRUE ELSE FALSE
	END AS requires_attention;
END;
$$;

SELECT * FROM evaluate_hba1c(31);

--------------------------------------------------------------------------------------------------------------------------------------

--22. What is the most common type of anesthesia used (epidural or spinal)?

SELECT * FROM maternal_health_info;

SELECT epidural_spinal, COUNT (*) AS common_anesthesia
FROM maternal_health_info
WHERE epidural_spinal IN ('Epidural', 'Spinal')
GROUP BY epidural_spinal
ORDER BY COUNT (*) DESC;

--------------------------------------------------------------------------------------------------------------------------------------

--23. Compare the average change in weight for participants who received nutritional counseling compared to those who did not.

SELECT COUNT(*) AS participant_count, d.nutritional_counselling, 
ROUND(AVG(b.weight_change_percent)) AS avg_weight_change
FROM body_compositions b
JOIN demographics d ON b.participant_id = d.participant_id
GROUP BY d.nutritional_counselling
ORDER BY d.nutritional_counselling;

--------------------------------------------------------------------------------------------------------------------------------------

--24. Identify factors most strongly correlated with GDM diagnosis

SELECT 'age' AS factor, ROUND(CORR(g.diagnosed_gdm, d.age_above_30::INT)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN demographics d ON d.participant_id = g.participant_id 
UNION ALL

SELECT 'bmi'AS factor, ROUND(CORR(g.diagnosed_gdm, d.bmi_kgm2_v1)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN demographics d ON d.participant_id = g.participant_id 
UNION ALL

SELECT 'gct_gtt'AS factor, ROUND(CORR(g.diagnosed_gdm, g.gct_ogtt_high)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN demographics d ON d.participant_id = g.participant_id 
UNION ALL

SELECT 'hba1c'AS factor, ROUND(CORR(g.diagnosed_gdm, g.hba1c_v1)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN demographics d ON d.participant_id = g.participant_id 
UNION ALL

SELECT 'alcohol'AS factor, ROUND(CORR(g.diagnosed_gdm, d.alcohol_intake)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN demographics d ON d.participant_id = g.participant_id 
UNION ALL

SELECT 'highrisk' AS factor, ROUND(CORR(g.diagnosed_gdm, d.highrisk::INT)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN demographics d ON d.participant_id = g.participant_id 
UNION ALL

SELECT 'weight' AS factor, ROUND(CORR(g.diagnosed_gdm, b.weight_change_percent)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN body_compositions b ON b.participant_id = g.participant_id
UNION ALL

SELECT 'systolic_bp' AS factor, ROUND(CORR(g.diagnosed_gdm, v.systolic_bp_v1)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN vital_signs v ON v.participant_id = g.participant_id
UNION ALL

SELECT 'diastolic_bp'AS factor, ROUND(CORR(g.diagnosed_gdm, v.diastolic_bp_v1)::NUMERIC, 2) AS gdm_correlation
FROM glucose_tests g
JOIN vital_signs v ON v.participant_id = g.participant_id
ORDER BY gdm_correlation DESC;

--------------------------------------------------------------------------------------------------------------------------------------

--25. Create a User 'GDM_Read'.GDM_Read has to access only First 100 participants and their details without seeing their Race. (Hint : No table creation)
CREATE USER GDM_Read WITH PASSWORD 'SQLHackathon';--user created

SELECT * FROM demographics

--Create a view with restriction
CREATE VIEW GDM_limited_access AS
SELECT participant_id, age_above_30, height_m, bmi_kgm2_v1, smoking, alcohol_intake, 
family_history, highrisk, medications, nutritional_counselling, high_risk_pregnancy
FROM demographics --All column names except 'ethnicity'
ORDER BY participant_id
LIMIT 100;

--Grant access on view only
GRANT SELECT ON GDM_limited_access TO GDM_Read;

--No access to original table
REVOKE SELECT ON demographics FROM GDM_Read;

--Logout as current user and Log in as user - gdm_read
SELECT * FROM demographics--access denied as expected

SELECT * FROM GDM_limited_access--it will show only 100 records without an ethnicity column.

--------------------------------------------------------------------------------------------------------------------------------------

--26. Compare % of Caesarean in GDM and Non GDM patients
SELECT COUNT(m.participant_id) AS caesarean_count, g.diagnosed_gdm,
ROUND(100*COUNT(m.participant_id)/(SELECT COUNT(*)FROM maternal_health_info WHERE caesarean = 1)::NUMERIC) 
AS percentage
FROM maternal_health_info m
JOIN glucose_tests g ON g.participant_id = m.participant_id
WHERE m.caesarean = 1
GROUP BY g.diagnosed_gdm;

--------------------------------------------------------------------------------------------------------------------------------------

--27. List the pair of  participants whose  estimated delivery dates are exactly consecutive dates.
SELECT p1.participant_id AS participant_1, p2.participant_id AS participant_2,
p1.edd_v1 AS edd_1, p2.edd_v1 AS edd_2
FROM pregnancy_info p1
INNER JOIN pregnancy_info p2 
ON p1.edd_v1 = p2.edd_v1 - INTERVAL '1 day'
WHERE p1.participant_id < p2.participant_id
ORDER BY p1.edd_v1;

--------------------------------------------------------------------------------------------------------------------------------------

--28. Identify the Participant count by ethnicity and age as a combination using CTE.

WITH RECURSIVE cte_ethnicity_age AS(
SELECT ethnicity, age_above_30, count(participant_id) AS participant_count
FROM demographics
GROUP BY ethnicity, age_above_30
ORDER BY ethnicity
)
SELECT * FROM cte_ethnicity_age;

--------------------------------------------------------------------------------------------------------------------------------------

--29. List the tables where column participant_id  is present. (Display column position number
--with respective table also).

SELECT table_name, column_name, ordinal_position
FROM information_schema.columns
WHERE column_name = 'participant_id'
ORDER BY ordinal_position;

--------------------------------------------------------------------------------------------------------------------------------------

--30. Create A trigger to raise a notice and prevent deletion of a record from view.
--Create a View

CREATE VIEW trigger_view AS
SELECT participant_id,eclampsia, epidural_spinal, caesarean
FROM maternal_health_info
ORDER BY participant_id
LIMIT 10;

SELECT * FROM trigger_view

--Create a Trigger Function
CREATE OR REPLACE FUNCTION prevent_deletion()
RETURNS TRIGGER AS $$
BEGIN
RAISE NOTICE 'Deletion of records from % is not allowed', TG_TABLE_NAME;
RETURN NULL; --prevents deletion
END;
$$ LANGUAGE plpgsql;

--Create Trigger
CREATE TRIGGER prevent_delete_trigger
INSTEAD OF DELETE ON trigger_view
FOR EACH ROW
EXECUTE FUNCTION prevent_deletion();

--Check the records in the view
SELECT * FROM trigger_view;

--Delete the record to check trigger
DELETE FROM trigger_view
WHERE participant_id = 3;

--------------------------------------------------------------------------------------------------------------------------------------

--31. "Identify infants whose condition improved from critically low to normal.
--Use window functions to determine the order based on severity to extent of recovery."

--The Apgar (Appearance, Pulse rate, Grimace Response, Activity and Respiration) score is a
--scoring system doctors and nurses use to assess newborns after they’re born.
--A score of 7 to 10 five minutes after birth is reassuring,
--4 to 7 is moderately abnormal, and 0 to 3 is concerning.
SELECT participant_id, apgar_1_min AS severity, apgar_3_min AS recovery, 
apgar_3_min - apgar_1_min AS extent_of_recovery,
RANK() OVER (ORDER BY apgar_1_min ASC) AS severity_rank,
RANK() OVER (ORDER BY(apgar_3_min - apgar_1_min)DESC) AS recovery_rank
FROM infant_outcomes
WHERE apgar_1_min < 7 and apgar_3_min > 7;

--------------------------------------------------------------------------------------------------------------------------------------

--32. List the Patients whose newborn may need immediate medical attention at  birth time

SELECT participant_id, apgar_1_min, apgar_3_min, birth_injury_fracture, birth_weight, 
CASE 
WHEN apgar_1_min < 4 AND apgar_3_min < 4
OR birth_injury_fracture =1
OR birth_weight <2.5
THEN 'Yes' ELSE 'No'
END AS Needs_Medical_Attention
FROM infant_outcomes
WHERE apgar_1_min < 4 AND apgar_3_min < 4
OR birth_injury_fracture =1
OR birth_weight <2.5;

--------------------------------------------------------------------------------------------------------------------------------------

--33. Calculate the average gestational age at delivery for GDM vs non-GDM pregnancies

select 
   case 
     when gt.diagnosed_gdm = 1 then 'GDM'
	 else 'Non-GDM'
   End as type_of_preganancy,	 
   avg(ga_delivery) as avg_gestational_delivery_at_age,
   count(*) as number_of_pregnancies 
   from 
   pregnancy_info p  
   join 
   glucose_tests gt on p.participant_id = gt.participant_id
   where p.ga_delivery is not null
   group by 
   case  when gt.diagnosed_gdm = 1 then 'GDM'
	 else 'Non-GDM'
end;

--------------------------------------------------------------------------------------------------------------------------------------

--34. Calculate the Participants Mean arterial Pressure (MAP) for both Visit 1 and Visit 3
--MAP Formula:
--MAP = Diastolic BP + 1/3(Systolic BP - Diastolic BP)

select participant_id, 
--visit 1 map calculation
Round(diastolic_bp_v1+(systolic_bp_v1-diastolic_bp_v1)/3,2) as MAP_Visit_1 ,
--visit 2 map calculation
round(diastolic_bp_v3+(systolic_bp_v3-diastolic_bp_v3)/3,2) as MAP_Visit_3
from
vital_signs

--------------------------------------------------------------------------------------------------------------------------------------

--35. List pregnancies that exceeded the standard 40 weeks full term and calculate the number of days delayed.

select participant_id,ga_delivery as full_term,
--calculate the number of days delayed:
(ga_delivery-40)*7 as exceeded_days
from pregnancy_info where ga_delivery > 40
group by participant_id,ga_delivery

--------------------------------------------------------------------------------------------------------------------------------------

--36. Apply lookahead concept to transform medication data and generate new column in the glucose_tests table
select * from glucose_tests where insulin_metformnin = '1' or glucose_lowering_therapy ='1'
--The lookahead concept helps predict future medication needs based on current test results 
--and track actual medication changes over the course of treatment

create or replace view glucose_lookahed_medication as
select 
 g.*,
 case
      when (later.insulin_metformnin = 'Insulin' and later.glucose_lowering_therapy = '1')
	  Then 1 Else 0
	  End
as needs_medication_later
from glucose_tests g
left join glucose_tests later on g.participant_id = later.participant_id
WHERE later.insulin_metformnin IS NOT NULL OR later.glucose_lowering_therapy IS NOT NULL;
--checked the view 
select participant_id,insulin_metformnin,glucose_lowering_therapy,needs_medication_later from glucose_lookahed_medication 
where participant_id = 23

--------------------------------------------------------------------------------------------------------------------------------------

--37. Find the correlation between Vitamin D levels and GDM diagnosis

select * from glucose_tests where diagnosed_gdm = 1
---checking the average vitamin d levels for women with GDM / NO GDM
select 
case 
when g.diagnosed_gdm = 1 then 'patient has Gesitational Diabetes(GDM)'
else 'NO GDM'
END as gdm_status,
count(*) as number_of_women,
(avg(b."25 OHD_V1")::numeric(10,1)) as avg_vitaminD_level
from biomarkers b
join glucose_tests g on b.participant_id = g.participant_id
where b."25 OHD_V1" is not null
and g.diagnosed_gdm in(0,1)
group by 
case 
when g.diagnosed_gdm = 1 then 'patient has Gesitational Diabetes(GDM)'
else 'NO GDM'
end;

-- Shows GDM rates for different Vitamin D levels

select 
vitamin_d_level,
total_women,
gdm_cases
from (
select 
  case 
  when b."25 OHD_V1" < 30 then 'Low'
   when b."25 OHD_V1" < 50 then 'medium(30-50)'
   else 'NOrmal (50+)'
   end as vitamin_d_level,
   count(*) as total_women,
   sum(g.diagnosed_gdm :: int) as gdm_cases
   from biomarkers b
   join glucose_tests g  on b.participant_id = g.participant_id
   where  b."25 OHD_V1" is not null 
   group by 1     
)

--------------------------------------------------------------------------------------------------------------------------------------

--38. Calculate the Cumulative percentage of Insulin medication consumption for gestational diabetic patients

select 
Round(
count(
case when insulin_metformnin = 'Insulin'
      then participant_id 
	  end)*100/
count(participant_id),2) as percentage_using_insulin
from glucose_tests 
where diagnosed_gdm = 1

--------------------------------------------------------------------------------------------------------------------------------------

--39. Count the Patient based on "BMI" category using "Width_bucket" function
--syntax:
--width_bucket(value, min_range, max_range, num_buckets)

select 
width_bucket(bmi_kgm2_v1,10,50,4)as bmi_category,
case
 when width_bucket(bmi_kgm2_v1,10,50,4)=1 then 'underweight(<18.5)'
 when width_bucket(bmi_kgm2_v1,10,50,4)=2 then 'NOrmal(18.5-24.9)'
 when width_bucket(bmi_kgm2_v1,10,50,4)=3 then 'overweight(25-29.9)'
 when width_bucket(bmi_kgm2_v1,10,50,4)=4 then 'obesse(>30)'
 else 'out of Range'
end as bmi_range,
count(*) as patient_count
from
demographics
where bmi_kgm2_v1 is not null
group by
bmi_category
order by bmi_category;

--------------------------------------------------------------------------------------------------------------------------------------

--40. Transform the values of edd_estimation_method to replace the abbreviations and handle nulls.

select 
distinct (edd_estimation_method),participant_id from pregnancy_info 
update pregnancy_info
set edd_estimation_method = case
  when edd_estimation_method = 'BPD' then 'biparietal diameter'
  when edd_estimation_method = 'CRL' then'crown-rump length'
  when edd_estimation_method is NULL then 'unknown'
 else edd_estimation_method
end

--------------------------------------------------------------------------------------------------------------------------------------

--41. Analyze the impact of GDM on infant outcomes using a composite score

--Step1
---first alter the table to add the composite scores
alter table infant_outcomes add column composite_scores numeric
--Step 2
--caluclating the composite score for infant outcomes 
--coalesce to handle the null values efficiently
--adding some positive points and negatives points to calculate birth_injury,
--fetal hypoglycaemia,fetal jaundice

update infant_outcomes
set composite_scores = (
(coalesce(apgar_1_min,0)*0.3)+
(coalesce(apgar_3_min,0)*0.3)+
(coalesce(birth_weight,0)*0.2)+
(case when birth_injury_fracture = 1 then -1 else 0 end )+
(case when coalesce("Fetal hypoglycaemia 10",0)=1 then -1 else 0 end)+
(case when coalesce("Fetal jaundice 10",0)=1 then -1 else 0 end)
);
--Step 3:
select participant_id,composite_scores from infant_outcomes

--step 4
--compare infant outcomes for GDM vs NON-GDM 

select g.diagnosed_gdm,
 count(*) as num_infants,
 avg(i.composite_scores) as avg_score,
 stddev(i.composite_scores) as score_stddev
from glucose_tests g
join infant_outcomes i on g.participant_id = i.participant_id
group by g.diagnosed_gdm

--------------------------------------------------------------------------------------------------------------------------------------

--42. Retrieve a list of participants who share the same estimated delivery due date with at least one other participant

select participant_id, "US EDD"
from documentation_track
where "US EDD" in (
select "US EDD" from documentation_track 
group by "US EDD"
having count(*)>1
)
order by "US EDD"


--------------------------------------------------------------------------------------------------------------------------------------

--43. Of all miscarriages records what percentage were currently using tobacco or drinking and what % were not?

SELECT COUNT(*) AS total_miscarriages
FROM pregnancy_info
WHERE "Miscarried 10" = 1;

select 
COUNT(*) AS total_miscarriages_based_on_alchol_or_tobacco_intake,
(count(*)*100.0/(select count(*) from pregnancy_info where "Miscarried 10" = 1)) as percentage_with_tobacco_or_alcohol,
(100-(count(*)*100.0/(select count(*) from pregnancy_info where "Miscarried 10" = 1))) as percentage_without_tobacco_or_alcohol
FROM pregnancy_info p
join demographics d on p.participant_id = d.participant_id 
WHERE p."Miscarried 10" = 1
and (d.smoking in ('EX','Current') or d.alcohol_intake = 1);

--------------------------------------------------------------------------------------------------------------------------------------

--44. Using window functions, identify all participants whose pulsation significantly considered an outlier.
--Hint: Threshold greater than 20 bpm
/*Window functions are special SQL functions that perform calculations across a set of table rows related to the current row, 
without collapsing the results into a single output row like regular aggregate functions do.*/


select participant_id, pulse_v1, pulse_v3,
     abs(pulse_v3 - pulse_v1) as pulse_change,
	 avg(abs(pulse_v3 - pulse_v1)) over () as avg_pulse_change
from vital_signs
where abs(pulse_v3 - pulse_v1) > 20


--------------------------------------------------------------------------------------------------------------------------------------

--45. Display the participant_id from 100 to 200 without using where condition.

select participant_id from demographics
order by participant_id
offset 99 limit 100

--------------------------------------------------------------------------------------------------------------------------------------

--46. Create a Backup table by using existing demographics table.List the differences
--observed between backup table and Base table

create table demographics_backup as select * from demographics

select * from demographics_backup

insert into demographics(participant_id,ethnicity,age_above_30,height_m,bmi_kgm2_v1,smoking,alcohol_intake,family_history,highrisk,medications,nutritional_counselling)
values(700,'white',1,4.65,45.5,'Never',0,0,0,0,0)
select * from demographics where participant_id = 700
select * from demographics_backup where participant_id = 700

--------------------------------------------------------------------------------------------------------------------------------------

--47. Create function and input the participant id, generate a 16-digit code with characters or digits until it reaches a total length of 16. 
--Also, display the number of characters added during this process.
--Use window functions to determine the order based on severity to extent of recovery.

create or replace function generate_code(p_id int)
returns table(participant_id int, generated_code text, chars_added int) as $$
declare
temp_code text := '';
chars_added int := 0;
begin
while length(temp_code)<16 loop
temp_code := temp_code || substring(md5(random()::TEXT),1,1);
chars_added := chars_added + 1;
end loop;
return query select p_id,temp_code,chars_added;
end;
$$ language plpgsql;

--step 2
--To analyse the severity- the health risks 
--gct_ogtt_high ->indicates severity is more
--pre-eclampsia --> indicates severity is more
--kidney_functionchronicillness
--high crp levels
-- to analyse the extent of recovery we need to consider
--the_h1b_change_percent,ALT_levels,hba1c_change_percent
--change in weight levels

select g.participant_id, 
       (g.gct_ogtt_high + m."Pre-eclampsia" + k.chronic_illness) as severity_score,
       (g.hba1c_change_percent + b.alt_change_percent + w.weight_change_percent) as recovery_extent,
       rank() over (order by (g.gct_ogtt_high + m."Pre-eclampsia" + k.chronic_illness) desc, 
                              (g.hba1c_change_percent + b.alt_change_percent + w.weight_change_percent) asc) as recovery_rank
from glucose_tests g
join maternal_health_info m on g.participant_id = m.participant_id
join kidney_function k on g.participant_id = k.participant_id
join biomarkers b on g.participant_id = b.participant_id
join body_compositions w on g.participant_id = w.participant_id;


--------------------------------------------------------------------------------------------------------------------------------------

--48. Display the last inserted row in demographics table without using limit.

--step 1 : insert the values into the demographic table
insert into demographics(participant_id,ethnicity,age_above_30,height_m,bmi_kgm2_v1,smoking,alcohol_intake,family_history,highrisk,medications,nutritional_counselling)
values(800,'white',1,4.65,45.5,'Never',0,0,0,0,0)
--step 2 : Check the values inserted in to the table
SELECT * FROM demographics where participant_id =800
--step 3: Checking the last inserted row in the table without using limit
select * from demographics order by participant_id desc 
fetch first row only
--step 4: Checking the last inserted 2 rows(if any) in the table without using limit
select * from demographics order by participant_id desc 
fetch first 2 rows only

--------------------------------------------------------------------------------------------------------------------------------------

--49. Count of patients by first letter of insulin_metformnin column.Replace blank values to Unknown

select left(coalesce(nullif(trim(insulin_metformnin),''),'Unknown'), 1) as first_letter,
count(*) as count_of_patients
from glucose_tests
group by first_letter
order by first_letter;

--------------------------------------------------------------------------------------------------------------------------------------

--50. "Create a Index on Ethnicity column. Check whether index is used in below Query:
/* select ethnicity,count(participant_id) 
from public.demographics
group by ethnicity. 
Make sure Above Query to use the index" */

/* Checking if the above query has index*/

explain select ethnicity,count(participant_id) 
from public.demographics
group by ethnicity;
/* The query plan shows that it is running Seq Scan. It seems that ethnicity 
column on demographics has no index. Hence giving index to the specified column with the below query*/

create index idx_ethnicity on demographics(ethnicity);

/* Checking the query completion time after indexing*/
select ethnicity,count(participant_id) 
from public.demographics
group by ethnicity;

/* Checking the Query Plan after indexing the column*/

explain select ethnicity,count(participant_id) 
from public.demographics
group by ethnicity;

/* The Query plan still shows it is running Seq Scan. Since the demographics table is small, 
PostgreSQL intentionally chose a sequential scan because it's faster to read the 
whole table than to use the index.*/

--------------------------------------------------------------------------------------------------------------------------------------

--51. Calculate the conception date or Last menstrual for all participants. Generate new attribute

select participant_id, 
(edd_v1 - interval '280 days') :: Date as  est_lmp,
(edd_v1 - interval '266 days') :: Date as est_conception
from pregnancy_info;

--------------------------------------------------------------------------------------------------------------------------------------

/*52. Display different set of 10 patients (every time) who were 
diagnosed with gestational diabetes from their demographic details.*/

select 
case 
when g.diagnosed_gdm = 1 then 'Yes'
when g.diagnosed_gdm = 0 then 'No'
else 'Unknown'
end as gdm_status, 
d.* from demographics d
join glucose_tests g
on g.participant_id = d.participant_id
where g.diagnosed_gdm = 1
order by random()
limit 10;

--------------------------------------------------------------------------------------------------------------------------------------

--53. Display list of patients with abnormal Alt_change % and diagnosed with vitamin D deficiency.

select participant_id, alt_change_percent, diagnosed_with_vitd_deficiency
from biomarkers
where alt_change_percent > 50 AND diagnosed_with_vitd_deficiency = 1;
/* Increased levels of ALT beyond 50% are considered as abnormal levels*/

--------------------------------------------------------------------------------------------------------------------------------------

--54. What is the distribution of participants by ethnicity and their GDM  status (either 'gdm' or 'non-gdm') in the database?

with gdm_status as (
select participant_id,
case
when diagnosed_gdm = 1 then 'gdm'
when diagnosed_gdm = 0 then 'non_gdm'
else 'Unknown'
end as gdm_label
from glucose_tests
) 

select d.ethnicity, gs.gdm_label, count(*) as participant_count
from demographics d
join gdm_status gs
on d.participant_id = gs.participant_id
group by d.ethnicity, gs.gdm_label
order by d.ethnicity, gs.gdm_label;

--------------------------------------------------------------------------------------------------------------------------------------

--55. Display all the details of 2nd tallest participant details using windows function

select * from 
(select *, row_number() over (order by height_m desc) as height_rank
from demographics) ranked
where height_rank = 2;

--------------------------------------------------------------------------------------------------------------------------------------

/*56. Create a trigger that raises a notice when trying to insert a duplicate 
participant_id into the demographics table. Provide a screenshot of the test result.*/

create function check_patient_duplicates()
returns trigger as $$
begin
 if exists (select 1 from demographics where participant_id = new.participant_id)
 then 
 raise notice 'This participant_id already exists: %', new.participant_id;
 return null;
 end if;
 return new;
 end;
 $$ language plpgsql;

 create trigger check_duplicate
 before insert on demographics
 for each row
 execute function check_patient_duplicates();

/* Checking the trigger by inserting new participant*/

 insert into demographics (participant_id, ethnicity, age_above_30, 
 height_m, bmi_kgm2_v1, smoking, alcohol_intake, family_history, 
 highrisk, medications, nutritional_counselling)
values('19', 'Hispanic', 1, 1.68, 24.5, 'ex', 0, 1, 1, 0, 1)

--------------------------------------------------------------------------------------------------------------------------------------

/*57. Compare the number of participants who signed the form on each day of the week and 
identify the day with the highest number of unique participants.*/

/* This query will compare the number of participants all days of the week 
and also shows the highest number of unique participants*/
select 
	to_char(date_form_signed, 'Day') as day_of_week,
	count(participant_id) as no_of_participants_signed_form
	from documentation_track
	group by day_of_week
	order by no_of_participants_signed_form desc;
	
/* This query will show the day of week when there were highest number of unique participants*/
with form_signed as 
( select 
	to_char(date_form_signed, 'Day') as day_of_week,
	count(distinct participant_id) as unique_participants
	from documentation_track
	group by day_of_week
	 )

select  * from form_signed
order by unique_participants desc
limit 1;

--------------------------------------------------------------------------------------------------------------------------------------

--58. What is the standard deviation of 'U creatinine_V1'? Display the result in two decimal places.

select round(stddev("U creatinine_V1")::numeric,2) as st_dev_U_Creatinine
from kidney_function;

--------------------------------------------------------------------------------------------------------------------------------------

--59. Create a Range Partition and show us how the partition is used in a Query.

/* Range Partitioning is a method of dividing table into multiple smaller, 
more maneageble pieces or partitions based on a range of values in 
a specific column (typically a date, number, or other ordered data type)*/

create table gd_glucose_Results (
patient_id SERIAL,
patient_name text,
gestational_week int ,
glucose_level_mgdl numeric,
test_date date,
primary key (patient_id, gestational_week)
) partition by range (gestational_week);

-- we are creating 3 sepearte tables by partition of gestational week.
-- first trimester: week 1 to 13
create table gd_trimester1 partition of gd_glucose_results
for values from (1) to (13);

-- second trimester: week 13 to 25
create table gd_trimester2 partition of gd_glucose_results
for values from (13) to (25);

-- third trimester: week 25 to 41
create table gd_trimester3 partition of gd_glucose_results
for values from (25) to (41);

-- now inserting values into the table gd_glucose_results
insert into gd_glucose_results(
patient_id, patient_name, gestational_week,glucose_level_mgdl,test_date)
values (1, 'Asha',  8,  92, '2025-01-10'),
(1, 'Asha', 10,  98, '2025-01-15'),
(2, 'Meera', 14, 130, '2025-02-05'),
(2, 'Meera', 20, 140, '2025-02-10'),
(2, 'Meera', 23, 135, '2025-02-15'),
(3, 'Nina', 26, 160, '2025-03-05'),
(3, 'Nina', 28, 158, '2025-03-12'),
(3, 'Nina', 30, 162, '2025-03-20'),
(4, 'Devi',  5,  85, '2025-01-07'),
(4, 'Devi', 12, 110, '2025-01-20'),
(4, 'Devi', 24, 125, '2025-02-25'),
(5, 'Priya', 13, 132, '2025-01-18'),
(5, 'Priya', 15, 145, '2025-01-25'),
(5, 'Priya', 17, 150, '2025-02-01'),
(5, 'Priya', 25, 155, '2025-02-12'),
(5, 'Priya', 32, 170, '2025-03-01'),
(6, 'Ramya', 35, 180, '2025-03-10'),
(6, 'Ramya', 36, 185, '2025-03-15'),
(6, 'Ramya', 38, 190, '2025-03-20'),
(6, 'Ramya', 39, 195, '2025-03-25');


select * from gd_glucose_results;

-- this query will automatically access only the gd_trimester 2 table
select * from gd_glucose_results
where gestational_week between 13 and 24 AND glucose_level_mgdl > 130;

-- This query will check the partition usage
explain select * from gd_glucose_results
where gestational_week = 20;
-- the result shows that it is directly scanning gd_trimester2 partition table

drop table gd_glucose_results cascade;

--------------------------------------------------------------------------------------------------------------------------------------

--60. Calculate the BMI for Visit 3 and Display the Highest BMI and their participant details.

/*-- Step 1 - This query will show the BMI for Vitsit 3 in a new column along with 
complete demographics details of the participant.*/

with Cal_BMI as
(select b.participant_id, round((b.weight_v3/(d.height_m * d.height_m)):: numeric,2) as BMI_V3  
from demographics d
join body_compositions b
on d.participant_id = b.participant_id
where b.weight_v3 is not null AND d.height_m is not null 
)
select d.*, c.BMI_V3 
from Cal_BMI c
join demographics d
on c.participant_id = d.participant_id;

--Step 2 - This query will display the highest BMI and their participant_id.
with Cal_BMI as
(select b.participant_id, round((b.weight_v3/(d.height_m * d.height_m)):: numeric,2) as BMI_V3  
from demographics d
join body_compositions b
on d.participant_id = b.participant_id
where b.weight_v3 is not null AND d.height_m is not null 
 )
select * from cal_BMI
order by BMI_V3 desc
limit 1;

--------------------------------------------------------------------------------------------------------------------------------------

--61. How do we gather statistics of table and check when it was done before.

--Step 1 - This query gathers statistics of demographisc table and stores in pg_stats

analyze demographics;

--Step 2 - This query will check when statistics were gathered the last time.

SELECT
    relname AS table_name,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE relname = 'demographics';

-- Step 3 - this query will show us the gathered statistics of table demographics

select * from pg_stats
where tablename = 'demographics';

--------------------------------------------------------------------------------------------------------------------------------------

/*62. Create a stored procedure that calculates the average OGTT value 
and compares it against a specified glucose threshold. If the average exceeds the threshold, classify the 
participant as "Gestational diabetes is suspected"*/

create or replace procedure Classify_GD(threshold numeric)
language plpgsql
as $$
begin
	drop table if exists temp_GD_classify;
	create temp table temp_GD_classify(
participant_id int,
Avg_OGTT numeric,
Classification text
) on commit preserve rows;
insert into temp_GD_classify
select 
	participant_id,
	round(((coalesce("0H_OGTT_Value", 0) + coalesce("1H_OGTT_Value", 0) + coalesce("2H_OGTT_Value", 0))/3.0)::numeric, 2) as avg_OGTT,
	case
	when ((coalesce("0H_OGTT_Value", 0) + coalesce("1H_OGTT_Value", 0) + coalesce("2H_OGTT_Value", 0))/3.0) > threshold then 'Gestational Diabetes Is Suspected'
	when ((coalesce("0H_OGTT_Value", 0) + coalesce("1H_OGTT_Value", 0) + coalesce("2H_OGTT_Value", 0))/3.0) = 0 then 'Unknown'
	else 'Normal'
	end as classification
	from glucose_tests;
end;
$$;

call classify_gd(7.9)

select * from temp_gd_classify
order by classification;

/* To evaluate the results, this query will show all OGTT values side by side along with average OGTT and classficiation.*/
select g."0H_OGTT_Value", g."1H_OGTT_Value", g."2H_OGTT_Value", t.* from glucose_tests g
join temp_gd_classify t
on t.participant_id = g.participant_id;

--------------------------------------------------------------------------------------------------------------------------------------

--63. Calculate Number of days difference between expected delivery date and ultrasound EDD

select d."US EDD", p.edd_v1,(d."US EDD" - p.edd_v1) as days_difference
from pregnancy_info p
join documentation_track d
on d.participant_id = p.participant_id;

--------------------------------------------------------------------------------------------------------------------------------------

--64. Estimate the follow up visit dates for all participants for each trimester and display them.

with classify_dates as (
select 
participant_id,
"US EDD",
"US EDD" - interval '40 weeks' as pregnancy_start_date,
"US EDD" - interval '27 weeks' as trimester1_end,
"US EDD" - interval '13 weeks' as trimester2_end
from documentation_track
)

select participant_id,
'1st Trimester Visit' as visit_type,
generate_series(pregnancy_start_date, trimester1_end, interval '4 weeks'):: date as follow_up_date
from classify_dates

UNION

select participant_id,
'2nd Trimester Visit' as visit_type,
generate_series(trimester1_end + interval '1 day', trimester2_end, interval '4 weeks') :: date as follow_up_date
from classify_dates

UNION

select participant_id,
'3rd Trimester Visit' as visit_type,
generate_series(trimester2_end + interval '1 day', "US EDD", interval '2 weeks'):: date as follow_up_date
from classify_dates
order by participant_id, follow_up_date;

--------------------------------------------------------------------------------------------------------------------------------------

--65.Show the position of letter 'n' in the insulin_metformnin column.Replace blank values to Unknown.List only distinct values.Hint:'n' is not case sensitive

SELECT DISTINCT 
	insulin_metformnin,
COALESCE(insulin_metformnin,'Unknown') AS updated_insulin_metformnin,
POSITION('n' IN LOWER(insulin_metformnin)) AS nth_position
FROM glucose_tests;

--------------------------------------------------------------------------------------------------------------------------------------

--66.Create a function to load data from an existing table into a new table, inserting records in batches of 100.

CREATE OR REPLACE FUNCTION move_data_newtable(existing_table TEXT, new_table TEXT)
RETURNS VOID 
LANGUAGE plpgsql
AS $$
DECLARE
    batch_size INT := 100;
    offset_val INT := 0;
    total_rows INT;
    fun_query TEXT;
BEGIN
EXECUTE format('SELECT COUNT(*) FROM %I', existing_table) INTO total_rows; -- Get total number of rows in existing_table 
EXECUTE format('CREATE TABLE IF NOT EXISTS %I (LIKE %I INCLUDING ALL)', new_table, existing_table); -- Create new table
-- Loop through in batches
WHILE offset_val < total_rows 
LOOP
	fun_query := format('INSERT INTO %I SELECT * FROM %I ORDER BY participant_id OFFSET %s LIMIT %s',new_table, existing_table, offset_val, batch_size);
EXECUTE fun_query;
offset_val := offset_val + batch_size; -- Direct to next batch
END LOOP;
END;
$$;

--Call Function to move data
SELECT move_data_newtable('vital_signs', 'vital_signs_copy');
-- Verify the new table
Select * from vital_signs_copy;

--------------------------------------------------------------------------------------------------------------------------------------

--67.Compare the average change in hemoglobin levels based on ethnicity using window function 

WITH hemoglobin_ethnicity AS (
SELECT b.participant_id, d.ethnicity,
	b.hb_change_percent,
AVG(b.hb_change_percent) OVER(PARTITION BY d.ethnicity) AS avg_change_hb_ethnicity
FROM biomarkers b
JOIN demographics d ON b.participant_id = d.participant_id
WHERE b.hb_change_percent IS NOT NULL)
SELECT DISTINCT
    ethnicity, ROUND(avg_change_hb_ethnicity::numeric, 2) AS avg_hb_change_percent
FROM hemoglobin_ethnicity
ORDER BY avg_hb_change_percent DESC; 

--------------------------------------------------------------------------------------------------------------------------------------
	
--68.List all the participants whose expected Delivery Date  is Weekend
-- Used DOW(Day of Week) and extracted data between 2014 to 2016 --

SELECT 
	participant_id, gestational_age_v1, edd_v1, TO_CHAR(edd_v1,'Day') AS Day
FROM pregnancy_info
WHERE 
  edd_v1 BETWEEN '2014-01-01' AND '2016-12-31'
  AND EXTRACT(DOW FROM edd_v1) IN (0, 6)  -- Zero represent Sunday & 6 as Saturday

--------------------------------------------------------------------------------------------------------------------------------------

--69.Calculate the percentage of GDM patients using only insulin medication

SELECT 
ROUND(100.0 * COUNT(*) FILTER (WHERE diagnosed_gdm = 1 AND insulin_metformnin = 'Insulin')
/ NULLIF(COUNT(*) FILTER (WHERE diagnosed_gdm = 1), 0), 2) AS insulin_only_percentage
FROM glucose_tests;

--------------------------------------------------------------------------------------------------------------------------------------

--70.Compare Ultrasound delivery date and edd by Lmp and Graph the Stacked Line chart.

SELECT 
  p.participant_id,
  p.edd_v1 AS edd_by_lmp,
  d."US EDD" AS edd_by_ultrasound,
  p.edd_consistent_with_lmp,
  ABS(d."US EDD" - p.edd_v1) AS difference
FROM pregnancy_info p
JOIN documentation_track d ON p.participant_id = d.participant_id
WHERE p.edd_v1 IS NOT NULL AND d."US EDD" IS NOT NULL;

--------------------------------------------------------------------------------------------------------------------------------------

--71.What proportion of participants diagnosed with gestational diabetes mellitus (GDM) have a family or their own previous history of the condition?

SELECT 
	ROUND(COUNT(*) FILTER (
WHERE demographics.family_history = 1 
OR screening.previous_gdm = 1) * 100.0 / NULLIF(COUNT(*), 0), 2) AS proportion_with_history
FROM glucose_tests
JOIN demographics ON glucose_tests.participant_id = demographics.participant_id
JOIN screening ON glucose_tests.participant_id = screening.participant_id
WHERE glucose_tests.diagnosed_gdm = 1;

--------------------------------------------------------------------------------------------------------------------------------------

--72.1.Create a backup of the demographic table that is accessible only for the current session..
 --2.In a new session ,display the name of the  schema name and backup table ,created (Attach Both the screen shots)

CREATE TEMP TABLE demographics_temp AS
SELECT * FROM demographics;

SHOW search_path;

SELECT tablename FROM pg_tables
WHERE schemaname = current_schema();

--------------------------------------------------------------------------------------------------------------------------------------

--73.What percentage of participants diagnosed with gestational diabetes mellitus (GDM) are using insulin, insulin & metformin and no-medication?

SELECT medication, 
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_gdm
FROM(
SELECT 
    CASE 
      WHEN insulin_metformnin = 'Insulin' THEN 'insulin'
      WHEN insulin_metformnin = 'MetforminInsulin' THEN 'insulin & metformin'
      WHEN insulin_metformnin = 'No' THEN 'no-Medication'
     ELSE NULL
END AS medication
FROM glucose_tests
WHERE diagnosed_gdm = 1) 
AS grouped_gdm WHERE medication IS NOT NULL
GROUP BY medication;

--------------------------------------------------------------------------------------------------------------------------------------

--74.What are the ways to optimize  below Query.
/*select * from 
public.pregnancy_info p, public.demographics d
where extract (year from edd_v1)='2015'
and p.participant_id=d.participant_id and d.ethnicity='White' ;" */


SELECT p.participant_id, p.edd_v1, d.ethnicity
FROM pregnancy_info p
INNER JOIN demographics d ON p.participant_id = d.participant_id
WHERE p.edd_v1 >= '2015-01-01' AND p.edd_v1 < '2016-01-01'
  AND d.ethnicity = 'White';
--Extracted only required field instead of listing all & used InnerJoin

--------------------------------------------------------------------------------------------------------------------------------------

--75.Display preeclampsia occurrence across different gestational hypertension statuses using cross tab

--Create tablefunc for using adv crosstab functionality
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM crosstab(
 -- Retrieves gestational hypertension status and preeclampsia status
$$ SELECT 
	s.ghp::text AS gestational_hypertension,
	m."Pre-eclampsia"::text AS preeclampsia_status,
COUNT(*) AS count      								 -- Counts occurrences, grouping by both conditions
FROM screening s
JOIN maternal_health_info m ON s.participant_id = m.participant_id
WHERE m."Pre-eclampsia" IS NOT NULL
GROUP BY s.ghp, m."Pre-eclampsia"
ORDER BY s.ghp, m."Pre-eclampsia"					-- Orders data for predictable pivot behavior
$$,
$$ SELECT DISTINCT "Pre-eclampsia"::text 			-- Get unique preeclampsia status values
FROM maternal_health_info 
WHERE "Pre-eclampsia" IS NOT NULL ORDER BY 1 $$) 
AS ct (gestational_hypertension text, preeclampsia_no int, preeclampsia_yes int); --  columns for the pivoted table

--------------------------------------------------------------------------------------------------------------------------------------

--76.Postgres supports extensibility for JSON querying. Prove it.

-- Create new table
CREATE TABLE gdm_patients (patient_no SERIAL PRIMARY KEY, patient_data JSONB);

--Insert patient_data in JSON format on the new table
INSERT INTO gdm_patients (patient_data)  
VALUES
	('{"name": "Laxmi", "age": 32, "glucose_level": 180, "insulin_required": true, "previous_conditions": {"visit1":"Gestational Diabetes", "visit2":"Hypertension"}, "medications": ["Metformin", "Vitamin D"]}'),
    ('{"name": "Rekha", "age": 28, "glucose_level": 160, "insulin_required": false, "previous_conditions": {"visit1": "None",  "visit2":"None"}, "medications": ["Prenatal Vitamin"]}'),
	('{"name": "Deepa", "age": 40, "glucose_level": 165, "insulin_required": false, "previous_conditions": {"visit1": "Pre-diabetes", "visit2": "None"}, "medications": ["Multivitamin"]}');

--Get JSON data for below condition with ->>(get value) and ->(get value in JSON format)
SELECT 
    patient_data->>'name' AS name, 
    patient_data->>'insulin_required' AS insulin_status,
    patient_data->'previous_conditions' AS pre_conditions
FROM gdm_patients;

--Created Indexing with GIN (Specific for JSON data)
CREATE INDEX idx_gdm_json ON gdm_patients USING GIN (patient_data);

-- (‘@>’ used for handling JSON data)
SELECT * FROM gdm_patients 
WHERE patient_data @> '{"insulin_required": true}';

--------------------------------------------------------------------------------------------------------------------------------------

--77.Display participants whose Vitamin D levels decreased by more than 50% between visit 1 and visit 3.
SELECT participant_id, "25 OHD_V1", "25 OHD_V3"
FROM biomarkers
WHERE ABS("25 OHD_V1" - "25 OHD_V3") > 0.5 * "25 OHD_V1";

--------------------------------------------------------------------------------------------------------------------------------------

--78.Among participants with elevated OGTT results, what are the highest, lowest, average HbA1c values at visit 3 ?

SELECT 
  MAX(hba1c_v3) AS maximum_hba1c_v3,
  MIN(hba1c_v3) AS minimum_hba1c_v3,
  ROUND(AVG(hba1c_v3), 2) AS average_hba1c_v3
FROM glucose_tests
WHERE gct_ogtt_high = 1
AND hba1c_v3 IS NOT NULL;

--------------------------------------------------------------------------------------------------------------------------------------

--79.Create a stored procedure to fetch past and current GDM status and their birth outcome. Call the procedure recursively. If the participant GDM is 'Yes'.

CREATE OR REPLACE PROCEDURE gdm_recursive_procedure(IN recursion_depth INT DEFAULT 1)
LANGUAGE plpgsql
AS $$ 
DECLARE rec RECORD;
BEGIN
-- Create temporary table inside the procedure
CREATE TEMP TABLE IF NOT EXISTS 
	temp_gdm_procedure ( participant_id INTEGER PRIMARY KEY, current_gdm INTEGER, previous_gdm INTEGER, birth_weight DOUBLE PRECISION,
						still_birth INTEGER, caesarean INTEGER, induction INTEGER, apgar_1_min INTEGER, apgar_3_min INTEGER,
        				birth_injury_fracture INTEGER, fetal_hypoglycaemia INTEGER, fetal_jaundice INTEGER) ON COMMIT DROP; 					
-- Fetch all participants with current GDM = 1
FOR rec IN 
SELECT s.participant_id, s.previous_gdm AS previous_gdm, g.diagnosed_gdm AS current_gdm, io.birth_weight, pi."Still-birth", m.caesarean,m.induction, io.apgar_1_min, io.apgar_3_min, io.birth_injury_fracture, io."Fetal hypoglycaemia 10", io."Fetal jaundice 10"
FROM screening s
LEFT JOIN glucose_tests g ON g.participant_id = s.participant_id
LEFT JOIN infant_outcomes io ON io.participant_id = s.participant_id
LEFT JOIN pregnancy_info pi ON pi.participant_id = s.participant_id
LEFT JOIN maternal_health_info m ON m.participant_id = s.participant_id
WHERE g.diagnosed_gdm = 1
LOOP
-- Stop recursion if participant already exists in temp table
IF EXISTS (SELECT 1 FROM temp_gdm_procedure WHERE participant_id = rec.participant_id) THEN
	RETURN;
END IF;
-- Insert record, skipping duplicates
INSERT INTO temp_gdm_procedure 
VALUES (
rec.participant_id, rec.previous_gdm::INT, rec.current_gdm::INT, rec.birth_weight, rec."Still-birth", rec.caesarean, rec.induction,
rec.apgar_1_min, rec.apgar_3_min, rec.birth_injury_fracture, rec."Fetal hypoglycaemia 10", rec."Fetal jaundice 10")
	ON CONFLICT (participant_id) DO NOTHING;
-- Recursive call with incremented depth
CALL gdm_recursive_procedure(recursion_depth + 1);
END LOOP;
END;
$$;

--Call the procedure
CALL gdm_recursive_procedure(1);
SELECT * FROM temp_gdm_procedure;

--------------------------------------------------------------------------------------------------------------------------------------

--80.Generate Pie chart to display patient count  with GDM ,Non GDM

SELECT 
  CASE 
    WHEN diagnosed_gdm = 1 THEN 'GDM'
    WHEN diagnosed_gdm = 0 THEN 'Non-GDM'
    ELSE 'Unknown'
  END AS gdm_category,
COUNT(*) AS patient_count
FROM glucose_tests
GROUP BY gdm_category;

--Used graph visualiser to generate piechart

--------------------------------------------------------------------------------------------------------------------------------------














