# 🏥 Clinic Operational & Financial MIS Performance Dashboard

An end-to-end data pipeline and interactive business intelligence dashboard modeling outpatient throughput, clinician workload distribution, and financial realization across multi-branch clinics using MySQL and Power BI Desktop.

![Dashboard Preview](dashboard_preview.png)

---

## 📌 Executive Summary
* **Total Visits:** 3,757 validated patient encounters across 1,527 unique patients.
* **Net Realized Revenue:** $1.54M with $108.1K in promotional discounts absorbed.
* **Clinical Completion Rate:** 79.9% (3,001 completed consultations).
* **Operational Leakage:** 11.1% cancellation rate (418 visits) and 6.7% no-show rate (251 visits).

---

## 🛠️ Data Pipeline & SQL Engineering (MySQL)
* **Deduplication:** Resolved 30 duplicate `Record_ID` pairs using `ROW_NUMBER() OVER (PARTITION BY Record_ID ORDER BY Visit_Date ASC)`.
* **Standardization:** Normalized casing variations (`completed`, `COMPLETED`, `No-Show`) into 4 consistent operational states (`Completed`, `Cancelled`, `No Show`, `Pending`).
* **Financial Constraints:** Balanced 7 records where promotional discounts exceeded the consultation fee using `CASE WHEN Discount > Consultation_Fee THEN Consultation_Fee ELSE Discount END`.
* **Data Cleaning:** Handled missing visit dates and ages, converting anomalies into typed SQL dates and nulls.

---

## 📊 Business Intelligence & DAX (Power BI)
* Created a dedicated `_Measures` table housing DAX business metrics (`Net Revenue`, `Total Visits`, `Completed Visits`, `Completion Rate`, `Avg Waiting Time`).
* Built an executive dashboard layout featuring:
  * 4 executive KPI header cards with styled container backgrounds.
  * Clinician workload breakdown across Completed, Cancelled, and No-Show appointments.
  * Monthly revenue trend tracking seasonal outpatient demand.
  * Treatment category specialty distribution.
  * Interactive cross-filtering by clinic branch and date range.
