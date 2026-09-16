/*
    03_create_dimension_tables.sql
    Lookup tables for every repeated, categorical value in the
    source data. Run after the staging table exists.
*/

USE HealthcareDB;
GO

CREATE TABLE dbo.DimBloodType
(
    BloodTypeId     INT IDENTITY(1, 1) NOT NULL,
    BloodTypeName   VARCHAR(5)         NOT NULL,
    CONSTRAINT PK_DimBloodType PRIMARY KEY (BloodTypeId),
    CONSTRAINT UQ_DimBloodType_Name UNIQUE (BloodTypeName)
);
GO

CREATE TABLE dbo.DimMedicalCondition
(
    ConditionId     INT IDENTITY(1, 1) NOT NULL,
    ConditionName   VARCHAR(100)       NOT NULL,
    CONSTRAINT PK_DimMedicalCondition PRIMARY KEY (ConditionId),
    CONSTRAINT UQ_DimMedicalCondition_Name UNIQUE (ConditionName)
);
GO

CREATE TABLE dbo.DimDoctor
(
    DoctorId        INT IDENTITY(1, 1) NOT NULL,
    DoctorName      VARCHAR(200)       NOT NULL,
    CONSTRAINT PK_DimDoctor PRIMARY KEY (DoctorId),
    CONSTRAINT UQ_DimDoctor_Name UNIQUE (DoctorName)
);
GO

CREATE TABLE dbo.DimHospital
(
    HospitalId      INT IDENTITY(1, 1) NOT NULL,
    HospitalName    VARCHAR(200)       NOT NULL,
    CONSTRAINT PK_DimHospital PRIMARY KEY (HospitalId),
    CONSTRAINT UQ_DimHospital_Name UNIQUE (HospitalName)
);
GO

CREATE TABLE dbo.DimInsuranceProvider
(
    InsuranceProviderId    INT IDENTITY(1, 1) NOT NULL,
    ProviderName            VARCHAR(100)       NOT NULL,
    CONSTRAINT PK_DimInsuranceProvider PRIMARY KEY (InsuranceProviderId),
    CONSTRAINT UQ_DimInsuranceProvider_Name UNIQUE (ProviderName)
);
GO

CREATE TABLE dbo.DimAdmissionType
(
    AdmissionTypeId     INT IDENTITY(1, 1) NOT NULL,
    AdmissionTypeName   VARCHAR(30)        NOT NULL,
    CONSTRAINT PK_DimAdmissionType PRIMARY KEY (AdmissionTypeId),
    CONSTRAINT UQ_DimAdmissionType_Name UNIQUE (AdmissionTypeName)
);
GO

CREATE TABLE dbo.DimMedication
(
    MedicationId    INT IDENTITY(1, 1) NOT NULL,
    MedicationName  VARCHAR(100)       NOT NULL,
    CONSTRAINT PK_DimMedication PRIMARY KEY (MedicationId),
    CONSTRAINT UQ_DimMedication_Name UNIQUE (MedicationName)
);
GO

CREATE TABLE dbo.DimTestResult
(
    TestResultId    INT IDENTITY(1, 1) NOT NULL,
    ResultName      VARCHAR(30)        NOT NULL,
    CONSTRAINT PK_DimTestResult PRIMARY KEY (TestResultId),
    CONSTRAINT UQ_DimTestResult_Name UNIQUE (ResultName)
);
GO
