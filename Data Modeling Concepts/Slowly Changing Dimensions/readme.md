# Slowly Changing Dimensions (SCD)

## Overview

Slowly Changing Dimensions (SCD) are a type of data modeling approach used to track changes to dimension attributes over time in a data warehouse. Unlike static dimensions, SCDs enable organizations to maintain historical accuracy and analyze trends across different time periods.

## Why SCDs Are Important

1. **Historical Tracking**: SCDs allow you to retain and query historical records of changes.
2. **Analytics Enablement**: By preserving attribute changes over time, SCDs empower deeper analytics, such as customer behavior or product performance.
3. **Data Integrity**: Properly designed SCDs ensure consistent and accurate results across backfills and real-time runs.

## Types of Slowly Changing Dimensions

### Type 0: Fixed Dimensions
- **Definition**: Attributes that do not change over time.
- **Use Case**: Immutable information like a person's birthdate or a product's initial launch date.
- **Advantages**: Simple design, high data integrity.

### Type 1: Overwrite
- **Definition**: Only the current value is stored. Historical data is overwritten.
- **Use Case**: Non-critical attributes where historical tracking is not needed.
- **Disadvantages**: Loses historical data, not idempotent.

### Type 2: Add New Row
- **Definition**: A new row is added with a start and end date when an attribute changes.
- **Use Case**: Tracking historical data for critical attributes like customer addresses.
- **Advantages**: Retains full history, idempotent.
- **Best Practices**:
  - Use a high future date (e.g., `9999-12-31`) or `NULL` for open-ended rows.
  - Include a Boolean `is_current` field for quick access to active records.

### Type 3: Add New Column
- **Definition**: Adds columns to store both current and previous values.
- **Use Case**: Scenarios with minimal changes, such as "original manager" vs. "current manager."
- **Disadvantages**: Limited historical tracking, not idempotent for frequent changes.

### Advanced Types
- **Type 4 and beyond**: Rarely used but involve hybrid approaches, such as separating historical and current data into different tables.

## Implementation Strategies

1. **Batch Processing**:
   - Load the entire dataset and apply transformations to identify changes.
   - Suitable for smaller datasets.

2. **Incremental Updates**:
   - Process only new or updated records.
   - Scales well with larger datasets.

## Common Challenges and Solutions

### 1. Idempotency
- **Problem**: Non-idempotent pipelines can produce inconsistent results during backfills.
- **Solution**:
  - Use `MERGE` or `UPSERT` operations instead of `INSERT INTO`.
  - Avoid using filters like `WHERE date > yesterday` without a fixed end date.

### 2. Performance
- **Problem**: Large SCD tables can impact query performance.
- **Solution**:
  - Partition by date or other high-cardinality fields.
  - Archive older data.

## Tools and Technologies
- **Databases**: PostgreSQL, Snowflake, BigQuery.
- **ETL Tools**: Apache Airflow, dbt, Spark.
- **Query Patterns**:
  - `MERGE` statements for incremental updates.
  - `INSERT OVERWRITE` for partitioned updates.

## Example: SCD Type 2 Table Structure

| ID  | Attribute  | Start Date | End Date     | Is Current |
|-----|------------|------------|--------------|------------|
| 101 | Lasagna    | 2000-01-01 | 2010-12-31   | FALSE      |
| 101 | Curry      | 2011-01-01 | 9999-12-31   | TRUE       |

## Conclusion

Slowly Changing Dimensions are crucial for maintaining accurate historical data in data warehouses. While Type 0 and Type 2 are the most commonly used due to their simplicity and reliability, choosing the right approach depends on the business requirements and data usage patterns.