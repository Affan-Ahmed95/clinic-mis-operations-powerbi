-- Create database
CREATE DATABASE IF NOT EXISTS clinic_mis_db;
USE clinic_mis_db;

-- Staging table for raw CSV load
DROP TABLE IF EXISTS raw_clinic_visists;

DROP TABLE IF EXISTS raw_clinic_visits;

CREATE TABLE raw_clinic_visits (
    Record_ID VARCHAR(50),
    Patient_ID VARCHAR(50),
    Patient_Name VARCHAR(150),
    Gender VARCHAR(20),
    Age INT,
    City VARCHAR(100),
    Visit_Date VARCHAR(50),
    Visit_Month VARCHAR(20),
    Visit_Year INT,
    Doctor VARCHAR(100),
    Branch VARCHAR(100),
    Visit_Type VARCHAR(50),
    Appointment_Status VARCHAR(50),
    Treatment_Category VARCHAR(100),
    Consultation_Type VARCHAR(50),
    Follow_Up VARCHAR(10),
    Prescription_Status VARCHAR(50),
    Consultation_Fee DECIMAL(10, 2),
    Discount DECIMAL(10, 2),
    Final_Amount DECIMAL(10, 2),
    Payment_Status VARCHAR(50),
    Payment_Mode VARCHAR(50),
    Appointment_Time VARCHAR(50),
    Registration_Channel VARCHAR(50),
    Waiting_Time_Minutes VARCHAR(50),
    Follow_Up_Date VARCHAR(50)
);

DROP TABLE IF EXISTS clean_clinic_visits;

CREATE TABLE clean_clinic_visits (
    Record_ID VARCHAR(50) PRIMARY KEY,
    Patient_ID VARCHAR(50),
    Patient_Name VARCHAR(150),
    Gender VARCHAR(20),
    Age INT,
    City VARCHAR(100),
    Visit_Date DATE,
    Visit_Month VARCHAR(20),
    Visit_Year INT,
    Doctor VARCHAR(100),
    Branch VARCHAR(100),
    Visit_Type VARCHAR(50),
    Appointment_Status VARCHAR(50),
    Treatment_Category VARCHAR(100),
    Consultation_Type VARCHAR(50),
    Follow_Up VARCHAR(10),
    Prescription_Status VARCHAR(50),
    Consultation_Fee DECIMAL(10, 2),
    Discount DECIMAL(10, 2),
    Final_Amount DECIMAL(10, 2),
    Payment_Status VARCHAR(50),
    Payment_Mode VARCHAR(50),
    Appointment_Time VARCHAR(50),
    Registration_Channel VARCHAR(50),
    Waiting_Time_Minutes INT,
    Follow_Up_Date DATE
);

INSERT INTO clean_clinic_visits
SELECT 
    Record_ID,
    Patient_ID,
    Patient_Name,
    Gender,
    Age,
    City,
    Visit_Date_Clean,
    Visit_Month,
    Visit_Year,
    Doctor,
    Branch,
    Visit_Type,
    Appointment_Status_Clean,
    Treatment_Category,
    Consultation_Type,
    Follow_Up,
    Prescription_Status,
    Consultation_Fee,
    Discount_Clean,
    Final_Amount_Clean,
    Payment_Status,
    Payment_Mode,
    Appointment_Time,
    Registration_Channel,
    Waiting_Time_Minutes_Clean,
    Follow_Up_Date_Clean
FROM (
    SELECT 
        Record_ID,
        Patient_ID,
        Patient_Name,
        Gender,
        Age,
        City,
        -- Safely convert Visit_Date, handling blanks and multiple text formats
        CASE 
            WHEN Visit_Date IS NULL OR TRIM(Visit_Date) = '' THEN NULL
            WHEN Visit_Date LIKE '%-%-%' AND LENGTH(TRIM(Visit_Date)) = 11 THEN STR_TO_DATE(TRIM(Visit_Date), '%d-%b-%Y')
            ELSE STR_TO_DATE(TRIM(Visit_Date), '%Y-%m-%d')
        END AS Visit_Date_Clean,
        Visit_Month,
        Visit_Year,
        Doctor,
        Branch,
        Visit_Type,
        -- Standardize appointment status casing and variants
        CASE 
            WHEN LOWER(Appointment_Status) LIKE '%complete%' THEN 'Completed'
            WHEN LOWER(Appointment_Status) LIKE '%cancel%' THEN 'Cancelled'
            WHEN LOWER(Appointment_Status) LIKE '%no%show%' THEN 'No Show'
            WHEN LOWER(Appointment_Status) LIKE '%pending%' THEN 'Pending'
            ELSE Appointment_Status 
        END AS Appointment_Status_Clean,
        Treatment_Category,
        Consultation_Type,
        Follow_Up,
        Prescription_Status,
        Consultation_Fee,
        -- Cap discount if it exceeds consultation fee
        CASE 
            WHEN Discount > Consultation_Fee THEN Consultation_Fee 
            ELSE Discount 
        END AS Discount_Clean,
        -- Recalculate Final_Amount cleanly
        CASE 
            WHEN Discount > Consultation_Fee THEN 0 
            ELSE (Consultation_Fee - Discount) 
        END AS Final_Amount_Clean,
        Payment_Status,
        Payment_Mode,
        Appointment_Time,
        Registration_Channel,
        NULLIF(TRIM(Waiting_Time_Minutes), '') AS Waiting_Time_Minutes_Clean,
        -- Safely convert Follow_Up_Date
        CASE 
            WHEN Follow_Up_Date IS NULL OR TRIM(Follow_Up_Date) = '' THEN NULL
            WHEN LENGTH(TRIM(Follow_Up_Date)) = 11 THEN STR_TO_DATE(TRIM(Follow_Up_Date), '%d-%b-%Y')
            ELSE STR_TO_DATE(TRIM(Follow_Up_Date), '%Y-%m-%d')
        END AS Follow_Up_Date_Clean,
        ROW_NUMBER() OVER(PARTITION BY Record_ID ORDER BY Visit_Date ASC) AS row_num
    FROM raw_clinic_visits
) AS clean_subquery
WHERE row_num = 1;
