



------------------/* Maternal Health Project - 2024 - Finalized DB After Review by the team - SQL DATABASE */----------------------------------

__________________________________Base Table Creation Begining - Finalized ----------------------------------------------------------

/* Creating the raw table and importing observations dataset into it*/
Create table MH_Observations
(case_id   INT, 
age_years_old   Varchar(50), 
color_ethnicity   Varchar(50), 
hypertension_past_reported   Varchar(50), 
hypertension_past_treatment   Varchar(50), 
diabetes_mellitus_dm_reported   Varchar(50), 
diabetes_mellitus_disease_gap   Varchar(50), 
diabetes_mellitus_treatment   Varchar(50), 
tobacco_use   Varchar(50), 
tobacco_use_in_months   Varchar(50), 
tobacco_quantity_by_day   Varchar(50), 
alcohol_use   Varchar(50), 
alcohol_quantity_milliliters   Varchar(50), 
alcohol_preference   Varchar(50), 
drugs_preference   Varchar(50), 
drugs_years_use   Varchar(50), 
drugs_during_pregnancy   Varchar(50), 
past_newborn_1_weight   Varchar(50), 
gestational_age_past_newborn_1   Varchar(50), 
past_newborn_2_weight   Varchar(50), 
gestational_age_past_newborn_2   Varchar(50), 
past_newborn_3_weight   Varchar(50), 
gestational_age_past_newborn_3   Varchar(50), 
past_newborn_4_weight   Varchar(50), 
gestational_age_past_4_newborn   Varchar(50), 
breakfast_meal   Varchar(50), 
morning_snack   Varchar(50), 
lunch_meal   Varchar(50), 
afternoon_snack   Varchar(50), 
meal_dinner   Varchar(50), 
supper_meal   Varchar(50), 
bean   Varchar(50), 
fruits   Varchar(50), 
vegetables   Varchar(50), 
embedded_food   Varchar(50), 
pasta   Varchar(50), 
cookies   Varchar(50), 
right_systolic_blood_pressure   Varchar(50), 
right_diastolic_blood_pressure   Varchar(50), 
left_systolic_blood_pressure   Varchar(50), 
left_diastolic_blood_pressure   Varchar(50), 
periumbilical_subcutanous_fat   Varchar(50), 
periumbilical_visceral_fat   Varchar(50), 
periumbilical_total_fat   Varchar(50), 
preperitoneal_subcutaneous_fat   Varchar(50), 
preperitoneal_visceral_fat   Varchar(50), 
gestational_age_at_inclusion   Varchar(50), 
fetal_weight_at_ultrasound   Varchar(50), 
weight_fetal_percentile   Varchar(50), 
past_pregnancies_number   Varchar(50), 
miscarriage   Varchar(50), 
first_trimester_hematocrit   Varchar(50), 
second_trimester_hematocrit   Varchar(50), 
third_trimester_hematocrit   Varchar(50), 
firt_trimester_hemoglobin   Varchar(50), 
second_trimester_hemoglobin   Varchar(50), 
third_trimester_hemoglobin   Varchar(50), 
first_tri_fasting_blood_glucose   Varchar(50), 
second_tri_fasting_blood_glucose   Varchar(50), 
third_tri_fasting_blood_glucose   Varchar(50), 
"1st_hour_ogtt75_1st_tri"   Varchar(50), 
"1st_hour_ogtt75_2tri"   Varchar(50), 
"1st_hour_ogtt75_3tri"   Varchar(50), 
"2nd_hour_ogtt_1tri"   Varchar(50), 
"2nd_hour_ogtt75_2tri"   Varchar(50), 
"2nd_hour_ogtt_3tri"   Varchar(50), 
hiv_1tri   Varchar(50), 
syphilis_1tri   Varchar(50), 
c_hepatitis_1tri   Varchar(50), 
prepregnant_weight   Varchar(50), 
prepregnant_bmi   Varchar(50), 
bmi_according_who   Varchar(50), 
current_maternal_weight_1st_tri   Varchar(50), 
current_maternal_weight_2nd_tri   Varchar(50), 
current_maternal_weight_3rd_tri   Varchar(50), 
maternal_weight_at_inclusion   Varchar(50), 
hight_at_inclusion   Varchar(50), 
current_bmi   Varchar(50), 
current_bmi_according_who   Varchar(50), 
ultrasound_gestational_age   Varchar(50), 
maternal_brachial_circumference   Varchar(50), 
circumference_maternal_calf   Varchar(50), 
maternal_neck_circumference   Varchar(50), 
maternal_hip_circumference   Varchar(50), 
maternal_waist_circumference   Varchar(50), 
mean_tricciptal_skinfold   Varchar(50), 
mean_subscapular_skinfold   Varchar(50), 
mean_supra_iliac_skin_fold   Varchar(50), 
gestational_age_at_birth   Varchar(50), 
prepartum_maternal_weight   Varchar(50), 
prepartum_maternal_heigh   Varchar(50), 
delivery_mode   Varchar(50), 
cesarean_section_reason   Varchar(50), 
hospital_systolic_blood_pressure   Varchar(50), 
hospital_diastolic_blood_pressure   Varchar(50), 
hospital_hypertension   Varchar(50), 
preeclampsia_record_pregnancy   Varchar(50), 
gestational_diabetes_mellitus   Varchar(50), 
chronic_diabetes   Varchar(50), 
chronic_diseases   Varchar(50), 
disease_diagnose_during_pregnancy   Varchar(250), 
treatment_disease_pregnancy   Varchar(50), 
number_prenatal_appointments   Varchar(50), 
expected_weight_for_the_newborn   Varchar(50), 
newborn_weight   Varchar(50), 
newborn_height   Varchar(50), 
newborn_head_circumference   Varchar(50), 
thoracic_perimeter_newborn   Varchar(50), 
meconium_labor   Varchar(50), 
apgar_1st_min   Varchar(50), 
apgar_5th_min   Varchar(50), 
pediatric_resuscitation_maneuvers   Varchar(50), 
newborn_intubation   Varchar(50), 
newborn_airway_aspiration   Varchar(50), 
mothers_hospital_stay   Varchar(50)
);

------/* Now imported observations csv dataset into the raw table */-----

/* To view the created raw table */
select * from mh_observations;


/* We are creating an additional column to categorize the patients based on their follow-up status. 
In our research, we found that 61 case_ids have no data in 
gestational outcomes columns i.e from Mother's hospitalization and labor untill newborn details. 
When we tried to go buy nulls in delivery_mode, there are 2 extra records showing up with few newborn details including apgar. 
So, we decided to go buy the nulls in apgar_1st min column. Then we got 61 records which matches with the physionet number as well. 
Hence, by using this logic in the query, we consider these 61 patients to have been lost-to-follow-up. */

ALTER TABLE mh_observations
ADD COLUMN follow_up_status VARCHAR(50);

UPDATE mh_observations
SET follow_up_status = 'Lost To Follow Up'
WHERE apgar_1st_min IS NULL;

UPDATE mh_observations
SET follow_up_Status = 'Follow_up Completed'
WHERE apgar_1st_min IS NOT NULL;

/*To view the additional column created on the raw table */
select case_id,follow_up_Status from mh_observations;


------------------------------------11 Tables Creation along with their Values/Data BEGINS--------------------------------------------------------------

----------------------/* Dividing the mh_observations raw table into 11 tables according to the planned data schema. */------

/* Creating Demographics Table. We are including the new follow_up_status column in Demographics table */
Create Table Demographics as
Select case_id,
age_years_old,
color_ethnicity,
hight_at_inclusion,
prepregnant_weight,
prepregnant_bmi,
bmi_according_who,
maternal_weight_at_inclusion,
current_bmi_according_who,
follow_up_status,
current_bmi
from mh_observations;

/* Assigning Primary key constraint on Demographics table for the case_id column*/
ALTER TABLE Demographics
ADD CONSTRAINT pk_demographics_case_id PRIMARY KEY (case_id);

/* Connecting all tables to Demographics table. Hence, creating foregin keys from other tables. */
ALTER TABLE Demographics
ADD CONSTRAINT fk_Medical_History_case_id FOREIGN KEY (case_id) 
REFERENCES Medical_History(case_id),
ADD CONSTRAINT fk_Dietary_Habits_case_id FOREIGN KEY (case_id)
REFERENCES Dietary_Habits(case_id),
ADD CONSTRAINT fk_Lifestyle_case_id FOREIGN KEY (case_id)
REFERENCES Lifestyle(case_id),
ADD CONSTRAINT fk_Anthropometry_case_id FOREIGN KEY (case_id) 
REFERENCES Anthropometry(case_id),
ADD CONSTRAINT fk_Laboratory_Test_case_id FOREIGN KEY (case_id)
REFERENCES Laboratory_Test(case_id),
ADD CONSTRAINT fk_Vitals_case_id FOREIGN KEY (case_id) 
REFERENCES Vitals(case_id),
ADD CONSTRAINT fk_Ultrasound_case_id FOREIGN KEY (case_id)
REFERENCES Ultrasound(case_id),
ADD CONSTRAINT fk_Pregnancy_History_case_id FOREIGN KEY (case_id)
REFERENCES Pregnancy_History(case_id),
ADD CONSTRAINT fk_Hospitalization_Labor_case_id FOREIGN KEY (case_id) 
REFERENCES Hospitalization_Labor(case_id),
ADD CONSTRAINT fk_Newborn_case_id FOREIGN KEY (case_id) 
REFERENCES Newborn(case_id);

/* Creating Medical_History Table*/
Create Table Medical_History as
Select case_id,
hypertension_past_reported,
hypertension_past_treatment,
diabetes_mellitus_dm_reported,
diabetes_mellitus_disease_gap,
diabetes_mellitus_treatment
from mh_observations;

/* Assigning Primary key constraint on Medical_History table for the case_id column*/
ALTER TABLE Medical_History
ADD CONSTRAINT pk_Medical_History_case_id PRIMARY KEY (case_id);

