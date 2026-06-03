-- Clean and enrich trip records
DROP TABLE IF EXISTS chicago_taxi.trips_clean;

CREATE TABLE chicago_taxi.trips_clean AS
SELECT
    trip_id,
    taxi_id,
    CAST(trip_start_timestamp AS TIMESTAMP) AS trip_start_timestamp,
    CAST(trip_end_timestamp AS TIMESTAMP) AS trip_end_timestamp,
    trip_seconds,
    trip_miles,
    fare,
    COALESCE(tips, 0) AS tips,
    COALESCE(tolls, 0) AS tolls,
    COALESCE(extras, 0) AS extras,
    fare + COALESCE(tips, 0) + COALESCE(tolls, 0) + COALESCE(extras, 0) AS total_amount,
    payment_type,
    company,
    pickup_community_area,
    dropoff_community_area,
    CAST(trip_start_timestamp AS DATE) AS trip_date,
    EXTRACT(HOUR FROM CAST(trip_start_timestamp AS TIMESTAMP))::INTEGER AS hour_of_day,
    EXTRACT(DOW FROM CAST(trip_start_timestamp AS TIMESTAMP)) IN (0, 6) AS is_weekend
FROM chicago_taxi.trips
WHERE trip_id IS NOT NULL
  AND trip_start_timestamp IS NOT NULL
  AND fare IS NOT NULL
  AND fare >= 0
  AND trip_miles IS NOT NULL
  AND trip_miles >= 0
  AND trip_seconds BETWEEN 60 AND 10800
  AND CAST(trip_start_timestamp AS DATE) BETWEEN DATE '2024-01-01' AND DATE '2024-01-31';
