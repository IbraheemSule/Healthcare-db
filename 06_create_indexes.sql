/*
    05_create_indexes.sql
    Supporting indexes for the joins and filters the views and
    stored procedures rely on. Run after the fact table is
    populated.
*/

USE HealthcareDB;
GO

CREATE NONCLUSTERED INDEX IX_Admissions_AdmissionDate
    ON dbo.Admissions (AdmissionDate)
    INCLUDE (HospitalId, ConditionId, BillingAmount);
GO

CREATE NONCLUSTERED INDEX IX_Admissions_HospitalId
    ON dbo.Admissions (HospitalId);
GO

CREATE NONCLUSTERED INDEX IX_Admissions_DoctorId
    ON dbo.Admissions (DoctorId);
GO

CREATE NONCLUSTERED INDEX IX_Admissions_ConditionId
    ON dbo.Admissions (ConditionId);
GO

CREATE NONCLUSTERED INDEX IX_Admissions_InsuranceProviderId
    ON dbo.Admissions (InsuranceProviderId);
GO
