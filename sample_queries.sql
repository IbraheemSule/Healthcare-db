/*
    sample_queries.sql
    Examples of how the views and stored procedures in this
    project are meant to be used. Nothing here is required for
    setup, these are just demonstrations.
*/

USE HealthcareDB;
GO

-- Every admission for patients with diabetes
EXEC dbo.usp_GetAdmissionsByCondition @ConditionName = 'Diabetes';
GO

-- Monthly admission volume and billing for 2023
EXEC dbo.usp_GetMonthlyTrend
    @StartDate = '2023-01-01',
    @EndDate   = '2023-12-31';
GO

-- Ten busiest hospitals by admission count
EXEC dbo.usp_GetTopHospitalsByVolume @TopN = 10;
GO

-- Billing and volume by insurance provider, all time
EXEC dbo.usp_GetInsuranceProviderBreakdown;
GO

-- Which medical condition has the longest average hospital stay
SELECT TOP 5 *
FROM dbo.vw_BillingByCondition
ORDER BY AverageLengthOfStayDays DESC;
GO

-- Admissions with an abnormal test result, most expensive first
SELECT TOP 20 *
FROM dbo.vw_AdmissionsDetail
WHERE TestResult = 'Abnormal'
ORDER BY BillingAmount DESC;
GO
