/*
    02_create_staging_table.sql
    A staging table that mirrors the source CSV column for column,
    with no constraints. Raw data lands here first, unmodified, so
    the load step never fails on a data quality surprise and the
    original values stay available for auditing.

    Dates are staged as text, not DATE, because the source uses
    M/D/YYYY formatting that should not be left to whatever the
    server's default language happens to be. The ETL step in
    /scripts converts them explicitly.
*/

USE HealthcareDB;
GO

IF OBJECT_ID(N'dbo.Staging_Healthcare', N'U') IS NOT NULL
    DROP TABLE dbo.Staging_Healthcare;
GO

CREATE TABLE dbo.Staging_Healthcare
(
    Name                VARCHAR(200)    NULL,
    Age                 INT             NULL,
    Gender              VARCHAR(10)     NULL,
    BloodType           VARCHAR(5)      NULL,
    MedicalCondition    VARCHAR(100)    NULL,
    DateOfAdmission      VARCHAR(20)     NULL,
    Doctor              VARCHAR(200)    NULL,
    Hospital            VARCHAR(200)    NULL,
    InsuranceProvider   VARCHAR(100)    NULL,
    BillingAmount        DECIMAL(14, 5)  NULL,
    RoomNumber           INT             NULL,
    AdmissionType        VARCHAR(30)     NULL,
    DischargeDate        VARCHAR(20)     NULL,
    Medication           VARCHAR(100)    NULL,
    TestResults           VARCHAR(30)     NULL
);
GO