/* Creating Dietary_Habits Table*/
Create Table Dietary_Habits as
Select case_id,
breakfast_meal,
morning_snack,
lunch_meal,
afternoon_snack,
meal_dinner,
supper_meal,
bean,
fruits,
vegetables,
embedded_food,
pasta,
cookies
from mh_observations;

/* Assigning Primary key constraint on Dietary_Habits table for the case_id column*/
ALTER TABLE Dietary_Habits
ADD CONSTRAINT pk_Dietary_Habits_case_id PRIMARY KEY (case_id);


/* Creating Lifestyle Table*/
Create Table Lifestyle as
Select case_id,
tobacco_use,
tobacco_use_in_months,
tobacco_quantity_by_day,
alcohol_use,
alcohol_quantity_milliliters,
alcohol_preference,
drugs_preference,
drugs_years_use,
drugs_during_pregnancy
from mh_observations;

/* Assigning Primary key constraint on Lifestyle table for the case_id column*/
ALTER TABLE Lifestyle
ADD CONSTRAINT pk_Lifestyle_case_id PRIMARY KEY (case_id);



/* Creating Anthropometry Table*/
Create Table Anthropometry as
Select case_id,
current_maternal_weight_1st_tri,
current_maternal_weight_2nd_tri,
current_maternal_weight_3rd_tri,
maternal_brachial_circumference,
circumference_maternal_calf,
maternal_neck_circumference,
maternal_waist_circumference,
maternal_hip_circumference,
mean_tricciptal_skinfold,
mean_subscapular_skinfold,
mean_supra_iliac_skin_fold
from mh_observations;

/* Assigning Primary key constraint on Anthropometry table for the case_id column*/
ALTER TABLE Anthropometry
ADD CONSTRAINT pk_Anthropometry_case_id PRIMARY KEY (case_id);


/* Creating Laboratory_Test Table*/
Create Table Laboratory_Test as
Select case_id,
first_trimester_hematocrit,
second_trimester_hematocrit,
third_trimester_hematocrit,
firt_trimester_hemoglobin,
second_trimester_hemoglobin,
third_trimester_hemoglobin,
first_tri_fasting_blood_glucose,
second_tri_fasting_blood_glucose,
third_tri_fasting_blood_glucose,
"1st_hour_ogtt75_1st_tri",
"1st_hour_ogtt75_2tri",
"1st_hour_ogtt75_3tri",
"2nd_hour_ogtt_1tri",
"2nd_hour_ogtt75_2tri",
"2nd_hour_ogtt_3tri",
hiv_1tri,
syphilis_1tri,
c_hepatitis_1tri
from mh_observations;

/* Assigning Primary key constraint on Laboratory_Test table for the case_id column*/
ALTER TABLE Laboratory_Test
ADD CONSTRAINT pk_Laboratory_Test_case_id PRIMARY KEY (case_id);

/* Creating Vitals Table*/
Create Table Vitals as
Select case_id,
right_systolic_blood_pressure,
right_diastolic_blood_pressure,
left_systolic_blood_pressure,
left_diastolic_blood_pressure
from mh_observations;

/* Assigning Primary key constraint on Vitals table for the case_id column*/
ALTER TABLE Vitals
ADD CONSTRAINT pk_Vitals_case_id PRIMARY KEY (case_id);

/* Creating Ultrasound Table*/
Create Table Ultrasound as
Select case_id,
periumbilical_subcutanous_fat,
periumbilical_visceral_fat,
periumbilical_total_fat,
preperitoneal_subcutaneous_fat,
preperitoneal_visceral_fat,
fetal_weight_at_ultrasound,
ultrasound_gestational_age,
weight_fetal_percentile,
gestational_age_at_inclusion
from mh_observations;

/* Assigning Primary key constraint on Ultrasound table for the case_id column*/
ALTER TABLE Ultrasound
ADD CONSTRAINT pk_Ultrasound_case_id PRIMARY KEY (case_id);

/* Creating Pregnancy_History Table*/
Create Table Pregnancy_History as
Select case_id,
past_newborn_1_weight,
gestational_age_past_newborn_1,
past_newborn_2_weight,
gestational_age_past_newborn_2,
past_newborn_3_weight,
gestational_age_past_newborn_3,
past_newborn_4_weight,
gestational_age_past_4_newborn,
past_pregnancies_number,
miscarriage
from mh_observations;

/* Assigning Primary key constraint on Pregnancy_History table for the case_id column*/
ALTER TABLE Pregnancy_History
ADD CONSTRAINT pk_Pregnancy_History_case_id PRIMARY KEY (case_id);

/* Creating Hospitalization_Labor Table*/
Create Table Hospitalization_Labor as
Select case_id,
delivery_mode,
cesarean_section_reason,
prepartum_maternal_weight,
prepartum_maternal_heigh,
hospital_systolic_blood_pressure,
hospital_diastolic_blood_pressure,
hospital_hypertension,
gestational_diabetes_mellitus,
disease_diagnose_during_pregnancy,
treatment_disease_pregnancy,
chronic_diseases,
preeclampsia_record_pregnancy,
chronic_diabetes,
number_prenatal_appointments,
mothers_hospital_stay
from mh_observations;

/* Assigning Primary key constraint on Hospitalization_Labor table for the case_id column*/
ALTER TABLE Hospitalization_Labor
ADD CONSTRAINT pk_Hospitalization_Labor_case_id PRIMARY KEY (case_id);

/* Creating Newborn Table*/
Create Table Newborn as
Select case_id,
expected_weight_for_the_newborn,
newborn_weight,
newborn_height,
gestational_age_at_birth,
newborn_head_circumference,
thoracic_perimeter_newborn,
meconium_labor,
apgar_1st_min,
apgar_5th_min,
pediatric_resuscitation_maneuvers,
newborn_intubation,
newborn_airway_aspiration
from mh_observations;

/* Assigning Primary key constraint on Newborn table for the case_id column*/
ALTER TABLE Newborn
ADD CONSTRAINT pk_Newborn_case_id PRIMARY KEY (case_id);




---------------------------------------------- 11 Tables Creation & Insertion - ENDS-------------------------------------------------------------------

------------------------------------CLEANING & TRANSFORMATION (C&T) PROCESS BEGINS---------------------------------------------------
Cleaning & Transformation process includes - Renaming columns, Changing Data Type, Removing columns, Adding columns, correcting or updating the values 



-------------------------------------------DEMOGRAPHICS TABLE Transformation-----------------------------------------------------------

SELECT * FROM Demographics;

UPDATE Demographics
SET
  age_years_old = NULLIF(NULLIF(NULLIF(REPLACE(age_years_old::VARCHAR, ',', ''), ''), 'not_applicable'), 'no_answer')::NUMERIC,
  hight_at_inclusion = NULLIF(NULLIF(NULLIF(REPLACE(hight_at_inclusion::VARCHAR, ',', ''), ''), 'not_applicable'), 'no_answer')::NUMERIC(10,2),
  prepregnant_weight = NULLIF(NULLIF(NULLIF(REPLACE(prepregnant_weight::VARCHAR, ',', ''), ''), 'not_applicable'), 'no_answer')::NUMERIC(10,2),
  prepregnant_bmi = NULLIF(NULLIF(NULLIF(REPLACE(prepregnant_bmi::VARCHAR, ',', ''), ''), 'not_applicable'), 'no_answer')::NUMERIC(10,2),
  maternal_weight_at_inclusion = NULLIF(NULLIF(NULLIF(REPLACE(maternal_weight_at_inclusion::VARCHAR, ',', ''), ''), 'not_applicable'), 'no_answer')::NUMERIC(10,2),
  current_bmi = NULLIF(NULLIF(NULLIF(REPLACE(current_bmi::VARCHAR, ',', ''), ''), 'not_applicable'), 'no_answer')::NUMERIC(10,2);

ALTER TABLE DEMOGRAPHICS RENAME COLUMN  age_years_old to age;
ALTER TABLE  DEMOGRAPHICS RENAME COLUMN color_ethnicity to ethnicity;
ALTER TABLE  DEMOGRAPHICS RENAME COLUMN hight_at_inclusion to HT_INCLUSION_MTRS;

/*CHANGING COLOR COLUMN VALUES TO WHITE,BLACK,ETC */

UPDATE DEMOGRAPHICS SET ethnicity=
CASE
WHEN ethnicity = '0' THEN 'White'
WHEN ethnicity = '1' THEN 'Black'
WHEN ethnicity = '2' THEN 'Brown'
WHEN ethnicity = '3' THEN 'Asian'
ELSE NULL
END;

/* Do NOT impute height unless you have strong clinical or demographic clues.
   If BMI or height is critical for modeling, consider flagging this record for exclusion
   or use population-based height estimates with caution and audit trail. */
/*
UPDATE  DEMOGRAPHICS
set HT_inclusion = sqrt(prepregnant_weight/27.1)     --21.7 is the avg of BMI code 1 range(18.5 - 24.9)
where HT_inclusion is null and bmi_according_who = 1 ; --formula BMI = weight/height^2 */

/* Label the bmi_according_who categories */
/* Label the current_bmi_according_who categories   --- BMI At Inclusion */
UPDATE demographics
SET current_bmi_according_who = CASE current_bmi_according_who
    WHEN '0' THEN 'Underweight'
    WHEN '1' THEN 'Normal'
    WHEN '2' THEN 'Overweight'
    WHEN '3' THEN 'Obese'
    ELSE NULL
END;

UPDATE demographics
SET bmi_according_who = CASE bmi_according_who
    WHEN '0' THEN 'Underweight'
    WHEN '1' THEN 'Normal'
    WHEN '2' THEN 'Overweight'
    WHEN '3' THEN 'Obese'
    ELSE NULL
END;

ALTER TABLE DEMOGRAPHICS
ALTER COLUMN Prepregnant_bmi TYPE NUMERIC USING Prepregnant_bmi::NUMERIC;

ALTER TABLE Demographics
ALTER COLUMN Prepregnant_weight TYPE NUMERIC(6,2)
USING ROUND(Prepregnant_weight::NUMERIC, 2);

