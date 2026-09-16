# Business questions

Every question below is answered with a query written against the
views and tables in this project. Run these in SSMS after the
database has been set up and loaded, see the main `README.md` for
setup steps.

## Volume and trends

**How many admissions came in each month, and is the trend growing
or shrinking?**

```sql
SELECT MonthStart, AdmissionCount
FROM dbo.vw_MonthlyAdmissionSummary
ORDER BY MonthStart;
```

**Which months see the highest admission volume?**

```sql
SELECT TOP 10 MonthStart, AdmissionCount
FROM dbo.vw_MonthlyAdmissionSummary
ORDER BY AdmissionCount DESC;
```

**How has the average length of stay changed over the five year
period?**

```sql
SELECT MonthStart, AverageLengthOfStayDays
FROM dbo.vw_MonthlyAdmissionSummary
ORDER BY MonthStart;
```

## Financial

**What is total billing by month, quarter, or year?**

```sql
-- By month
SELECT MonthStart, TotalBilled
FROM dbo.vw_MonthlyAdmissionSummary
ORDER BY MonthStart;

-- By quarter
SELECT
    YEAR(MonthStart)                       AS BillingYear,
    DATEPART(QUARTER, MonthStart)          AS BillingQuarter,
    SUM(TotalBilled)                       AS TotalBilled
FROM dbo.vw_MonthlyAdmissionSummary
GROUP BY YEAR(MonthStart), DATEPART(QUARTER, MonthStart)
ORDER BY BillingYear, BillingQuarter;

-- By year
SELECT
    YEAR(MonthStart)   AS BillingYear,
    SUM(TotalBilled)   AS TotalBilled
FROM dbo.vw_MonthlyAdmissionSummary
GROUP BY YEAR(MonthStart)
ORDER BY BillingYear;
```

**Which medical condition costs the most on average per admission?**

```sql
SELECT TOP 10 ConditionName, AverageBilled
FROM dbo.vw_BillingByCondition
ORDER BY AverageBilled DESC;
```

**Which insurance provider carries the largest share of total
billing?**

```sql
EXEC dbo.usp_GetInsuranceProviderBreakdown;
```

**Are there admissions with unusually high or negative billing
amounts worth a closer look?**

```sql
-- Negative billing
SELECT *
FROM dbo.vw_AdmissionsDetail
WHERE BillingAmount < 0
ORDER BY BillingAmount ASC;

-- Top 20 highest billed admissions
SELECT TOP 20 *
FROM dbo.vw_AdmissionsDetail
ORDER BY BillingAmount DESC;
```

## Hospitals and doctors

**Which hospitals handle the most admissions?**

```sql
EXEC dbo.usp_GetTopHospitalsByVolume @TopN = 10;
```

**Which hospitals bill the most on average per admission?**

```sql
SELECT TOP 10 HospitalName, AverageBilled
FROM dbo.vw_HospitalSummary
ORDER BY AverageBilled DESC;
```

**Do certain doctors see a disproportionate share of one medical
condition?**

```sql
SELECT
    d.DoctorName,
    mc.ConditionName,
    COUNT(*) AS AdmissionCount
FROM dbo.Admissions AS a
INNER JOIN dbo.DimDoctor AS d ON d.DoctorId = a.DoctorId
INNER JOIN dbo.DimMedicalCondition AS mc ON mc.ConditionId = a.ConditionId
GROUP BY d.DoctorName, mc.ConditionName
HAVING COUNT(*) > 1
ORDER BY AdmissionCount DESC;
```

## Clinical patterns

**Which medical condition has the longest average hospital stay?**

```sql
SELECT TOP 10 ConditionName, AverageLengthOfStayDays
FROM dbo.vw_BillingByCondition
ORDER BY AverageLengthOfStayDays DESC;
```

**Is there a relationship between admission type and length of
stay?**

```sql
SELECT
    at.AdmissionTypeName,
    COUNT(*)                                                          AS AdmissionCount,
    AVG(CAST(DATEDIFF(DAY, a.AdmissionDate, a.DischargeDate) AS DECIMAL(10, 2))) AS AverageLengthOfStayDays
FROM dbo.Admissions AS a
INNER JOIN dbo.DimAdmissionType AS at ON at.AdmissionTypeId = a.AdmissionTypeId
GROUP BY at.AdmissionTypeName
ORDER BY AverageLengthOfStayDays DESC;
```

**How common is an abnormal test result for each medical
condition?**

```sql
SELECT
    ConditionName,
    TestResult,
    COUNT(*) AS AdmissionCount
FROM dbo.vw_AdmissionsDetail
GROUP BY ConditionName, TestResult
ORDER BY ConditionName, TestResult;
```

**Does age correlate with length of stay or billing amount?**

```sql
SELECT
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 39 THEN '18 to 39'
        WHEN Age BETWEEN 40 AND 59 THEN '40 to 59'
        ELSE '60 and over'
    END                                          AS AgeGroup,
    AVG(CAST(LengthOfStayDays AS DECIMAL(10, 2))) AS AverageLengthOfStayDays,
    AVG(BillingAmount)                            AS AverageBilled
FROM dbo.vw_AdmissionsDetail
GROUP BY
    CASE
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 39 THEN '18 to 39'
        WHEN Age BETWEEN 40 AND 59 THEN '40 to 59'
        ELSE '60 and over'
    END
ORDER BY AverageBilled DESC;
```

## Operational

**Which room numbers get used most often?**

```sql
SELECT TOP 10 RoomNumber, COUNT(*) AS TimesUsed
FROM dbo.Admissions
GROUP BY RoomNumber
ORDER BY TimesUsed DESC;
```

**Is there a seasonal pattern to admission type?**

```sql
SELECT
    MONTH(a.AdmissionDate)     AS AdmissionMonth,
    at.AdmissionTypeName,
    COUNT(*)                   AS AdmissionCount
FROM dbo.Admissions AS a
INNER JOIN dbo.DimAdmissionType AS at ON at.AdmissionTypeId = a.AdmissionTypeId
GROUP BY MONTH(a.AdmissionDate), at.AdmissionTypeName
ORDER BY AdmissionMonth, at.AdmissionTypeName;
```

**Which medication is prescribed most often for each condition?**

```sql
SELECT ConditionName, MedicationName, AdmissionCount
FROM (
    SELECT
        mc.ConditionName,
        med.MedicationName,
        COUNT(*) AS AdmissionCount,
        ROW_NUMBER() OVER (
            PARTITION BY mc.ConditionName
            ORDER BY COUNT(*) DESC
        ) AS RowNum
    FROM dbo.Admissions AS a
    INNER JOIN dbo.DimMedicalCondition AS mc ON mc.ConditionId = a.ConditionId
    INNER JOIN dbo.DimMedication AS med ON med.MedicationId = a.MedicationId
    GROUP BY mc.ConditionName, med.MedicationName
) AS ranked
WHERE RowNum = 1
ORDER BY ConditionName;
```

## Patient-level

Remember there is no patient ID in the source data, so matches here
are by name only. See the data quality note in `data_dictionary.md`.

**Which patients have more than one recorded admission?**

```sql
SELECT PatientName, COUNT(*) AS AdmissionCount
FROM dbo.Admissions
GROUP BY PatientName
HAVING COUNT(*) > 1
ORDER BY AdmissionCount DESC;
```

**What does a single patient's admission history look like over
time?**

```sql
EXEC dbo.usp_GetPatientAdmissionHistory @PatientName = 'Bobby Jackson';
```
