/*
    07_create_stored_procedures.sql
    Stored procedures for common reporting questions.
    Run after the views are created.
*/

USE HealthcareDB;
GO

-- Every admission for one medical condition, most recent first
CREATE OR ALTER PROCEDURE dbo.usp_GetAdmissionsByCondition
    @ConditionName  VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_AdmissionsDetail
    WHERE ConditionName = @ConditionName
    ORDER BY AdmissionDate DESC;
END
GO

-- Monthly admission volume, billing, and average length of stay over a date range
CREATE OR ALTER PROCEDURE dbo.usp_GetMonthlyTrend
    @StartDate  DATE,
    @EndDate    DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_MonthlyAdmissionSummary
    WHERE MonthStart >= @StartDate
      AND MonthStart <= @EndDate
    ORDER BY MonthStart;
END
GO

-- Busiest hospitals by admission volume
CREATE OR ALTER PROCEDURE dbo.usp_GetTopHospitalsByVolume
    @TopN   INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@TopN) *
    FROM dbo.vw_HospitalSummary
    ORDER BY AdmissionCount DESC;
END
GO

-- Admission history for a patient, matched by name
CREATE OR ALTER PROCEDURE dbo.usp_GetPatientAdmissionHistory
    @PatientName    VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM dbo.vw_AdmissionsDetail
    WHERE PatientName = @PatientName
    ORDER BY AdmissionDate;
END
GO

-- Admission volume and billing broken down by insurance provider
CREATE OR ALTER PROCEDURE dbo.usp_GetInsuranceProviderBreakdown
    @StartDate  DATE = NULL,
    @EndDate    DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ip.ProviderName,
        COUNT(*)               AS AdmissionCount,
        SUM(a.BillingAmount)   AS TotalBilled,
        AVG(a.BillingAmount)   AS AverageBilled
    FROM dbo.Admissions AS a
    INNER JOIN dbo.DimInsuranceProvider AS ip
        ON ip.InsuranceProviderId = a.InsuranceProviderId
    WHERE (@StartDate IS NULL OR a.AdmissionDate >= @StartDate)
      AND (@EndDate IS NULL OR a.AdmissionDate <= @EndDate)
    GROUP BY ip.ProviderName
    ORDER BY TotalBilled DESC;
END
GO