ALTER TABLE DEMOGRAPHICS
ALTER COLUMN age TYPE NUMERIC USING age::NUMERIC;

UPDATE DEMOGRAPHICS
SET bmi_according_who = NULL
WHERE bmi_according_who = 'not_applicable';

/* changing the datatype for the belwo columns to numeric to perform the calculations */
ALTER TABLE DEMOGRAPHICS
ALTER COLUMN maternal_weight_at_inclusion TYPE NUMERIC USING maternal_weight_at_inclusion::NUMERIC;

ALTER TABLE DEMOGRAPHICS
ALTER COLUMN HT_inclusion_MTRS TYPE NUMERIC USING HT_inclusion_MTRS::NUMERIC;

ALTER TABLE DEMOGRAPHICS
ALTER COLUMN current_bmi TYPE NUMERIC USING current_bmi::NUMERIC;


/* Estimate prepregnant weight by subtracting fetal weight (in kg) 
   from maternal weight at inclusion. This assumes fetal mass contributes 
   to maternal weight during late pregnancy and helps recover missing values. */
UPDATE demographics d
SET prepregnant_weight = (d.maternal_weight_at_inclusion) - (u.fetal_weight_ultrasound_grms/1000)
FROM ultrasound u
WHERE d.case_id = u.case_id
  AND d.prepregnant_weight IS NULL; -------execute this query after Ultrasound
 
SELECT * FROM DEMOGRAPHICS 
WHERE PREPREGNANT_WEIGHT IS NULL;


/*Updating maternal_weight_at_inclusion for case_id 124 */
UPDATE demographics
SET maternal_weight_at_inclusion = current_bmi*(HT_inclusion_MTRS * HT_inclusion_MTRS)
where maternal_weight_at_inclusion IS NULL;



-------------------------------------------MEDICAL HISTORY TABLE Transformation-----------------------------------------------------------

/* Renaming Table Medical History column name into New Readable Column */

ALTER TABLE Medical_History RENAME COLUMN diabetes_mellitus_dm_reported TO Diabetes_Mellitus_Reported;
ALTER TABLE Medical_History RENAME COLUMN diabetes_mellitus_disease_gap TO Diabetes_Mellitus_Gap;


/* updating hypertension_past_reported values with Yes or No for better clarity */
 UPDATE Medical_History
SET Hypertension_Past_Reported = CASE
  WHEN Hypertension_Past_Reported = '1' THEN 'Yes'
  WHEN Hypertension_Past_Reported = '0' THEN 'No'
  ELSE NULL
END;

/*updating hypertension_past_treatment with appropriate values based on data dictionary. */
 UPDATE Medical_History
SET Hypertension_Past_treatment = CASE
  WHEN Hypertension_Past_treatment = '0' THEN 'No Medicine'
  WHEN Hypertension_Past_treatment = '1' THEN 'Medicine'
  ELSE NULL
END;

/*updating Diabetes_Mellitus_Reported with appropriate values based on data dictionary. Replacing not applicables with nulls*/
UPDATE Medical_History
SET Diabetes_Mellitus_Reported = CASE
  WHEN Diabetes_Mellitus_Reported = '1' THEN 'Yes'
  WHEN Diabetes_Mellitus_Reported = '0' THEN 'No'
  ELSE NULL
END;

/*updating Diabetes_Mellitus_Gap with appropriate values based on data dictionary.Replacing not applicables with nulls */
UPDATE Medical_History
SET Diabetes_Mellitus_Gap = CASE
  WHEN Diabetes_Mellitus_Gap = '0' THEN 'Chronic'
  WHEN Diabetes_Mellitus_Gap = '1' THEN 'Past Pregnancy'
  ELSE NULL
END;

/*updating Diabetes_Mellitus_Treatment with appropriate values based on data dictionary. Replacing not applicables with nulls */
UPDATE Medical_History
SET Diabetes_Mellitus_Treatment = CASE
  WHEN Diabetes_Mellitus_Treatment = '0' THEN 'No Medicine'
  WHEN Diabetes_Mellitus_Treatment = '1' THEN 'Medicine'
  WHEN Diabetes_Mellitus_Treatment = '2' THEN 'Diet'
  ELSE NULL
END;

/*  Case_id 187 and 156 have not applciable. But they had reported diseases. 
so for treatment column it has to be no treatment rather than not applicable.*/
UPDATE Medical_History
SET Hypertension_Past_treatment = 'No Medicine'  
  where case_id= 187;

  UPDATE Medical_History
SET Diabetes_Mellitus_Treatment = 'No Medicine'  
  where case_id= 156;

/* To view the changes on Medical_History table */
 select * from Medical_History

-------------------------------------------DIETARY_HABITS Table Transformation-----------------------------------------------------------

ALTER TABLE Dietary_Habits
RENAME COLUMN meal_dinner TO dinner_meal;

/*Replacing 1 and 0 with Yes and No respectively for clarity during analysis */

UPDATE Dietary_Habits
SET breakfast_meal = CASE
	WHEN breakfast_meal = '1' THEN 'Yes'
	WHEN breakfast_meal = '0' THEN 'No'
	ELSE NULL
END,
	morning_snack = CASE
	WHEN morning_snack = '1' THEN 'Yes'
	WHEN morning_snack = '0' THEN 'No'
	ELSE NULL
END,
	lunch_meal = CASE
	WHEN lunch_meal = '1' THEN 'Yes'
	WHEN lunch_meal = '0' THEN 'No'
	ELSE NULL
END,
	afternoon_snack = CASE
	WHEN afternoon_snack = '1' THEN 'Yes'
	WHEN afternoon_snack = '0' THEN 'No'
	ELSE NULL
END,
	dinner_meal = CASE
	WHEN dinner_meal = '1' THEN 'Yes'
	WHEN dinner_meal = '0' THEN 'No'
	ELSE NULL
END,
	supper_meal = CASE
	WHEN supper_meal = '1' THEN 'Yes'
	WHEN supper_meal = '0' THEN 'No'
	ELSE NULL
END,
	bean = CASE
	WHEN bean = '1' THEN 'Yes'
	WHEN bean = '0' THEN 'No'
	ELSE NULL
END,
	fruits = CASE
	WHEN fruits = '1' THEN 'Yes'
	WHEN fruits = '0' THEN 'No'
	ELSE NULL
END,
	vegetables = CASE
	WHEN vegetables = '1' THEN 'Yes'
	WHEN vegetables = '0' THEN 'No'
	ELSE NULL
END,
	embedded_food = CASE
	WHEN embedded_food = '1' THEN 'Yes'
	WHEN embedded_food = '0' THEN 'No'
	ELSE NULL
END,
	pasta = CASE
	WHEN pasta = '1' THEN 'Yes'
	WHEN pasta = '0' THEN 'No'
	ELSE NULL
END,
	cookies = CASE
	WHEN cookies = '1' THEN 'Yes'
	WHEN cookies = '0' THEN 'No'
	ELSE NULL
END;

/* To view the changes. */
SELECT * FROM Dietary_Habits;

-------------------------------------------LIFESTYLE Table Transformation-----------------------------------------------------------

/* tobacco_use: update 0/1 to NO/YES */

UPDATE Lifestyle
SET tobacco_use = CASE
    WHEN tobacco_use = '0' THEN 'NO'
    WHEN tobacco_use = '1' THEN 'YES'
    ELSE tobacco_use
END;

/* Shortening not_applicable to NA for ease */

UPDATE Lifestyle
SET tobacco_use_in_months = CASE
    WHEN LOWER(tobacco_use_in_months) = 'not_applicable' THEN 'NA'
    ELSE tobacco_use_in_months
END;

/* Shortening not_applicable to NA for ease and updating value of outlier*/

UPDATE Lifestyle
SET tobacco_quantity_by_day = CASE
    WHEN LOWER(tobacco_quantity_by_day) = 'not_applicable' THEN 'NA'
    WHEN case_id = 47 AND tobacco_quantity_by_day = '0.3' THEN '3'
    ELSE tobacco_quantity_by_day
END;

/* alcohol_use: update 0/1 to NO/YES */

UPDATE Lifestyle
SET alcohol_use = CASE
    WHEN alcohol_use = '0' THEN 'NO'
    WHEN alcohol_use = '1' THEN 'YES'
    ELSE alcohol_use
END;

/* Renaming column name for ease */

ALTER TABLE lifestyle
RENAME COLUMN alcohol_quantity_milliliters TO alcohol_qty_ml;

/* Shortening not_applicable to NA for ease and No answer to Null */

UPDATE Lifestyle
SET alcohol_qty_ml = CASE
    WHEN LOWER(alcohol_qty_ml) IN ('not_applicable') THEN 'NA'
	WHEN LOWER(alcohol_qty_ml) IN ('no_answer') THEN Null
    ELSE alcohol_qty_ml
END;

/* alcohol_preference: update 0/1 to Fermented/Distilled, and Shortening not_applicable to NA for ease */


UPDATE Lifestyle
SET alcohol_preference = CASE
    WHEN alcohol_preference = '0' THEN 'Fermented'
    WHEN alcohol_preference = '1' THEN 'Distilled'
    WHEN LOWER(alcohol_preference) = 'not_applicable' THEN 'NA'
    ELSE alcohol_preference
END;

/*drugs_preference: update 0/1 to NO/marijuana and Shortening not_applicable to NA for ease */ 


UPDATE lifestyle
SET  drugs_preference = CASE
    WHEN drugs_preference= '0' THEN 'No'
    WHEN drugs_preference = '1' THEN 'Marijuana'
	WHEN drugs_preference = 'not_applicable' THEN 'No'
    ELSE drugs_preference
END;

/* Shortening not_applicable to NA for ease */

UPDATE Lifestyle
SET drugs_years_use = CASE
    WHEN LOWER(drugs_years_use) = 'not_applicable' THEN 'NA'
    ELSE drugs_years_use
END;

