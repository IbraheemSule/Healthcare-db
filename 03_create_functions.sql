/*
    03_create_functions.sql
    Small helper functions used during the load into the star
    schema. Run after the staging table exists and before the
    dimension tables are populated.
*/

USE HealthcareDB;
GO

-- Converts a string to title case. The source data has patient
-- names in random casing (for example "LesLie TErRy"), and T-SQL
-- has no built in function for this.
CREATE OR ALTER FUNCTION dbo.fn_ToTitleCase (@Input VARCHAR(200))
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @Output VARCHAR(200) = '';
    DECLARE @StartOfWord BIT = 1;
    DECLARE @Position INT = 1;
    DECLARE @Character CHAR(1);

    WHILE @Position <= LEN(@Input)
    BEGIN
        SET @Character = SUBSTRING(@Input, @Position, 1);

        IF @StartOfWord = 1
            SET @Output = @Output + UPPER(@Character);
        ELSE
            SET @Output = @Output + LOWER(@Character);

        SET @StartOfWord = CASE WHEN @Character = ' ' THEN 1 ELSE 0 END;
        SET @Position = @Position + 1;
    END

    RETURN @Output;
END
GO

-- Strips a trailing comma and any surrounding whitespace from a
-- hospital name. About one in ten hospital names in the source
-- data ends with a stray comma (for example "Kim and Sons,").
CREATE OR ALTER FUNCTION dbo.fn_CleanHospitalName (@Input VARCHAR(200))
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @Trimmed VARCHAR(200) = LTRIM(RTRIM(@Input));

    IF RIGHT(@Trimmed, 1) = ','
        SET @Trimmed = LTRIM(RTRIM(LEFT(@Trimmed, LEN(@Trimmed) - 1)));

    RETURN @Trimmed;
END
GO
