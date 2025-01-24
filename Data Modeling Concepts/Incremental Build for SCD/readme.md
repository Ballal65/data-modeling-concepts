# README: Incremental Build for Slowly Changing Dimensions (SCD)

## Overview
This README explains the iterative query process for creating and maintaining **Slowly Changing Dimensions (SCD) Type 2** tables. The focus is on transitioning from full historical data processing to an **incremental build** approach, which is more efficient for large datasets. 

The incremental query design ensures historical accuracy by processing only new or changed data and updating the SCD table accordingly.

---

## Goals
1. **Historical Tracking**: Maintain detailed records of changes to dimensions like player activity and scoring class over time.
2. **Efficiency**: Reduce the computational overhead by limiting the data processed during each run.
3. **Consistency**: Ensure the pipeline remains idempotent and supports both production and backfill scenarios.

---

## Key Concepts

### Input Tables
- **Players Table**: Contains records of all players and their attributes for the current season.
- **Player Seasons Table**: Tracks player statistics by season.

### Output Table
- **Players SCD Table**: Records historical changes for dimensions using SCD Type 2. Columns include:
  - `player_name`
  - `scoring_class`
  - `is_active`
  - `start_season`
  - `end_season`
  - `current_season`

### Challenges Solved
1. **Change Detection**: Identify changes in `scoring_class` or `is_active` attributes using window functions.
2. **Efficient Updates**: Process only current and previous season data.
3. **Record Management**:
   - Update existing records with an `end_season`.
   - Add new records for changed or new players.

---

## Query Breakdown

### 1. Historical Data
The query separates **unchanged historical records** from those requiring updates:
```sql
WITH historical_scd AS (
    SELECT *
    FROM players_scd
    WHERE end_season < 2021
)
```
These records are finalized and do not require further modification.

### 2. Current Season Data
Extract current season data:
```sql
WITH current_season_data AS (
    SELECT *
    FROM players
    WHERE current_season = 2022
)
```
This subset ensures only the latest data is considered for processing.

### 3. Last Season Data
Fetch records from the SCD table for the most recent completed season:
```sql
WITH last_season_scd AS (
    SELECT *
    FROM players_scd
    WHERE current_season = 2021
)
```

### 4. Change Detection
Using `LEFT JOIN` and comparison logic, detect changes in attributes (`scoring_class` and `is_active`) and classify records as:
- **Unchanged**: Extend `end_season` by one year.
- **Changed**: Close existing records and create new ones.
- **New**: Add records for players not present in the previous season.

#### Example Change Indicator:
```sql
WITH with_indicators AS (
    SELECT 
        t.player_name,
        t.scoring_class,
        t.is_active,
        t.current_season,
        CASE WHEN t.scoring_class <> l.scoring_class OR t.is_active <> l.is_active THEN 1 ELSE 0 END AS change_indicator
    FROM current_season_data t
    LEFT JOIN last_season_scd l
    ON t.player_name = l.player_name
)
```

### 5. Streak Identification
Track streaks by identifying sequential periods with the same attribute values using window functions:
```sql
WITH streaks AS (
    SELECT 
        player_name,
        SUM(change_indicator) OVER (PARTITION BY player_name ORDER BY current_season) AS streak_id
    FROM with_indicators
)
```

### 6. Aggregation
Aggregate streaks into compact SCD records:
```sql
SELECT 
    player_name,
    scoring_class,
    is_active,
    MIN(current_season) AS start_season,
    MAX(current_season) AS end_season
FROM streaks
GROUP BY player_name, scoring_class, is_active, streak_id
```

### 7. Final Union
Combine the processed records:
```sql
SELECT * FROM historical_scd
UNION ALL
SELECT * FROM updated_scd
UNION ALL
SELECT * FROM new_records;
```

---

## Example Use Case: Michael Jordan
Track Michael Jordan’s career transitions:

| Player Name      | Scoring Class | Is Active | Start Season | End Season |
|------------------|---------------|-----------|--------------|------------|
| Michael Jordan   | Star          | TRUE      | 1984         | 1993       |
| Michael Jordan   | Retired       | FALSE     | 1994         | 1994       |
| Michael Jordan   | Star          | TRUE      | 1995         | 1998       |
| Michael Jordan   | Retired       | FALSE     | 1999         | 2000       |
| Michael Jordan   | Star          | TRUE      | 2001         | 2003       |

---

## Benefits of Incremental Build
1. **Performance**: Processes only a small subset of data (current and last season).
2. **Scalability**: Supports large datasets without requiring full table scans.
3. **Maintainability**: Simplifies debugging by isolating changes.

---

## Assumptions
- Attributes like `scoring_class` and `is_active` are non-null.
- Historical records are finalized and immutable.
- Incremental builds rely on sequential updates.

---

## Limitations
- Cannot process records independently of prior season data.
- Additional complexity compared to full historical processing.

---

## Summary
This approach enables efficient, scalable, and accurate updates to SCD Type 2 tables. While slightly more complex, it ensures high performance for large-scale data pipelines and maintains data quality over time.