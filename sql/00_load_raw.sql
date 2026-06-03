-- Load raw CSV into DuckDB (raw_csv_path set by run_pipeline.py)
CREATE SCHEMA IF NOT EXISTS chicago_taxi;

DROP TABLE IF EXISTS chicago_taxi.trips;

CREATE TABLE chicago_taxi.trips AS
SELECT *
FROM read_csv_auto('__RAW_CSV_PATH__');
