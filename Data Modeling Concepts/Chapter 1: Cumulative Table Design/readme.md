# Cumulative Table Design
Cumulative table design is a critical concept in data modeling, particularly for maintaining historical data and ensuring comprehensive datasets for analysis. This chapter explores the methodology, use cases, and trade-offs of cumulative table design.

## What is a Cumulative Table?
A cumulative table retains historical data by combining daily snapshots. It merges today's data with the accumulated data from previous days, ensuring a complete history of changes for each entity. This design is often used in analytics for tracking user activity, transitions, and historical metrics.

## Key Characteristics:
History Preservation: Ensures no data is lost over time by maintaining a record of past states.
Full Outer Join: Combines today's and yesterday's data, allowing for unmatched rows in either dataset.
Coalescing Values: Resolves conflicts or nulls when data exists in only one of the tables.
Steps for Designing a Cumulative Table
Prepare Today's and Yesterday's Tables:

Ensure both tables have identical schemas.
Today's table contains new records; yesterday's table holds historical data.
- Full Outer Join: Merge both tables to retain all records, whether in one or both datasets.
- Coalesce Values: Resolve missing or updated values, preserving the latest information.
- Filter Irrelevant Data: Remove no longer needed entities, such as deactivated users.
- Generate Metrics: Compute historical metrics, such as days since the last activity or cumulative engagement.

![cumulative_table_design](https://github.com/user-attachments/assets/44571697-3e27-43b5-b5e1-9934e0a93373)

  
## Example Use Cases
- User Activity Tracking: Cumulative tables can track daily, weekly, and monthly active users, enabling analysis of user retention, churn, and resurrection patterns.

- State Transition Analysis: Monitor changes in user states (e.g., active, inactive, churned) by comparing today's and yesterday's data.

## Strengths:
- Scalable Queries: Directly query the latest data for insights without expensive joins or groupings.
- Historical Analysis: Analyze trends over time with minimal computation **avoiding shuffling**.
- Easy “transition” analysis
## Weaknesses:
- Sequential Backfilling: Backfilling data must follow chronological order, slowing batch processing.
- Data Growth: Tables grow daily, necessitating periodic pruning of irrelevant records. Complexity in Deleting Data: Handling PII or inactive users requires additional logic.

## Best Practices
- Regular Pruning: Define a clear retention policy to manage table size (e.g., drop users inactive for over 180 days).
- Optimize Queries: Use indexed or partitioned tables to handle large datasets efficiently.
- Clear Schema Design: Ensure schemas are intuitive for downstream consumers.

## Example with players_season dataset
![image](https://github.com/user-attachments/assets/3cc224b3-b312-43ae-b560-46467ba099c3)

### New Columns and Their Role in Cumulative Design
1. `season_stats:` Type: season_stats[] (an array of structured data containing season, games played, points, rebounds, and assists)
   - Each entry represents one season's statistics, allowing easy access to a player’s complete performance history.
   - By appending new season data or retaining existing stats during inactivity, season_stats ensures all historical data is preserved without complex joins.
2. `scoring_class:` Type: Enum ('star', 'good', 'average', 'bad')
   - This label is recalculated each season for active players and retained for inactive ones, enabling straightforward analysis of performance trends over time.

