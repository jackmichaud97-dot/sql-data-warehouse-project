/*
==================================================================================
DDL Script: Create Silver Tables
==================================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' tables
==================================================================================
*/

USE DataWarehouse
GO

--Creating the Tables

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info

CREATE TABLE silver.crm_cust_info (
	cst_id INT
	, cst_key NVARCHAR(50)
	, cst_firstname VARCHAR(50)
	, cst_lastname VARCHAR(50)
	, cst_marital_status VARCHAR(50)
	, cst_gnder VARCHAR(50)
	, cst_create_date DATE
	, dwh_create_date DATETIME2 DEFAULT GETDATE()
)
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info

CREATE TABLE silver.crm_prd_info (
	prd_id INT
	, cat_id NVARCHAR(50)
	, prd_key NVARCHAR(50)
	, prd_nm NVARCHAR(50)
	, prd_cost INT
	, prd_line VARCHAR(50)
	, prd_start_dt DATE
	, prd_end_dt DATE
	, dwh_create_date DATETIME2 DEFAULT GETDATE()
)
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details

CREATE TABLE silver.crm_sales_details (
	sls_ord_num NVARCHAR(50)
	, sls_prd_key NVARCHAR(50)
	, sls_cust_id INT
	, sls_order_dt DATE
	, sls_ship_dt DATE
	, sls_due_dt DATE
	, sls_sales INT
	, sls_quantity INT
	, sls_price INT
	, dwh_create_date DATETIME2 DEFAULT GETDATE()
)
IF OBJECT_ID('silver.erp_CUST_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_CUST_AZ12

CREATE TABLE silver.erp_CUST_AZ12 (
	CID NVARCHAR(50)
	, BDATE DATE
	, GEN VARCHAR(10)
	, dwh_create_date DATETIME2 DEFAULT GETDATE()
)
IF OBJECT_ID('silver.erp_LOCA101', 'U') IS NOT NULL
    DROP TABLE silver.erp_LOCA101

CREATE TABLE silver.erp_LOCA101 (
	CID NVARCHAR(50)
	, CNTRY VARCHAR(50)
	, dwh_create_date DATETIME2 DEFAULT GETDATE()
)
IF OBJECT_ID('silver.erp_px_CAT_G1V2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_CAT_G1V2

CREATE TABLE silver.erp_PX_CAT_G1V2 (
	ID NVARCHAR(10)
	, CAT VARCHAR(50)
	, SUBCAT VARCHAR(50)
	, MAINTENANCE VARCHAR(10)
	, dwh_create_date DATETIME2 DEFAULT GETDATE()
)
