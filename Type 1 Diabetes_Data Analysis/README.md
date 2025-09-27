
# HUPA-UCM Diabetes Dataset Analysis

## Description about the Dataset

The **HUPA-UCM Diabetes Dataset** is a real-world collection of multimodal physiological and lifestyle data from 25 patients with **Type 1 Diabetes Mellitus (T1DM)**.  Data was gathered at the **Hospital Príncipe de Asturias (Spain)** over a monitoring period of at least 14 consecutive days per patient. Data sources include:

- **Continuous Glucose Monitoring (CGM):**  
  Collected using **FreeStyle Libre 2** sensors, providing interstitial glucose readings at regular intervals.

- **Insulin Administration:**  
  - Basal insulin doses (background insulin).  
  - Bolus insulin doses (meal-related or correction doses).  
  Both administered and recorded by **Medtronic Insulin Pump & Sensor**.

- **Meal Records:**  
  Carbohydrate intake measured as servings for each ingestion (1 serving = 10 g).  
  Aligned with bolus doses.

- **Wearable Activity & Lifestyle Data:**  
  Collected using **Fitbit Ionic smartwatches**:  
  - Steps and overall physical activity  
  - Calories burned  
  - Heart rate (continuous monitoring)  
  - Sleep duration, quality, and disturbances  

- **Demographics:**  
  Patient-level information such as age, gender, and clinical background.

This dataset enables **integrated analysis** across glucose control, insulin dosing, lifestyle behaviors, and sleep health.  
It is structured in **CSV files (one per patient)**, harmonized at 5-minute intervals after preprocessing.

---

## Problem Statement

Type 1 Diabetes patients face continuous challenges in balancing **glucose levels, insulin therapy, diet, activity, and sleep**.  
Poor glycemic control can lead to **hypoglycemia, hyperglycemia, or long-term organ damage**.

**Central Problem:**  
How can integrated patient data (CGM, insulin, meals, activity, and sleep) be analyzed to better understand glucose patterns, predict risk events, and support improved disease management strategies?

This problem aims to support:  
- Personalized treatment  
- Automated glucose prediction systems  
- Decision-support tools such as **artificial pancreas models**

---

## Methods & Analysis

Our workflow was divided into three main stages:

### 1. Data Cleaning & Preprocessing
- Merged CGM data of 25 patients into one dataframe with `patient_id`  
- Joined with demographics & sleep data  
- Verified every patient had both CGM and demographic/sleep records  
- Checked for null values and outliers  
- Rounded floats to two decimals  
- Fixed negative insulin values (e.g., bolus volume set to 0)  
- Converted time columns to `datetime`  
- Created `day_label` column (Day 1–14)  
- Exported cleaned dataset to Excel  

### 2. Descriptive Analysis
- **Glucose Profiles:** Average, min, max, SD, time in ranges (<70, 70–180, >180)  
- **Insulin Usage:** Basal vs bolus averages  
- **Nutrition:** Daily carb intake patterns  
- **Physical Activity:** Steps, calories burned  
- **Sleep Patterns:** Duration, quality, disturbances  
- **Demographics:** Age and gender distributions  

### 3. Prescriptive Analysis
We developed **actionable clinical questions** grouped into key areas:

- **Glucose & Insulin Management:** Adjust bolus ratios, basal profiles, correction bolus optimization, pump features  
- **Carbohydrate & Meal Planning:** Insulin-to-carb ratio consistency, carb distribution, GI foods, snack timing  
- **Exercise & Activity:** Effects of aerobic/anaerobic activity, basal reduction, activity thresholds  
- **Sleep & Lifestyle:** Sleep quality correlations, shift work adjustments, bedtime snacks, stress management  

---

## Key Findings
*(Summarize findings here when analysis is complete)*

### Glucose and Insulin Management

- **Basal - Bolus Split:** The ratio of how much of a person’s total daily insulin comes from basal insulin (background insulin) versus bolus insulin (mealtime/correction insulin). Maintaining a good balance between Basal and Bolus Insulin is an important factor in maintaining steady glucose values and increasing Time in Range (TIR).

- **Insulin-to-Carb Ratio (ICR):** Determines how many grams of carbohydrate are covered by 1 unit of rapid-acting insulin. Finding the perfect ICR for each individual helps to maintain steady glucose values and increases TIR. For patients spending >25% time in Hyperglycemia, it is recommended that they reduce the ICR to improve their TIR.

- **Time to Peak:** The time taken for blood glucose to reach its highest value after a meal. Blood glucose levels should stay within range after meals. Rapid and steep rise in blood glucose levels increases glucose variability (GV%) and indicates that the bolus insulin may need to be increased to control blood sugars more effectively.

- **Dawn Phenomenon:** The Dawn Phenomenon (sometimes called the dawn effect) is the natural rise in blood glucose in the early morning hours. Analysis indicates that for patients experiencing hyperglycemia due to dawn phenomenon, the dosage of basal insulin released by the pump in the early morning hours be increased.

### Sleep and Lifestyle Analysis  

- **Sleep and Glucose Stability are Closely Linked:** Poor sleep quality, frequent disturbances, or insomnia proxies are associated with higher glucose variability (GV%) and lower TIR.  

- **Sleep Quantity vs. Quality:** Many patients do not achieve the recommended 7+ hours of sleep, and even those who do often have poor sleep quality, showing that both quantity and restfulness matter.  

- **Insomnia and Morning Glucose:** Insomnia proxies correlate with elevated and more variable morning glucose and higher overnight hyperglycemia.  

- **Meal Timing and Snacks:** Late dinners and skipping balanced bedtime snacks increase the risk of overnight glucose instability.  

- **Hypoglycemia Risks:** Patients identified as snack-candidates show the highest overnight hypoglycemia rates, especially around midnight and early morning.  

- **Demographics:** The dataset shows a bimodal age distribution (30s & 60s), is male-dominant, and females tend to be older, which may affect comparative analyses.  

- **Universal Sleep Disturbances:** All patients report disturbances, with an average >50% of nights disrupted, making sleep health a universal intervention need.  

### Exercise and Activity  

- **Examines how evening physical activity impacts glucose variability and nighttime hypoglycemia risk: Moderate activity is associated with fewer risks of Hypoglycemia while vigorous activity has a stronger correlation to hypoglycemia. 

- Physical activity leads to better glucose control in diabetic patients. 65% of patients experienced a better glucose control (Time-in-Range) after a day's worth of physical activity.

  




---

## Authors

**Team Name:** Python Wranglers  
**Team Number:** 10  

**Team Members:**  
- Padmasree Basineni  
- Geetanjali Das  
- Priya Ravi Tembe  
- Pallabi Mukherjee  
- Kirthana Ramanathan  



## File Structure
- `data/` → Raw CSV files (1 per patient)  
- `cleaned_data/` → Preprocessed & merged dataset  
- `notebooks/` → Jupyter notebooks for cleaning & analysis  
- `results/` → Outputs, charts, and summaries  

---

## Requirements
To run the analysis, install dependencies:

```bash
pip install -r requirements.txt







