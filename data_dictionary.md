# Data dictionary

This describes every table, view, and stored procedure in
HealthcareDB. The source data is a hospital admissions export
covering May 2019 through May 2024, 55,500 records. It is
synthetic, publicly available sample data with no real patients,
doctors, or hospitals attached to it.

## dbo.Staging_Healthcare

A one for one mirror of the source CSV, with no constraints. This
is where the raw file lands before anything gets cleaned or split
into the star schema below. Kept around after the load so the
original values are still there if you need to check what the
source actually said.

## Dimension tables

Each of these holds the distinct values for one categorical column
in the source data.

| Table                    | Key column          | Name column      | Distinct values |
|---------------------------|---------------------|------------------|------------------|
| DimBloodType               | BloodTypeId         | BloodTypeName    | 8                |
| DimMedicalCondition         | ConditionId          | ConditionName    | 6                |
| DimDoctor                   | DoctorId             | DoctorName       | ~40,300          |
| DimHospital                 | HospitalId           | HospitalName     | ~39,800          |
| DimInsuranceProvider         | InsuranceProviderId  | ProviderName     | 5                |
| DimAdmissionType             | AdmissionTypeId      | AdmissionTypeName| 3                |
| DimMedication                | MedicationId         | MedicationName   | 5                |
| DimTestResult                | TestResultId         | ResultName       | 3                |

## dbo.Admissions

The fact table. One row per hospital stay.

| Column               | Type           | Notes                                   |
|----------------------|----------------|--------------------------------------------|
| AdmissionId          | INT            | Primary key                                 |
| PatientName          | VARCHAR(200)   | Title-cased during load                     |
| Age                  | INT            |                                              |
| Gender               | VARCHAR(10)    | `Male` or `Female`                          |
| BloodTypeId          | INT            | Foreign key to DimBloodType                 |
| ConditionId          | INT            | Foreign key to DimMedicalCondition          |
| DoctorId             | INT            | Foreign key to DimDoctor                    |
| HospitalId           | INT            | Foreign key to DimHospital                  |
| InsuranceProviderId  | INT            | Foreign key to DimInsuranceProvider         |
| AdmissionDate        | DATE           |                                              |
| DischargeDate        | DATE           | Always on or after AdmissionDate            |
| AdmissionTypeId      | INT            | Foreign key to DimAdmissionType             |
| RoomNumber           | INT            | 101 to 500                                  |
| MedicationId         | INT            | Foreign key to DimMedication                |
| TestResultId         | INT            | Foreign key to DimTestResult                |
| BillingAmount        | DECIMAL(14,2)  | See the data quality note below             |

There is no reliable patient identifier in the source data, so
`PatientName`, `Age`, and `Gender` live on the fact table itself
rather than in a separate Patients dimension. Splitting them out
would imply the data can tell two admissions under the same name
apart as the same person, which it cannot.

## Functions

- **fn_ToTitleCase** `(@Input)` — converts a string to title case. Used to clean up patient names, which arrive in random casing (for example `LesLie TErRy`).
- **fn_CleanHospitalName** `(@Input)` — strips a trailing comma and surrounding whitespace from a hospital name. About one in ten hospital names in the source file ends with a stray comma.

## Views

- **vw_AdmissionsDetail** — every admission, fully joined and human-readable.
- **vw_MonthlyAdmissionSummary** — admission count, total and average billing, and average length of stay, by month.
- **vw_BillingByCondition** — the same metrics, grouped by medical condition.
- **vw_HospitalSummary** — admission count and billing totals, grouped by hospital.

## Stored procedures

- **usp_GetAdmissionsByCondition** `@ConditionName` — every admission for one condition.
- **usp_GetMonthlyTrend** `@StartDate, @EndDate` — the monthly summary view, filtered to a date range.
- **usp_GetTopHospitalsByVolume** `@TopN = 10` — busiest hospitals by admission count.
- **usp_GetPatientAdmissionHistory** `@PatientName` — every admission recorded under one name.
- **usp_GetInsuranceProviderBreakdown** `@StartDate = NULL, @EndDate = NULL` — billing and volume by insurance provider, with optional date filtering.

## Data quality notes

- **Billing amount.** 108 rows have a negative billing amount. This
  is a property of the source file, not something this project
  corrects, since there is no way to tell from the data alone
  whether a negative value represents a refund, an adjustment, or
  an error. Anything summing billing amounts should decide how to
  treat these deliberately rather than assuming they cancel out
  correctly.
- **Patient identity.** Because there is no patient ID in the
  source, two admissions with the same `PatientName` are not
  guaranteed to be the same person. `usp_GetPatientAdmissionHistory`
  matches on name only.
