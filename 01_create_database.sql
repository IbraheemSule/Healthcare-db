/*
    01_create_database.sql
    Creates the HealthcareDB database.
    Run this first, connected to the master database.
*/

USE master;
GO

IF DB_ID(N'HealthcareDB') IS NOT NULL
BEGIN
    ALTER DATABASE HealthcareDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HealthcareDB;
END
GO

CREATE DATABASE HealthcareDB;
GO

ALTER DATABASE HealthcareDB SET RECOVERY SIMPLE;
GO

USE HealthcareDB;
GO
