/*
    04_create_fact_table.sql
    The central Admissions table. Every record is one hospital
    stay, linked out to the dimension tables created in the
    previous script.

    There is no reliable patient identifier in the source data, so
    patient name, age, and gender stay on the fact table itself
    rather than being split into a Patients dimension that would
    imply an identity link the data does not actually support.
*/

USE HealthcareDB;
GO

CREATE TABLE dbo.Admissions
(
    AdmissionId             INT IDENTITY(1, 1) NOT NULL,
    PatientName             VARCHAR(200)       NOT NULL,
    Age                     INT                NOT NULL,
    Gender                  VARCHAR(10)        NOT NULL,
    BloodTypeId             INT                NOT NULL,
    ConditionId             INT                NOT NULL,
    DoctorId                INT                NOT NULL,
    HospitalId              INT                NOT NULL,
    InsuranceProviderId     INT                NOT NULL,
    AdmissionDate           DATE               NOT NULL,
    DischargeDate           DATE               NOT NULL,
    AdmissionTypeId         INT                NOT NULL,
    RoomNumber              INT                NOT NULL,
    MedicationId            INT                NOT NULL,
    TestResultId            INT                NOT NULL,
    BillingAmount           DECIMAL(14, 2)     NOT NULL,
    CONSTRAINT PK_Admissions PRIMARY KEY (AdmissionId),
    CONSTRAINT FK_Admissions_BloodType FOREIGN KEY (BloodTypeId)
        REFERENCES dbo.DimBloodType (BloodTypeId),
    CONSTRAINT FK_Admissions_Condition FOREIGN KEY (ConditionId)
        REFERENCES dbo.DimMedicalCondition (ConditionId),
    CONSTRAINT FK_Admissions_Doctor FOREIGN KEY (DoctorId)
        REFERENCES dbo.DimDoctor (DoctorId),
    CONSTRAINT FK_Admissions_Hospital FOREIGN KEY (HospitalId)
        REFERENCES dbo.DimHospital (HospitalId),
    CONSTRAINT FK_Admissions_InsuranceProvider FOREIGN KEY (InsuranceProviderId)
        REFERENCES dbo.DimInsuranceProvider (InsuranceProviderId),
    CONSTRAINT FK_Admissions_AdmissionType FOREIGN KEY (AdmissionTypeId)
        REFERENCES dbo.DimAdmissionType (AdmissionTypeId),
    CONSTRAINT FK_Admissions_Medication FOREIGN KEY (MedicationId)
        REFERENCES dbo.DimMedication (MedicationId),
    CONSTRAINT FK_Admissions_TestResult FOREIGN KEY (TestResultId)
        REFERENCES dbo.DimTestResult (TestResultId),
    CONSTRAINT CK_Admissions_Age CHECK (Age >= 0),
    CONSTRAINT CK_Admissions_DischargeAfterAdmission CHECK (DischargeDate >= AdmissionDate)
);
GO