/* drugs_during_pregnancy: change type, then update 0/1 to NO/YES, Shortening not_applicable to NA for ease */ 

UPDATE Lifestyle
SET drugs_during_pregnancy = CASE
    WHEN drugs_during_pregnancy = '0' THEN 'NO'
    WHEN drugs_during_pregnancy = '1' THEN 'YES'
    WHEN LOWER(drugs_during_pregnancy) = 'not_applicable' THEN 'NA'
    ELSE drugs_during_pregnancy
END;

select * from lifestyle



-------------------------------------------LABORATORY TEST Table Transformation-----------------------------------------------------------

-- Rename column names
ALTER TABLE Laboratory_Test RENAME COLUMN first_trimester_hematocrit TO hematocrit_1st_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN second_trimester_hematocrit TO hematocrit_2nd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN third_trimester_hematocrit TO hematocrit_3rd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN firt_trimester_hemoglobin TO hemoglobin_1st_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN second_trimester_hemoglobin TO hemoglobin_2nd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN third_trimester_hemoglobin TO hemoglobin_3rd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN first_tri_fasting_blood_glucose TO fasting_glucose_1st_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN second_tri_fasting_blood_glucose TO fasting_glucose_2nd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN third_tri_fasting_blood_glucose TO fasting_glucose_3rd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN "1st_hour_ogtt75_1st_tri" TO first_hr_ogtt75_1st_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN "1st_hour_ogtt75_2tri" TO first_hr_ogtt75_2nd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN "1st_hour_ogtt75_3tri" TO first_hr_ogtt75_3rd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN "2nd_hour_ogtt_1tri" TO second_hr_ogtt75_1st_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN "2nd_hour_ogtt75_2tri" TO second_hr_ogtt75_2nd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN "2nd_hour_ogtt_3tri" TO second_hr_ogtt75_3rd_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN hiv_1tri TO hiv_1st_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN syphilis_1tri TO syphilis_1st_tri;
ALTER TABLE Laboratory_Test RENAME COLUMN c_hepatitis_1tri TO hepatitis_c_1st_tri;

-- Replace not-applicable to null 
UPDATE Laboratory_Test
SET hematocrit_2nd_tri = NULL
WHERE hematocrit_2nd_tri = 'not_applicable';

UPDATE Laboratory_Test
SET hematocrit_3rd_tri = NULL
WHERE hematocrit_3rd_tri= 'not_applicable'; 

UPDATE Laboratory_Test
SET hemoglobin_2nd_tri = NULL     
WHERE hemoglobin_2nd_tri= 'not_applicable';

UPDATE Laboratory_Test
SET hemoglobin_3rd_tri = NULL
WHERE hemoglobin_3rd_tri= 'not_applicable';

UPDATE Laboratory_Test
SET fasting_glucose_1st_tri = NULL
WHERE fasting_glucose_1st_tri= 'not_applicable';

UPDATE Laboratory_Test
SET fasting_glucose_2nd_tri = NULL
WHERE fasting_glucose_2nd_tri= 'not_applicable';

UPDATE Laboratory_Test
SET fasting_glucose_3rd_tri = NULL
WHERE fasting_glucose_3rd_tri = 'not_applicable';

UPDATE Laboratory_Test
SET first_hr_ogtt75_1st_tri = NULL
WHERE first_hr_ogtt75_1st_tri= 'not_applicable';

UPDATE Laboratory_Test
SET first_hr_ogtt75_2nd_tri = NULL
WHERE  first_hr_ogtt75_2nd_tri= 'not_applicable';

UPDATE Laboratory_Test
SET first_hr_ogtt75_3rd_tri = NULL
WHERE  first_hr_ogtt75_3rd_tri= 'not_applicable';

UPDATE Laboratory_Test
SET second_hr_ogtt75_1st_tri = NULL
WHERE  second_hr_ogtt75_1st_tri= 'not_applicable';

UPDATE Laboratory_Test
SET second_hr_ogtt75_2nd_tri = NULL
WHERE  second_hr_ogtt75_2nd_tri= 'not_applicable';

UPDATE Laboratory_Test
SET second_hr_ogtt75_3rd_tri = NULL
WHERE  second_hr_ogtt75_3rd_tri= 'not_applicable';

UPDATE Laboratory_Test
SET hiv_1st_tri = NULL
WHERE  hiv_1st_tri= 'not_applicable';

UPDATE Laboratory_Test
SET syphilis_1st_tri = NULL
WHERE syphilis_1st_tri= 'not_applicable';

UPDATE Laboratory_Test
SET hepatitis_c_1st_tri = NULL
WHERE  hepatitis_c_1st_tri= 'not_applicable';

-- Change the datatype to numeric
ALTER TABLE Laboratory_Test
ALTER COLUMN hematocrit_1st_tri TYPE NUMERIC USING hematocrit_1st_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN hematocrit_2nd_tri TYPE NUMERIC USING hematocrit_2nd_tri::NUMERIC; 

ALTER TABLE Laboratory_Test
ALTER COLUMN hematocrit_3rd_tri TYPE NUMERIC USING hematocrit_3rd_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN hemoglobin_1st_tri TYPE NUMERIC(4,1) USING hemoglobin_1st_tri::NUMERIC;  

ALTER TABLE Laboratory_Test
ALTER COLUMN hemoglobin_2nd_tri TYPE NUMERIC USING hemoglobin_2nd_tri::NUMERIC; 

ALTER TABLE Laboratory_Test
ALTER COLUMN hemoglobin_3rd_tri TYPE NUMERIC USING hemoglobin_3rd_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN fasting_glucose_1st_tri TYPE NUMERIC USING fasting_glucose_1st_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN fasting_glucose_2nd_tri TYPE NUMERIC USING fasting_glucose_2nd_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN fasting_glucose_3rd_tri TYPE NUMERIC USING fasting_glucose_3rd_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN first_hr_ogtt75_1st_tri TYPE NUMERIC USING first_hr_ogtt75_1st_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN first_hr_ogtt75_2nd_tri TYPE NUMERIC USING first_hr_ogtt75_2nd_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN first_hr_ogtt75_3rd_tri TYPE NUMERIC USING first_hr_ogtt75_3rd_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN second_hr_ogtt75_1st_tri TYPE NUMERIC USING second_hr_ogtt75_1st_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN second_hr_ogtt75_2nd_tri TYPE NUMERIC USING second_hr_ogtt75_2nd_tri::NUMERIC;

ALTER TABLE Laboratory_Test
ALTER COLUMN second_hr_ogtt75_3rd_tri TYPE NUMERIC USING second_hr_ogtt75_3rd_tri::NUMERIC;

-- Replace 0 and 1 as no/yes
UPDATE Laboratory_Test
SET hiv_1st_tri = CASE 
    WHEN hiv_1st_tri = '1' THEN 'Yes'
    WHEN hiv_1st_tri = '0' THEN 'No'
    ELSE hiv_1st_tri
END;

UPDATE Laboratory_Test
SET syphilis_1st_tri = CASE 
    WHEN syphilis_1st_tri = '1' THEN 'Yes'
    WHEN syphilis_1st_tri = '0' THEN 'No'
    ELSE syphilis_1st_tri
END;

UPDATE Laboratory_Test
SET hepatitis_c_1st_tri = CASE 
    WHEN hepatitis_c_1st_tri = '1' THEN 'Yes'
    WHEN hepatitis_c_1st_tri = '0' THEN 'No'
    ELSE hepatitis_c_1st_tri
END;

-- Filling blank values of hematocrit calculated from hemoglobin
UPDATE Laboratory_Test
SET hematocrit_1st_tri = hemoglobin_1st_tri * 3
WHERE hematocrit_1st_tri IS NULL
  AND hemoglobin_1st_tri IS NOT NULL;

UPDATE Laboratory_Test
SET hematocrit_2nd_tri = hemoglobin_2nd_tri * 3
WHERE hematocrit_2nd_tri IS NULL
  AND hemoglobin_2nd_tri is not null;

-- Low outlier data correction where 11.9 is not possible, so calculating it from hemoglobin 
UPDATE Laboratory_Test
SET hematocrit_2nd_tri = hemoglobin_2nd_tri * 3
WHERE case_id = 216;
 
UPDATE Laboratory_Test
SET hematocrit_3rd_tri = hemoglobin_3rd_tri  * 3
WHERE hematocrit_3rd_tri IS NULL
  AND hemoglobin_3rd_tri IS NOT NULL;
  
UPDATE Laboratory_Test
SET hemoglobin_1st_tri = (hematocrit_1st_tri / 3)
WHERE hemoglobin_1st_tri IS NULL
  AND hematocrit_1st_tri IS NOT NULL;

-- Not imputing hemoglobin for 2nd and 3rd trimesters because we dont have corresponding hematocrit values

-- Data Correction, missing decimal point
UPDATE Laboratory_Test
SET hemoglobin_3rd_tri = '12.1'
WHERE case_id = 177;

--Dropping this column as it has values in only 4 rows out of 272 rows
ALTER TABLE Laboratory_Test DROP COLUMN "first_hr_ogtt75_1st_tri";

--Dropping this column as it has values in only 3 rows 
ALTER TABLE Laboratory_Test DROP COLUMN "second_hr_ogtt75_1st_tri";


-------------------------------------------VITALS Table Transformation-----------------------------------------------------------

-----Rename columns-----

alter table vitals rename  right_systolic_blood_pressure to  right_sbp;
alter table vitals rename right_diastolic_blood_pressure to right_dbp;
alter table vitals rename left_systolic_blood_pressure to left_sbp; 
alter table vitals rename left_diastolic_blood_pressure to left_dbp;

-----Replace text entries with NULL for consistency-----

UPDATE vitals
SET right_sbp = NULL
WHERE right_sbp IN ('', 'no_answer', 'not_applicable');

UPDATE vitals
SET right_dbp = NULL
WHERE right_dbp IN ('', 'no_answer', 'not_applicable');

