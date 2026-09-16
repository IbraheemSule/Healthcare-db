/*
    06_create_views.sql
    Reporting views built on top of the star schema.
    Run after the fact and dimension tables are populated.
*/

USE HealthcareDB;
GO

-- Every admission, fully joined and readable, for ad hoc reporting
CREATE OR ALTER VIEW dbo.vw_AdmissionsDetail
AS
SELECT
    a.AdmissionId,
    a.PatientName,
    a.Age,
    a.Gender,
    bt.BloodTypeName,
    mc.ConditionName,
    d.DoctorName,
    h.HospitalName,
    ip.ProviderName            AS InsuranceProvider,
    a.AdmissionDate,
    a.DischargeDate,
    DATEDIFF(DAY, a.AdmissionDate, a.DischargeDate) AS LengthOfStayDays,
    at.AdmissionTypeName,
    a.RoomNumber,
    med.MedicationName,
    tr.ResultName               AS TestResult,
    a.BillingAmount
FROM dbo.Admissions AS a
INNER JOIN dbo.DimBloodType AS bt          ON bt.BloodTypeId = a.BloodTypeId
INNER JOIN dbo.DimMedicalCondition AS mc   ON mc.ConditionId = a.ConditionId
INNER JOIN dbo.DimDoctor AS d              ON d.DoctorId = a.DoctorId
INNER JOIN dbo.DimHospital AS h            ON h.HospitalId = a.HospitalId
INNER JOIN dbo.DimInsuranceProvider AS ip  ON ip.InsuranceProviderId = a.InsuranceProviderId
INNER JOIN dbo.DimAdmissionType AS at      ON at.AdmissionTypeId = a.AdmissionTypeId
INNER JOIN dbo.DimMedication AS med        ON med.MedicationId = a.MedicationId
INNER JOIN dbo.DimTestResult AS tr         ON tr.TestResultId = a.TestResultId;
GO

-- Admission volume and average billing by month
CREATE OR ALTER VIEW dbo.vw_MonthlyAdmissionSummary
AS
SELECT
    DATEFROMPARTS(YEAR(AdmissionDate), MONTH(AdmissionDate), 1) AS MonthStart,
    COUNT(*)                       AS AdmissionCount,
    SUM(BillingAmount)             AS TotalBilled,
    AVG(BillingAmount)             AS AverageBilled,
    AVG(CAST(DATEDIFF(DAY, AdmissionDate, DischargeDate) AS DECIMAL(10, 2))) AS AverageLengthOfStayDays
FROM dbo.Admissions
GROUP BY DATEFROMPARTS(YEAR(AdmissionDate), MONTH(AdmissionDate), 1);
GO

-- Billing and volume broken down by medical condition
CREATE OR ALTER VIEW dbo.vw_BillingByCondition
AS
SELECT
    mc.ConditionName,
    COUNT(*)                       AS AdmissionCount,
    SUM(a.BillingAmount)            AS TotalBilled,
    AVG(a.BillingAmount)            AS AverageBilled,
    AVG(CAST(DATEDIFF(DAY, a.AdmissionDate, a.DischargeDate) AS DECIMAL(10, 2))) AS AverageLengthOfStayDays
FROM dbo.Admissions AS a
INNER JOIN dbo.DimMedicalCondition AS mc ON mc.ConditionId = a.ConditionId
GROUP BY mc.ConditionName;
GO

-- Admission volume and billing by hospital
CREATE OR ALTER VIEW dbo.vw_HospitalSummary
AS
SELECT
    h.HospitalName,
    COUNT(*)                        AS AdmissionCount,
    SUM(a.BillingAmount)             AS TotalBilled,
    AVG(a.BillingAmount)             AS AverageBilled
FROM dbo.Admissions AS a
INNER JOIN dbo.DimHospital AS h ON h.HospitalId = a.HospitalId
GROUP BY h.HospitalName;
GO
