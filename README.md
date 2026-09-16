# HealthcareDB

A SQL Server data warehouse for hospital admissions data, built for
SQL Server Management Studio (SSMS). It takes a flat, 55,500-row CSV
export and turns it into a proper star schema: one fact table for
admissions and eight dimension tables for the categorical data
around it (hospital, doctor, condition, insurance provider, and so
on).

The source data is synthetic and publicly available. No real
patients, doctors, or hospitals are involved.

## What is in here

```
HealthcareDB/
├── database/
│   ├── 01_create_database.sql
│   ├── 02_create_staging_table.sql
│   ├── 03_create_functions.sql
│   ├── 04_create_dimension_tables.sql
│   ├── 05_create_fact_table.sql
│   ├── 06_create_indexes.sql
│   ├── 07_create_views.sql
│   └── 08_create_stored_procedures.sql
├── data/
│   └── healthcare_raw.csv
├── scripts/
│   ├── 01_load_staging.sql
│   └── 02_populate_dimensional_model.sql
├── docs/
│   ├── data_dictionary.md
│   ├── er_diagram.md
│   ├── business_questions.md
│   └── sample_queries.sql
└── README.md
```

## Design

Rather than load the CSV straight into one wide table, this project
uses a two-step ETL pattern that is common in real data warehouses:

1. **Staging.** The raw file lands in `Staging_Healthcare` exactly as
   it is, with no constraints. Nothing here can fail on a data
   quality surprise.
2. **Dimensional model.** A second script reads the staging table,
   cleans it up, and splits it into the `Admissions` fact table and
   eight dimension tables. Cleaning includes title-casing patient
   names (the source has them in random casing, for example
   `LesLie TErRy`), and stripping a trailing comma that shows up on
   about one in ten hospital names.

Doctor and hospital both get their own dimension tables even though
most values only appear once or twice, since that is still the
correct way to model a one-to-many relationship, and it keeps
`Admissions` from repeating long text values on every row.

There is no patient ID in the source data, so patient name, age, and
gender live directly on the fact table instead of a separate
Patients dimension. See `docs/data_dictionary.md` for the reasoning
and for a full column by column breakdown of every table.

## Setting it up in SSMS

1. Open SSMS and connect to your SQL Server instance.
2. Run the scripts in `database/` in numeric order, 01 through 08.
   Steps 04 and 05 create empty tables. Steps 06 through 08 need the
   tables to already exist, but not necessarily populated.
3. Copy the `data` folder to a path the SQL Server service account
   can read (for example `C:\HealthcareDB\data\`), and update the
   `@DataFolder` variable at the top of `scripts/01_load_staging.sql`
   if you used a different path.
4. Run `scripts/01_load_staging.sql`. This loads the CSV into the
   staging table with `BULK INSERT` and prints the row count.
5. Run `scripts/02_populate_dimensional_model.sql`. This reads the
   staging table, applies the cleaning steps, and fills the
   dimension tables and `Admissions`. It prints a row count for
   every table when it finishes.

If `BULK INSERT` is not available on your instance, use SSMS's
Import Flat File wizard against `Staging_Healthcare` instead, then
run step 5 as written.

## Example queries

`docs/business_questions.md` has around twenty business questions
this data can answer, each with a working query, grouped into
volume and trends, financial, hospitals and doctors, clinical
patterns, operational, and patient-level. `docs/sample_queries.sql`
has a shorter set of examples covering each stored procedure.

## Data quality notes

A few things worth knowing before building on top of this:

- 108 rows have a negative billing amount. The project keeps these
  as they are in the source rather than guessing whether they are
  refunds or errors. See `docs/data_dictionary.md` for more detail.
- Patient name is not a reliable identifier. Two admissions under
  the same name are not guaranteed to be the same person, since the
  source data has no patient ID to confirm it either way.

## License