UPDATE vitals
SET left_sbp = NULL
WHERE left_sbp IN ('', 'no_answer', 'not_applicable');

UPDATE vitals
SET left_dbp = NULL
WHERE left_dbp IN ('', 'no_answer', 'not_applicable');

-----Add calculated systolic (average of left & right if both exist)-----

ALTER TABLE vitals ADD COLUMN systolic_bp NUMERIC;

UPDATE vitals
SET systolic_bp = CASE
    WHEN right_sbp IS NOT NULL AND left_sbp IS NOT NULL
        THEN ROUND((
            NULLIF(right_sbp, '')::NUMERIC + 
            NULLIF(left_sbp, '')::NUMERIC
        ) / 2.0, 2)
    WHEN right_sbp IS NOT NULL
        THEN NULLIF(right_sbp, '')::NUMERIC
    WHEN left_sbp IS NOT NULL
        THEN NULLIF(left_sbp, '')::NUMERIC
    ELSE NULL
END;

-----Add calculated diastolic (average of left & right if both exist)-----

ALTER TABLE vitals ADD COLUMN diastolic_bp NUMERIC;

UPDATE vitals
SET diastolic_bp = CASE
    WHEN right_dbp IS NOT NULL AND left_dbp IS NOT NULL
        THEN ROUND((
            NULLIF(right_dbp, '')::NUMERIC + 
            NULLIF(left_dbp, '')::NUMERIC
        ) / 2.0, 2)
    WHEN right_dbp IS NOT NULL
        THEN NULLIF(right_dbp, '')::NUMERIC
    WHEN left_dbp IS NOT NULL
        THEN NULLIF(left_dbp, '')::NUMERIC
    ELSE NULL
END;

-----Example: case_id = 126 has invalid BP readings → set them NULL-----

UPDATE vitals
SET right_sbp  = NULL,
    right_dbp = NULL,
    left_sbp  = NULL,
    left_dbp  = NULL
WHERE case_id = 126;

-----dropping column-----

ALTER TABLE vitals
DROP COLUMN right_sbp;

ALTER TABLE vitals
DROP COLUMN right_dbp;

ALTER TABLE vitals
DROP COLUMN left_sbp;

ALTER TABLE vitals
DROP COLUMN left_dbp;

select * from vitals;

-------------------------------------------ULTRASOUND Table Transformation-----------------------------------------------------------


/* Rename column*/
alter table  Ultrasound
rename column periumbilical_subcutanous_fat to periumbilical_SAT;

alter table  Ultrasound
rename column preperitoneal_subcutaneous_fat to preperitoneal_SAT;

alter table  Ultrasound
rename column preperitoneal_visceral_fat to preperitoneal_VAT;

alter table  Ultrasound
rename column periumbilical_visceral_fat to periumbilical_VAT; 

update ultrasound set periumbilical_SAT = null where periumbilical_SAT = 'not_applicable' ;
update ultrasound set periumbilical_VAT = null where periumbilical_VAT = 'not_applicable' ;


/* changing data type*/  

alter table ultrasound
ALTER COLUMN periumbilical_SAT TYPE NUMERIC
USING periumbilical_SAT::NUMERIC;

ALTER TABLE ultrasound
ALTER COLUMN periumbilical_VAT TYPE NUMERIC
USING periumbilical_VAT::NUMERIC;

ALTER TABLE ultrasound
ALTER COLUMN periumbilical_total_fat TYPE NUMERIC
USING periumbilical_total_fat::NUMERIC;

 -----fill null value for case_id 9 by calculating from total_fat and vfat
update ultrasound set periumbilical_SAT = (periumbilical_total_fat - periumbilical_VAT) where case_id = 9;


/* changing data type*/
ALTER TABLE Ultrasound 
ALTER column preperitoneal_SAT TYPE Numeric
USING  preperitoneal_SAT::Numeric;

ALTER TABLE Ultrasound
ALTER column preperitoneal_VAT TYPE Numeric
USING preperitoneal_VAT::Numeric;

Update ultrasound
Set periumbilical_total_fat=(periumbilical_SAT+periumbilical_VAT) where periumbilical_total_fat is null and periumbilical_SAT > 0 and periumbilical_VAT > 0;

ALTER TABLE ultrasound 
ALTER COLUMN gestational_age_at_inclusion TYPE numeric(5,2)
USING gestational_age_at_inclusion ::numeric(5,2);

alter table  Ultrasound
rename column gestational_age_at_inclusion to gest_age_inclusion;

alter table  Ultrasound
rename column ultrasound_gestational_age to Gestational_age_at_Ultrasound;

UPDATE ultrasound
SET Gestational_age_at_Ultrasound = gest_age_inclusion
WHERE case_id = 282
  AND gest_age_inclusion IS NOT NULL;
 
 alter table  Ultrasound
rename column  fetal_weight_at_ultrasound to fetal_weight_ultrasound_grms;

update ultrasound set fetal_weight_ultrasound_grms = null where fetal_weight_ultrasound_grms = 'not_applicable'; ------throwing error as  column "fetal_weight_ultrasound" does not exist 

/*remove comma and .00 */
UPDATE ultrasound SET fetal_weight_ultrasound_grms = 
REPLACE(REPLACE(fetal_weight_ultrasound_grms, ',', ''), '.00', '');

Update Ultrasound
Set fetal_weight_ultrasound_grms = Null
Where fetal_weight_ultrasound_grms = 'not_applicable';

ALTER TABLE Ultrasound 
ALTER COLUMN fetal_weight_ultrasound_grms TYPE NUMERIC
USING fetal_weight_ultrasound_grms::NUMERIC;

update ultrasound set weight_fetal_percentile =
 5 where case_id = 283;

 UPDATE Ultrasound--------This is to categorise, replace the values
SET weight_fetal_percentile = CASE weight_fetal_percentile
    WHEN '0' THEN '10'
    WHEN '1' THEN '10-25'
    WHEN '2' THEN '25'
    WHEN '3' THEN '25-50'
    WHEN '4' THEN '50'
    WHEN '5' THEN '50-75'
    WHEN '6' THEN '75'
    WHEN '7' THEN '75-90'
    WHEN '8' THEN '90'
    ELSE weight_fetal_percentile  -- keep original if no match
END;




ALTER TABLE Ultrasound 
ALTER COLUMN gestational_age_at_ultrasound TYPE NUMERIC
USING gestational_age_at_ultrasound::NUMERIC;

UPDATE Ultrasound
SET weight_fetal_percentile = NULL
WHERE weight_fetal_percentile = 'not_applicable';





-------------------------------------------PREGNANCY HISTORY Table Transformation-----------------------------------------------------------


ALTER TABLE pregnancy_history
RENAME COLUMN past_newborn_1_weight TO FirstNB_wt_kgs;

ALTER TABLE pregnancy_history
RENAME COLUMN gestational_age_past_newborn_1 TO FirstNB_gest_status;

ALTER TABLE pregnancy_history
RENAME COLUMN past_newborn_2_weight TO SecondNB_wt_kgs;

ALTER TABLE pregnancy_history
RENAME COLUMN gestational_age_past_newborn_2 TO SecondNB_gest_status;

ALTER TABLE pregnancy_history
RENAME COLUMN past_newborn_3_weight TO ThirdNB_Wt_kgs;

ALTER TABLE pregnancy_history
RENAME COLUMN gestational_age_past_newborn_3 TO ThirdNB_gest_status;

ALTER TABLE pregnancy_history
RENAME COLUMN past_newborn_4_weight TO FourthNB_Wt_kgs;

ALTER TABLE pregnancy_history
RENAME COLUMN gestational_age_past_4_newborn TO FourthNB_gest_status;

ALTER TABLE pregnancy_history
RENAME COLUMN past_pregnancies_number TO no_of_past_pregnancies;

-------------------updated NA and no_answer to NULL------------------------------------

UPDATE public.pregnancy_history
SET
FirstNB_wt_kgs = ROUND(
CAST(
CASE
WHEN FirstNB_wt_kgs IN ('not_applicable','', 'no_answer') THEN NULL
ELSE REPLACE(FirstNB_wt_kgs, ',', '')
END AS NUMERIC
) / 1000.0, 1
),
FirstNB_gest_status = CAST(
CASE
WHEN FirstNB_gest_status IN ('not_applicable','', 'no_answer') THEN NULL
ELSE FirstNB_gest_status
END AS NUMERIC
),
SecondNB_wt_kgs = ROUND(
CAST(
CASE
WHEN SecondNB_wt_kgs IN ('not_applicable','', 'no_answer') THEN NULL
ELSE REPLACE(SecondNB_wt_kgs, ',', '')
END AS NUMERIC
) / 1000.0, 1
),
SecondNB_gest_status = CAST(
CASE
WHEN SecondNB_gest_status IN ('not_applicable','', 'no_answer') THEN NULL
ELSE SecondNB_gest_status
END AS NUMERIC
),
ThirdNB_Wt_kgs = ROUND(
CAST(
            CASE
                WHEN ThirdNB_Wt_kgs IN ('not_applicable','', 'no_answer') THEN NULL
                ELSE REPLACE(ThirdNB_Wt_kgs, ',', '')
            END AS NUMERIC
        ) / 1000.0, 1
    ),

    ThirdNB_gest_status = CAST(
        CASE
            WHEN ThirdNB_gest_status IN ('not_applicable','', 'no_answer') THEN NULL
            ELSE ThirdNB_gest_status
        END AS NUMERIC
    ),

    FourthNB_Wt_kgs = ROUND(
        CAST(
            CASE
                WHEN FourthNB_Wt_kgs IN ('not_applicable','', 'no_answer') THEN NULL
                ELSE REPLACE(FourthNB_Wt_kgs, ',', '')
            END AS NUMERIC
        ) / 1000.0, 1
    ),

    FourthNB_gest_status = CAST(
        CASE
            WHEN FourthNB_gest_status IN ('not_applicable','', 'no_answer') THEN NULL
            ELSE FourthNB_gest_status
        END AS NUMERIC
    ),

    no_of_past_pregnancies = CAST(no_of_past_pregnancies AS NUMERIC),

    miscarriage = CASE
        WHEN miscarriage::text IN ('not_applicable','', 'no_answer') THEN NULL
        WHEN miscarriage::numeric = 0 THEN 0
        WHEN miscarriage::numeric IN (1,2,3) THEN 1
        ELSE NULL
    END;


