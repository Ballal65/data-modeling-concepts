# Data Modeling Essentials

## Overview

This repository is a comprehensive collection of example queries, concepts, and notebooks to explore powerful data modeling approaches and OLAP techniques for analyzing and managing big data. The project is built using **PostgreSQL** as the primary database, with supplementary support for **Apache Spark** to demonstrate scalability.

The repository is structured to address key data modeling concepts, each with example SQL queries and explanations.

---

## Goals

1. **Educate**: Provide clear, real-world examples of advanced data modeling and analysis techniques.
2. **Showcase Best Practices**: Highlight effective use cases for dimensional modeling, cumulative designs, slowly changing dimensions (SCD), and graph data modeling.
3. **Integrate Scalability**: Demonstrate the compatibility of these techniques with big data tools like **Apache Spark**.
4. **Provide Hands-On Learning**: Include SQL queries and Jupyter notebooks for experimentation.

---

## Folder Structure

Here’s the proposed folder structure for the project:

```
data-modeling-essentials/
├── Data Modeling Concepts/
│   ├── Cumulative Table Design/
│   │   ├── README.md
│   │   ├── cumulative_table_design.sql
│   ├── Graph Data Modeling/
│   │   ├── README.md
│   │   ├── graph_data_modeling.sql
│   ├── Incremental Build for SCD/
│   │   ├── README.md
│   │   ├── incremental_build_scd.sql
│   ├── Slowly Changing Dimensions/
│       ├── README.md
│       ├── scd_example.sql
├── SQL/
│   ├── example_queries.sql
│   ├── supporting_tables.sql
├── data_modeling_files/
│   ├── players_season.csv
│   ├── metadata/
├── spark_notebooks/
│   ├── scd_analysis.ipynb
│   ├── graph_modeling.ipynb
├── README.md
```

---

## Concepts Covered

### 1. **Cumulative Table Design**
   - **Description**: Tracks historical data cumulatively, preserving trends over time.
   - **SQL Examples**: Includes queries to calculate running totals, cumulative averages, and performance metrics.
   - **Use Cases**: Time-series analysis, revenue trends, and growth tracking.

### 2. **Graph Data Modeling**
   - **Description**: Focuses on relationships between entities, ideal for social networks and logistics.
   - **SQL Examples**: Demonstrates creating nodes and edges, and querying relationships.
   - **Use Cases**: Building recommendation systems, analyzing interconnected datasets.

### 3. **Incremental Build for Slowly Changing Dimensions (SCD)**
   - **Description**: Efficiently updates SCD Type 2 tables by processing only changed data.
   - **SQL Examples**: Includes queries for change detection and updating history.
   - **Use Cases**: Tracking employee status, product changes, and customer profiles.

### 4. **Slowly Changing Dimensions (SCD)**
   - **Description**: Captures changes to dimension attributes over time.
   - **SQL Examples**: Covers Type 0, Type 1, Type 2, and Type 3 implementations.
   - **Use Cases**: Maintaining historical accuracy for critical attributes.

---

## How to Use

1. **Explore Concepts**:
   - Navigate to the `Data Modeling Concepts` folder and pick a sub-concept to explore.
   - Read the `README.md` file for an overview.
   - Open the corresponding SQL file for queries.

2. **Run Queries**:
   - Import the provided SQL queries into your PostgreSQL instance.
   - Use the example data in the `data_modeling_files` folder to test the queries.

3. **Scale with Spark**:
   - Open notebooks in the `spark_notebooks` folder to try these concepts at scale using Apache Spark.

---

## Prerequisites

- **PostgreSQL**: Install and configure PostgreSQL for running SQL queries.
- **Apache Spark**: Set up Spark for scaling data models.
- **Python and Jupyter**: Required for running `.ipynb` notebooks.
