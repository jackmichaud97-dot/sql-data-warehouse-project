# SQL Data Warehouse Project

A hands-on data warehouse built from scratch in SQL Server, using the **Medallion Architecture** (Bronze → Silver → Gold). It ingests raw CRM and ERP data from CSV files, cleans and standardizes it, and models it into a star schema that's ready for analytics and reporting.

This is a learning project I completed by following along with [Data with Baraa's *SQL Data Warehouse from Scratch* walkthrough](https://www.youtube.com/watch?v=9GVqKuTVANE). My goals were to:

- Practice and reinforce the SQL skills from my MSBA on a hands-on, real-world-adjacent project
- Build a repeatable workflow and project structure I can reuse for future data warehouse builds
- Get comfortable with the end-to-end ETL flow: raw ingestion, layered transformation, dimensional modeling, and data-quality testing

---

## Architecture

The warehouse follows the Medallion Architecture, separating raw ingestion, cleansing, and business modeling into three schemas.

docs/data_architecture.drawio.png

| Layer | Object Type | Load Pattern | Transformations | Data Model |
|-------|-------------|--------------|-----------------|------------|
| **Bronze** | Tables | Batch, full load, truncate & insert | None (raw, as-is) | None |
| **Silver** | Tables | Batch, full load, truncate & insert | Cleansing, standardization, normalization, derived columns, enrichment | None (as-is) |
| **Gold** | Views | No load (queried live) | Integration, business logic, aggregation | Star schema |

- **Bronze** — raw data loaded directly from the source CSVs with `BULK INSERT`, no changes.
- **Silver** — cleaned and conformed: trimmed strings, normalized codes (gender, marital status, country), recalculated invalid sales/price values, derived category IDs and product end-dates, and deduplicated customers to the most recent record.
- **Gold** — business-ready views that join CRM and ERP data into dimensions and a fact table.

---

## Data Flow

Source tables flow through each layer, with the six source objects consolidating into two dimensions and one fact by the Gold layer.

docs/Data Flow Diagram.drawio.png

---

## Data Integration Model

How the CRM and ERP source tables relate before modeling. CRM is the master for product and customer records; ERP tables enrich them with categories, birthdates, and location/country.

docs/integration_model.drawio.png

---

## Data Model (Star Schema)

The Gold layer exposes a classic star schema — one fact table surrounded by two dimensions.

docs/Data_model.drawio.png

- **gold.fact_sales** — one row per sales order line (`sales_amount`, `quantity`, `price`), with foreign keys to the two dimensions. Sales = Quantity × Price.
- **gold.dim_customers** — customer attributes from CRM enriched with ERP birthdate, gender, and country.
- **gold.dim_products** — current product records enriched with ERP category, subcategory, and maintenance flag (historical rows filtered out via `prd_end_dt IS NULL`).

---

## Tech Stack

- **SQL Server** (T-SQL) — database engine
- **SQL Server Management Studio (SSMS)** — development
- **BULK INSERT** — CSV ingestion
- **Stored procedures** — repeatable, logged ETL loads with error handling
- **Views** — the Gold presentation layer
- **draw.io /** — architecture and data-model diagrams

---

## Repository Structure

```
sql-data-warehouse-project/
├── datasets/                   # Raw source CSVs
│   ├── source_crm/             # cust_info, prd_info, sales_details
│   └── source_erp/             # CUST_AZ12, LOC_A101, PX_CAT_G1V2
├── docs/                       # Diagrams (.drawio) and exported images
│   ├── data_architecture.drawio
│   ├── data_flow.drawio
│   ├── data_integration_model.drawio
│   └── data_model.drawio
├── scripts/
│   ├── init_database.sql       # Create DataWarehouse + bronze/silver/gold schemas
│   ├── bronze/
│   │   ├── ddl_bronze.sql      # Bronze table definitions
│   │   └── proc_load_bronze.sql
│   ├── silver/
│   │   ├── ddl_silver.sql      # Silver table definitions
│   │   └── proc_load_silver.sql
│   └── gold/
│       └── ddl_gold.sql        # Gold dimension & fact views
├── tests/
│   ├── quality_checks_silver.sql
│   └── quality_checks_gold.sql
└── README.md
```

> Note: diagrams are stored as `.drawio` files. GitHub renders `.drawio` as XML, not as an image, so export each one to `.png` (or `.drawio.svg` to keep it editable) into `docs/` for the images above to display.

---

## Data Sources

Two source systems, delivered as CSV files:

- **CRM** — `cust_info`, `prd_info`, `sales_details` (customers, products, sales & orders)
- **ERP** — `CUST_AZ12` (birthdate/gender), `LOC_A101` (country), `PX_CAT_G1V2` (product categories)

---

## How to Run

1. **Create the database and schemas** — run `scripts/init_database.sql`.
   > This drops and recreates the `DataWarehouse` database. Don't run it against a server where that name is already in use.
2. **Create the tables** — run `scripts/bronze/ddl_bronze.sql` then `scripts/silver/ddl_silver.sql`.
3. **Update the file paths** — edit the `BULK INSERT` paths in `proc_load_bronze.sql` to point at your local `datasets/` folder.
4. **Load Bronze** — `EXEC bronze.load_bronze;`
5. **Load Silver** — `EXEC silver.load_silver;`
6. **Create the Gold views** — run `scripts/gold/ddl_gold.sql`.
7. **Validate** — run the scripts in `tests/`. Each check is written to return **no rows** when the data is clean.

---

## Skills Practiced

Building this reinforced a range of SQL and data-engineering concepts:

- **Window functions** — `ROW_NUMBER()` for deduplication, `LEAD()` for deriving product end-dates (SCD-style history)
- **Data cleansing & standardization** — `TRIM`, `CASE` mapping of codes to readable values, handling NULLs and invalid dates
- **Data validation logic** — recalculating sales/price when source values are missing or inconsistent
- **Dimensional modeling** — surrogate keys, dimensions vs. facts, star schema design
- **Stored procedures** — parameterless ETL procs with `TRY...CATCH` error handling and `PRINT`-based load logging
- **Bulk ingestion** — `BULK INSERT` from CSV into staging tables
- **Views** — separating a business-facing layer from physical storage
- **Data quality testing** — uniqueness, referential integrity, range, and consistency checks per layer

---

## Credits

Built by following [Data with Baraa — *SQL Data Warehouse from Scratch | Full Hands-On Data Engineering Project*](https://www.youtube.com/watch?v=9GVqKuTVANE). Full credit to Baraa for the project design, source data, and walkthrough. This repository is my own implementation and notes, completed for learning purposes.

---

## About

Completed as a portfolio project to practice SQL from my MSBA and establish a reusable data-warehouse workflow.

Jackson Michaud, https://www.linkedin.com/in/jackson-michaud-013981195/