---------------------working on prepregnancy_number-----------------

ALTER TABLE pregnancy_history
ALTER COLUMN no_of_past_pregnancies TYPE NUMERIC USING no_of_past_pregnancies::NUMERIC;

UPDATE public.pregnancy_history
SET no_of_past_pregnancies = 
(CASE 
WHEN no_of_past_pregnancies IS NOT NULL THEN no_of_past_pregnancies
ELSE
(CASE WHEN FirstNB_wt_kgs IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN SecondNB_gest_status IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN ThirdNB_gest_status IS NOT NULL THEN 1 ELSE 0 END +
CASE WHEN FourthNB_gest_status IS NOT NULL THEN 1 ELSE 0 END)
END);

--updating miscarriage_flag 
ALTER TABLE public.pregnancy_history
ALTER COLUMN miscarriage TYPE text;

UPDATE public.pregnancy_history
SET miscarriage = 
CASE 
WHEN miscarriage::numeric = 0 THEN 'No'
WHEN miscarriage::numeric IN (1,2,3) THEN 'Yes'
ELSE NULL
END;


ALTER TABLE pregnancy_history
ALTER COLUMN FirstNB_wt_kgs TYPE NUMERIC USING FirstNB_wt_kgs::NUMERIC,
ALTER COLUMN FirstNB_gest_status TYPE NUMERIC USING FirstNB_gest_status::NUMERIC,
ALTER COLUMN SecondNB_wt_kgs TYPE NUMERIC USING SecondNB_wt_kgs::NUMERIC,
ALTER COLUMN SecondNB_gest_status TYPE NUMERIC USING SecondNB_gest_status::NUMERIC,
ALTER COLUMN ThirdNB_wt_kgs TYPE NUMERIC USING ThirdNB_wt_kgs::NUMERIC,
ALTER COLUMN ThirdNB_gest_status TYPE NUMERIC USING ThirdNB_gest_status::NUMERIC,
ALTER COLUMN FourthNB_wt_kgs TYPE NUMERIC USING FourthNB_wt_kgs::NUMERIC,
ALTER COLUMN FourthNB_gest_status TYPE NUMERIC USING FourthNB_gest_status::NUMERIC;

-------------------------------------------HOSPITATLIZATION_LABOR Table Transformation-----------------------------------------------------------

---Delivery_mode column transformation
UPDATE public.Hospitalization_Labor
SET delivery_mode = 
CASE
    WHEN delivery_mode = '1' THEN 'vaginal'
        WHEN delivery_mode = '2' THEN 'vaginal forcipe'
        WHEN delivery_mode = '3' THEN 'miscarriage with curettage'
        WHEN delivery_mode = '4' THEN 'miscarriage without curettage'
        WHEN delivery_mode = '5' THEN 'cesarean section'
        WHEN delivery_mode = '6' THEN 'cesarean by jeopardy'
        WHEN delivery_mode = '7' THEN 'vaginal with episiotomy'
        WHEN delivery_mode = '8' THEN 'vaginal without episiotomy'
        WHEN delivery_mode = '9' THEN 'vaginal with episiotomy plus forcipe'
        WHEN delivery_mode = '12' AND (cesarean_section_reason ='previa' OR cesarean_section_reason ='breech presentation') THEN 'cesarean by jeopardy'
		
		WHEN delivery_mode = '12' AND (cesarean_section_reason ='previous cesarean section' OR cesarean_section_reason = 'eletiva') THEN 'cesarean section'
    	
	ELSE NULL
END;                    

---cesarean_section_reason column transformation
UPDATE public.Hospitalization_Labor
SET cesarean_section_reason = 
CASE
    WHEN cesarean_section_reason = 'not_applicable' THEN null
        WHEN cesarean_section_reason = 'no_answer' THEN null
                WHEN cesarean_section_reason = ' ' THEN null
        WHEN cesarean_section_reason = '8' THEN null
        WHEN cesarean_section_reason = '12' THEN 'elective cesarean section'
        WHEN cesarean_section_reason = 'previa' THEN 'placenta previa'
        WHEN cesarean_section_reason = 'eletiva' THEN 'elective cesarean section'
        ELSE cesarean_section_reason 
      
END;

---prepartum_maternal_heigh, prepartum_maternal_weight column transformation
/* Renaming the column prepartum_maternal_weight to prepartum_maternal_wt_kgs. */
ALTER TABLE Hospitalization_Labor
RENAME COLUMN prepartum_maternal_weight TO prepartum_maternal_wt_kgs;

/* Renaming the column prepartum_maternal_heigh to prepartum_maternal_ht_mtrs. */
ALTER TABLE Hospitalization_Labor
RENAME COLUMN prepartum_maternal_heigh TO prepartum_maternal_ht_mtrs;

/* Replacing not-applicable to nulls in these two columns. for clarity during analysis. These are lost to follow-up. Hence, changing them to nulls. */
UPDATE Hospitalization_Labor
SET prepartum_maternal_wt_kgs = NULL
WHERE prepartum_maternal_wt_kgs = 'not_applicable';

UPDATE Hospitalization_Labor
SET prepartum_maternal_ht_mtrs = NULL
WHERE prepartum_maternal_ht_mtrs = 'not_applicable';

ALTER TABLE Hospitalization_Labor
ALTER COLUMN prepartum_maternal_wt_kgs TYPE NUMERIC(6,1) USING ROUND(prepartum_maternal_wt_kgs::NUMERIC,1),
ALTER COLUMN prepartum_maternal_ht_mtrs TYPE NUMERIC(2,1) USING ROUND(prepartum_maternal_ht_mtrs::NUMERIC,1);

-- Filled with the height from height at inclusion
UPDATE Hospitalization_Labor h
SET prepartum_maternal_ht_mtrs = o.ht_inclusion_mtrs
FROM demographics o
WHERE h.case_id = o.case_id
  AND h.prepartum_maternal_ht_mtrs IS NULL;


---hospital_diastolic_blood_pressure  and hospital_systolic_blood_pressure column transformation  
ALTER TABLE Hospitalization_Labor
RENAME COLUMN hospital_systolic_blood_pressure TO Hospital_SBP;

ALTER TABLE Hospitalization_Labor
RENAME COLUMN hospital_diastolic_blood_pressure TO Hospital_DBP;

-- Fix invalid systolic values
UPDATE Hospitalization_Labor
SET Hospital_SBP = NULL
WHERE Hospital_SBP::text ILIKE 'not_applicable' 
   OR Hospital_SBP::text = '';

-- Fix invalid diastolic values
UPDATE Hospitalization_Labor
SET Hospital_DBP = NULL
WHERE Hospital_DBP::text ILIKE 'not_applicable' 
   OR Hospital_DBP::text = '';

ALTER TABLE Hospitalization_Labor
ALTER COLUMN Hospital_SBP TYPE INT USING Hospital_SBP::INT,
ALTER COLUMN Hospital_DBP TYPE INT USING Hospital_DBP::INT;

--Swapped the Diastolic with Systolic and Systollic with Diastolic when the Diastolic is greater than Systolic

UPDATE Hospitalization_Labor
SET 
    Hospital_SBP = Hospital_DBP,
    Hospital_DBP = Hospital_SBP
WHERE 
    Hospital_SBP IS NOT NULL AND
    Hospital_DBP IS NOT NULL AND
    Hospital_SBP < Hospital_DBP;  

---hospital_hypertension column transformation
ALTER TABLE Hospitalization_Labor
ALTER COLUMN hospital_hypertension TYPE varchar(50);

-- for these case_ids - 22,48, 64, 164, 182,187, 252, 234
-- if the systolic or Diastolic BP is higher in range update with htn as 1
UPDATE Hospitalization_Labor
SET hospital_hypertension = '1'
WHERE (Hospital_SBP >= 140
   OR Hospital_DBP >= 90) ;


UPDATE Hospitalization_Labor
SET hospital_hypertension = CASE
        WHEN hospital_hypertension = '0' THEN 'No'
        WHEN hospital_hypertension = '1' THEN 'Yes'
        ELSE NULL
END;

---gestational_diabetes_mellitus column transformation
ALTER TABLE Hospitalization_Labor
RENAME COLUMN gestational_diabetes_mellitus TO hosp_gest_DM;

ALTER TABLE Hospitalization_Labor
ALTER COLUMN hosp_gest_DM TYPE varchar(50);

UPDATE Hospitalization_Labor
SET hosp_gest_DM = CASE
	WHEN hosp_gest_DM = '0' THEN 'No'
	WHEN hosp_gest_DM = '1' THEN 'Yes'
	ELSE NULL
END;

---gestational_diabetes_mellitus column transformation
UPDATE public.Hospitalization_Labor
SET disease_diagnose_during_pregnancy = 
CASE
    WHEN disease_diagnose_during_pregnancy = 'depression + ITU' THEN 'Depression|Urinary Tract Infection'
        WHEN disease_diagnose_during_pregnancy IN ('depression','Depression') THEN 'Depression'
        WHEN disease_diagnose_during_pregnancy = 'asthma and depression' THEN 'Asthma|Depression'
        WHEN disease_diagnose_during_pregnancy = 'pre-eclampsia' THEN 'Pre-eclampsia'
        WHEN disease_diagnose_during_pregnancy IN ('itu','ITU') THEN 'Urinary Tract Infection'
        WHEN disease_diagnose_during_pregnancy = 'lactose intolerance' THEN 'Lactose Intolerance'
        WHEN disease_diagnose_during_pregnancy = 'not_applicable+CX20' THEN 'Cervix is 20mm'
        WHEN disease_diagnose_during_pregnancy in('has','Has','HAS') THEN 'Hypertension Arterial System'
        WHEN disease_diagnose_during_pregnancy = 'Gestational thrombocytopenia and gestational hypothyroidism and NT' THEN 'Gestational Thrombocytopenia|Gestational Hypothyroidism|NT'
        WHEN disease_diagnose_during_pregnancy = 'hypothyroidism' THEN 'Hypothyroidism' 

        WHEN disease_diagnose_during_pregnancy = 'asthma and bronchitis and pre-eclampsia' THEN 'Asthma|Bronchitis|Pre-eclampsia'
        WHEN disease_diagnose_during_pregnancy = 'Pre-eclampsia and has gestational' THEN 'Pre-eclampsia|Hypertension Arterial System Gestational"
