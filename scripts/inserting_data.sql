USE DataWarehouse 
GO

--Emptying table
TRUNCATE TABLE bronze.crm_cust_info

--Inserting data
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\Jack\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH (
	FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, TABLOCK
)

TRUNCATE TABLE bronze.crm_prd_info
BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\Jack\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH (
	FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, TABLOCK
)

TRUNCATE TABLE bronze.crm_sales_details
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\Jack\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH (
	FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, TABLOCK
)

TRUNCATE TABLE bronze.erp_CUST_AZ12
BULK INSERT bronze.erp_CUST_AZ12
FROM 'C:\Users\Jack\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
WITH (
	FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, TABLOCK
)

TRUNCATE TABLE bronze.erp_LOCA101
BULK INSERT bronze.erp_LOCA101
FROM 'C:\Users\Jack\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
WITH (
	FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, TABLOCK
)

TRUNCATE TABLE bronze.erp_PX_CAT_G1V2
BULK INSERT bronze.erp_PX_CAT_G1V2
FROM 'C:\Users\Jack\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
	FIRSTROW = 2
	, FIELDTERMINATOR = ','
	, TABLOCK
)
