# Chicago Taxi Demand & Performance — Stakeholder Memo

> Fill in findings after running the pipeline and notebook. Replace `[TBD]` sections with your conclusions.

## Context

[TBD: Why this analysis matters — e.g. fleet utilization, peak-hour staffing, zone-level revenue opportunities.]

## Data source and scope

- **Source**: City of Chicago [Taxi Trips](https://data.cityofchicago.org/Transportation/Taxi-Trips/wrvz-psew) open dataset (or synthetic demo data for local runs).
- **Scope**: January 2024, one-month slice.
- **Grain**: Trip-level records aggregated to daily, hourly, and pickup-zone metrics.

## Cleaning assumptions

- Excluded trips with null IDs, timestamps, or fares.
- Removed negative fares and trip distances.
- Kept trips between 60 seconds and 3 hours duration.
- Restricted to January 2024 dates in the clean layer.

See [`sql/01_schema.sql`](../sql/01_schema.sql) for full logic.

## Key findings

1. **[TBD]** Daily trip volume trend — e.g. stable weekdays vs. softer weekends.
2. **[TBD]** Peak demand hours — e.g. evening rush concentration.
3. **[TBD]** Fare and distance patterns — e.g. typical trip economics.
4. **[TBD]** Top pickup zones — e.g. central business district dominance.

_Export charts from `notebooks/exploration.ipynb` into `docs/screenshots/` for portfolio use._

## Recommendations

1. **[TBD]** Operational — e.g. shift driver supply toward peak hours.
2. **[TBD]** Zone focus — e.g. prioritize high-revenue pickup areas.
3. **[TBD]** Pricing / product — e.g. investigate long-duration outliers.

## Caveats

- Demo data is synthetic; re-run on real Chicago export before external sharing.
- Community area IDs require a lookup table for neighborhood names.
- Open-data lag and reporting quality may affect fare/tip fields.