'
        WHEN disease_diagnose_during_pregnancy = 'HAS +DMG' THEN 'Hypertension Arterial System|Gestational Diabetes Mellitus'
        WHEN disease_diagnose_during_pregnancy = 'VDRL +' THEN 'VDRL Syphilis Test'
        WHEN disease_diagnose_during_pregnancy = 'depression and glaucoma and alcoholism' THEN 'Depression|Glaucoma|Alcoholism'
        WHEN disease_diagnose_during_pregnancy = 'hyperthyroidism' THEN 'Hyperthyroidism'
        WHEN disease_diagnose_during_pregnancy = 'HIV' THEN 'HIV'
        WHEN disease_diagnose_during_pregnancy = 'endocardite' THEN 'Endocarditis'
        WHEN disease_diagnose_during_pregnancy = 'DMG' THEN 'Gestational Diabetes Mellitus'
        WHEN disease_diagnose_during_pregnancy = 'hepatitis c' THEN 'Hepatitis c'
        WHEN disease_diagnose_during_pregnancy = 'gestational hypothyroidism' THEN 'Gestational Hypothyroidism'
        WHEN disease_diagnose_during_pregnancy = 'Cognitive deficit - depression + HAS Gestation' THEN 'Cognitive Deficit|Depression|Hypertension Arterial System Gestation'
        WHEN disease_diagnose_during_pregnancy in ('Asthma','asthma') THEN 'Asthma'
        WHEN disease_diagnose_during_pregnancy = 'colestase' THEN 'Cholestasis'
        WHEN disease_diagnose_during_pregnancy = 'DM' THEN 'Diabetes Mellitus'
        WHEN disease_diagnose_during_pregnancy = 'Has + DMG' THEN 'Hypertension Arterial System|Gestational Diabetes Mellitus'
        WHEN disease_diagnose_during_pregnancy = 'ischemic stroke without sequelae' THEN 'Ischemic Stroke Without Sequelae'
        WHEN disease_diagnose_during_pregnancy = 'hepatitis b and ITU' THEN 'Hepatitis b|Urinary Tract Infection'
        WHEN disease_diagnose_during_pregnancy LIKE '%Has secund%' THEN 'Secondary Arterial Hypertension'
        WHEN disease_diagnose_during_pregnancy = 'anxiety' THEN 'Anxiety'
        WHEN disease_diagnose_during_pregnancy = 'bronchitis, itu' THEN 'Bronchitis|Urinary Tract Infection'
        WHEN disease_diagnose_during_pregnancy = 'HAS na baixa hospitalar' THEN 'Hypertension at Discharge'
        WHEN disease_diagnose_during_pregnancy = 'Strepto + ITU' THEN 'Streptococcus|Urinary Tract Infection'
        WHEN disease_diagnose_during_pregnancy = 'thb' THEN 'Tuberculosis'
        WHEN disease_diagnose_during_pregnancy = 'Pyelonephritis + depression' THEN 'Pyelonephritis|Depression'
        WHEN disease_diagnose_during_pregnancy = 'hypothyroidism and syphilis' THEN 'Hypothyroidism|Syphilis'
        WHEN disease_diagnose_during_pregnancy = 'syphilis' THEN 'Syphilis'
   
    ELSE NULL
END;

UPDATE public.Hospitalization_Labor SET disease_diagnose_during_pregnancy = 'Gestational Hypothyroidism' where case_id =161;

---treatment_disease_pregnancy column transformation
UPDATE hospitalization_labor
SET treatment_disease_pregnancy = CASE
        WHEN treatment_disease_pregnancy = 'Sem tto' THEN 'No Medication'
        WHEN treatment_disease_pregnancy = 'Sem TTo' THEN 'No Medication'
		WHEN treatment_disease_pregnancy = 'sim' THEN 'Yes Medication'
        WHEN treatment_disease_pregnancy = 'Fluxetina' THEN 'Fluoxetine'
        WHEN treatment_disease_pregnancy = 'Medicamento' THEN 'Medication'
        WHEN treatment_disease_pregnancy = 'insulina' THEN 'Insulin'
        WHEN treatment_disease_pregnancy = 'predinisolona' THEN 'Prednisolone'
        WHEN treatment_disease_pregnancy = 'aspirina' THEN 'Aspirin'
        WHEN treatment_disease_pregnancy = 'Metildopa' THEN 'Methyldopa'
        WHEN treatment_disease_pregnancy = 'tapazol' THEN 'Tapazole'
        WHEN treatment_disease_pregnancy = 'metformina' THEN 'Metformin'
        WHEN treatment_disease_pregnancy = 'medicamento' THEN 'Medication'
		WHEN treatment_disease_pregnancy = 'ac valproico,' THEN 'valproic acid'
       	WHEN treatment_disease_pregnancy = 'not_applicable' THEN null   
		WHEN treatment_disease_pregnancy = ' ' THEN null 
		WHEN treatment_disease_pregnancy IN ('0','45') THEN null 
	   ELSE treatment_disease_pregnancy
END;       

---chronic_diseases column transformation 
ALTER TABLE Hospitalization_Labor
RENAME COLUMN chronic_diseases TO chronic_diseases_hosp_eval;

ALTER TABLE Hospitalization_Labor
ALTER COLUMN chronic_diseases_hosp_eval TYPE varchar(50);

UPDATE Hospitalization_Labor
SET chronic_diseases_hosp_eval = NULL
WHERE chronic_diseases_hosp_eval = 'not_applicable';

/* Replacing the binary values in this column to Yes and No for clarity during analysis */
UPDATE Hospitalization_Labor
SET chronic_diseases_hosp_eval = CASE
        WHEN chronic_diseases_hosp_eval = '0' THEN 'No'
        WHEN chronic_diseases_hosp_eval = '1' THEN 'Yes'
        ELSE chronic_diseases_hosp_eval
END;

---preeclampsia_record_pregnancy column transformation 
ALTER TABLE Hospitalization_Labor
ALTER COLUMN preeclampsia_record_pregnancy TYPE varchar(50);


UPDATE Hospitalization_Labor
SET preeclampsia_record_pregnancy = CASE
        WHEN preeclampsia_record_pregnancy = '0' THEN 'No'
        WHEN preeclampsia_record_pregnancy = '1' THEN 'Yes'
        ELSE null                                                                                                                         END;
END;


--chronic_diabetes column transformation
--Fix case_id 88 and 118 values from 888/88888 to '0'
UPDATE Hospitalization_Labor
SET chronic_diabetes = '0'
WHERE case_id IN (88, 118);

ALTER TABLE Hospitalization_Labor
ALTER COLUMN chronic_diabetes TYPE varchar(50);

UPDATE public.Hospitalization_Labor
SET chronic_diabetes = 
CASE
    WHEN chronic_diabetes = '0' THEN 'No'
        WHEN chronic_diabetes = '1' THEN 'Yes'        
        ELSE null           
END;

-- Prenatal_Appointments

ALTER TABLE Hospitalization_Labor
RENAME COLUMN number_prenatal_appointments TO prenatal_appointments;

ALTER TABLE Hospitalization_Labor
ALTER COLUMN prenatal_appointments TYPE INT USING prenatal_appointments::INT;

---Mothers Hospital Stay

ALTER TABLE Hospitalization_Labor
ALTER COLUMN mothers_hospital_stay TYPE INT USING mothers_hospital_stay::INT;



-------------------------------------------ANTHROPOMETRY Table Transformation-----------------------------------------------------------



-- Anthropomentry Table Cleaning Steps
-- renaming the columns for first, sceond and third trimester  

alter table Anthropometry
rename column current_maternal_weight_1st_tri to maternal_wt_1st_tri;

alter table Anthropometry
rename column current_maternal_weight_2nd_tri to maternal_wt_2nd_tri;

alter table Anthropometry
rename column current_maternal_weight_3rd_tri to maternal_wt_3rd_tri;

-- Replace all not-applicable values to null for datatype change. other column doesnt have not-applicable 
UPDATE Anthropometry SET maternal_wt_1st_tri = NULL WHERE maternal_wt_1st_tri !~ '^[0-9]+(\.[0-9]+)?$';

UPDATE Anthropometry SET maternal_wt_2nd_tri = NULL WHERE maternal_wt_2nd_tri !~ '^[0-9]+(\.[0-9]+)?$';

UPDATE Anthropometry SET maternal_wt_3rd_tri = NULL WHERE maternal_wt_3rd_tri !~ '^[0-9]+(\.[0-9]+)?$';

-- Datatype change
ALTER TABLE Anthropometry
ALTER COLUMN maternal_wt_1st_tri TYPE numeric
USING maternal_wt_1st_tri:: numeric,

ALTER COLUMN maternal_wt_2nd_tri TYPE numeric  
USING maternal_wt_2nd_tri:: numeric,
		
ALTER COLUMN maternal_wt_3rd_tri TYPE numeric 
USING maternal_wt_3rd_tri:: numeric;

ALTER TABLE Anthropometry
ALTER COLUMN maternal_brachial_circumference TYPE numeric
USING maternal_brachial_circumference:: numeric,

ALTER COLUMN circumference_maternal_calf TYPE numeric  
USING circumference_maternal_calf:: numeric,
		
ALTER COLUMN maternal_neck_circumference TYPE numeric 
USING maternal_neck_circumference:: numeric,

ALTER COLUMN maternal_waist_circumference TYPE numeric
USING maternal_waist_circumference:: numeric,

ALTER COLUMN maternal_hip_circumference TYPE numeric  
USING maternal_hip_circumference:: numeric,
		
ALTER COLUMN mean_tricciptal_skinfold TYPE numeric 
USING mean_tricciptal_skinfold:: numeric,

ALTER COLUMN mean_subscapular_skinfold TYPE numeric  
USING mean_subscapular_skinfold:: numeric,
		
ALTER COLUMN mean_supra_iliac_skin_fold TYPE numeric 
USING mean_supra_iliac_skin_fold:: numeric;

-- Updating the outlier 999 with null because its considered as missing data, where first_trimster_weight is very less
UPDATE Anthropometry SET maternal_wt_3rd_tri = null WHERE case_id = 237 
AND maternal_wt_3rd_tri = '999';

--Update current_maternal_weight_3rd_tri to the prepartum_maternal_weight for people admitted in hospital for delivery in 3rd trimester

UPDATE anthropometry a
SET maternal_wt_3rd_tri = h.prepartum_maternal_wt_kgs
FROM Hospitalization_Labor h
WHERE h.case_id = a.case_id AND h.prepartum_maternal_wt_kgs is not null 
AND a.maternal_wt_3rd_tri IS NULL;

-- Updating the current_maternal_weight_3rd_tri to maternal_weight_at_inclusion
--if the current_maternal_weight_3rd_tri IS NULL and gestational_age_at_inclusion>=27
UPDATE anthropometry a   	
SET maternal_wt_3rd_tri = d.maternal_weight_at_inclusion
FROM  demographics d , ultrasound u
WHERE d.case_id = a.case_id and  u.case_id = a.case_id
AND d.maternal_weight_at_inclusion is not null 
and a.maternal_wt_3rd_tri IS NULL AND u.gest_age_inclusion>=27;

-- Updating the current_maternal_weight_2nd_tri to maternal_weight_at_inclusion 
--if the current_maternal_weight_2nd_tri IS NULL and gestational_age_at_inclusion >=14 and gestational_age_at_inclusion < 27

UPDATE anthropometry a
SET maternal_wt_2nd_tri = d.maternal_weight_at_inclusion
FROM demographics d , ultrasound u
WHERE d.case_id = a.case_id  and u.case_id = a.case_id
AND a.maternal_wt_2nd_tri IS NULL and d.maternal_weight_at_inclusion is not null
and u.gest_age_inclusion >=14 and u.gest_age_inclusion < 27;

-- Updating the current_maternal_weight_1st_tri to maternal_weight_at_inclusion 
--if the current_maternal_weight_1st_tri IS NULL and gestational_age_at_inclusion<14

UPDATE anthropometry a
SET maternal_wt_1st_tri = d.maternal_weight_at_inclusion
FROM demographics d , ultrasound u
WHERE d.case_id = a.case_id and u.case_id = a.case_id
AND d.maternal_weight_at_inclusion is not null 
and a.maternal_wt_1st_tri IS NULL AND u.gest_age_inclusion<14;




-------------------------------------------NEWBORN TABLE Transformation-----------------------------------------------------------


/*Datatype change varchar to numeric(6,2) and remove commas from expected_newborn_weight */
ALTER TABLE Newborn
ALTER COLUMN expected_weight_for_the_newborn TYPE NUMERIC(6,2)
USING REPLACE(expected_weight_for_the_newborn, ',', '')::NUMERIC(6,2);

/*Converting expected_weight_for_the_newborn to kg */
UPDATE Newborn
SET expected_weight_for_the_newborn = expected_weight_for_the_newborn/ 1000;

/*rename column expected_weight_for_the_newborn to exp_newborn_wt_kg*/
ALTER TABLE Newborn
RENAME COLUMN expected_weight_for_the_newborn TO exp_newborn_wt_kg;
—-------------------------------------------------------


/*Datatype change varchar to numeric(6,2) and remove commas from newborn_weight */
ALTER TABLE Newborn
ALTER COLUMN newborn_weight TYPE NUMERIC(6,2)
USING REPLACE(newborn_weight, ',', '')::NUMERIC(6,2);

/*Converting newborn_weight to kg */
UPDATE Newborn
SET newborn_weight = newborn_weight/ 1000;

/*rename column newborn_weight to newborn_wt_kg*/
ALTER TABLE Newborn
RENAME COLUMN newborn_weight TO newborn_wt_kg;
—----------------------------------------------------------


/* Replace ‘not-applicable’ as NULL for newborn_height*/
UPDATE Newborn
SET newborn_height = NULL
WHERE newborn_height = 'not_applicable';
/*Datatype change varchar to numeric(5,2) for newborn_height */
ALTER TABLE Newborn
ALTER COLUMN newborn_height TYPE NUMERIC(5,2)
USING NULLIF(TRIM( newborn_height), '')::NUMERIC(5,2);


/*rename column newborn_height to newborn_ht*/
ALTER TABLE Newborn
RENAME COLUMN newborn_height TO newborn_ht;
—---------------------------------------------------------------


/*Datatype change varchar to numeric(5,2) for gestational_age_at_birth */
ALTER TABLE Newborn
ALTER COLUMN gestational_age_at_birth TYPE NUMERIC(5,2)
USING NULLIF(TRIM( gestational_age_at_birth), '')::NUMERIC(5,2);

/*rename column gestational_age_at_birth to gest_age_birth*/
ALTER TABLE Newborn
RENAME COLUMN gestational_age_at_birth TO gest_age_birth;
—---------------------------------------------------------------------


/* Replace ‘not-applicable’ as NULL for newborn_head_circumference*/
UPDATE Newborn
SET newborn_head_circumference = NULL
WHERE newborn_head_circumference = 'not_applicable';

/*Datatype change varchar to numeric(5,2) for newborn_head_circumference */
ALTER TABLE Newborn
ALTER COLUMN newborn_head_circumference TYPE NUMERIC(5,2)
USING NULLIF(TRIM( newborn_head_circumference), '')::NUMERIC(5,2);


/*rename column newborn_head_circumference to newborn_head_circum*/
ALTER TABLE Newborn
RENAME COLUMN newborn_head_circumference TO newborn_head_circum;
—-------------------------------------------------------------------


/*Datatype change varchar to numeric(5,2) for thoracic_perimeter_newborn */
ALTER TABLE Newborn
ALTER COLUMN thoracic_perimeter_newborn TYPE NUMERIC(5,2)
USING NULLIF(TRIM( thoracic_perimeter_newborn), '')::NUMERIC(5,2);

/*rename column thoracic_perimeter_newborn to newborn_thor_perim*/
ALTER TABLE Newborn
RENAME COLUMN thoracic_perimeter_newborn TO newborn_thor_perim;
—--------------------------------------------------------------------


/*update meconium_labor*/
UPDATE Newborn
SET meconium_labor = '0'
WHERE meconium_labor IS NULL
AND apgar_1st_min  > '7' 
AND apgar_5th_min > '7'
AND newborn_intubation = '0';


/*Replacing 0 to no and 1 to yes for meconium_labor */
UPDATE Newborn
SET meconium_labor = CASE
WHEN meconium_labor = '1' THEN 'Yes'
	 WHEN meconium_labor = '0' THEN 'No'
	 ELSE NULL
END;
—---------------------------------------------------------------------


/*Datatype change varchar to INT for apgar_1st_min */
ALTER TABLE Newborn
ALTER COLUMN apgar_1st_min TYPE INT
USING NULLIF(TRIM( apgar_1st_min), '')::INT;

/* Replace 99 to 9 for apgar_1st_min as this is considered as typo*/
UPDATE Newborn
SET apgar_1st_min = 9
WHERE apgar_1st_min = 99;

/*rename column apgar_1st_min to apgar_min1*/
ALTER TABLE Newborn
RENAME COLUMN apgar_1st_min TO apgar_min1;
—-------------------------------------------------------------------


/*Datatype change varchar to INT for apgar_5th_min */
ALTER TABLE Newborn
ALTER COLUMN apgar_5th_min TYPE INT
USING NULLIF(TRIM( apgar_5th_min), '')::INT;


/*rename column apgar_5th_min to apgar_min5*/
ALTER TABLE Newborn
RENAME COLUMN apgar_5th_min TO apgar_min5;
—-------------------------------------------------------------------


/*Replacing 0 to no and 1 to yes for pediatric_resuscitation_maneuvers */
UPDATE Newborn
SET pediatric_resuscitation_maneuvers = 
CASE WHEN pediatric_resuscitation_maneuvers = '1' THEN 'Yes'
	 WHEN pediatric_resuscitation_maneuvers = '0' THEN 'No'
	 ELSE NULL
END;

/*rename column pediatric_resuscitation_maneuvers to ped_resus_man*/
ALTER TABLE Newborn
RENAME COLUMN pediatric_resuscitation_maneuvers TO ped_resus_man;
—---------------------------------------------------------------------


/*Replacing 0 to no and 1 to yes for newborn_intubation */
UPDATE Newborn
SET newborn_intubation = 
CASE WHEN newborn_intubation = '1' THEN 'Yes'
	 WHEN newborn_intubation = '0' THEN 'No'
	 ELSE NULL
END;
—-----------------------------------------------------------------------

/*Replacing 0 to no and 1 to yes for newborn_airway_aspiration */
UPDATE Newborn
SET newborn_airway_aspiration = 
CASE WHEN newborn_airway_aspiration = '1' THEN 'Yes'
	 WHEN newborn_airway_aspiration = '0' THEN 'No'
	 ELSE NULL
END;

/*rename newborn_airway_aspiration to newborn_asp*/
ALTER TABLE Newborn
RENAME COLUMN newborn_airway_aspiration TO newborn_asp;

----------------------------------------------------------------------------------------------------------------------


/* Deleting the raw table as it is affecting the ER Diagram */
Drop table IF EXISTS mh_observations;

