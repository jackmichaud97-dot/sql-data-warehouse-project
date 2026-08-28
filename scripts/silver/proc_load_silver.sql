/*
=====================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=====================================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
  Actions Performed:
    - Truncate Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver
====================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME
			, @end_time DATETIME
			, @batch_start_time DATETIME
			, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT '=============================================='
		PRINT 'Loading Silver Layer'
		PRINT '=============================================='

		PRINT '----------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '----------------------------------------------'
	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.crm_prd_info'
	TRUNCATE TABLE silver.crm_prd_info
	PRINT '>> Inserting Data Into: silver.crm_prd_cust_info'
	INSERT INTO silver.crm_prd_info (
		prd_id
		, cat_id 
		, prd_key 
		, prd_nm 
		, prd_cost 
		, prd_line 
		, prd_start_dt 
		, prd_end_dt 
	)
	SELECT p.prd_id
			, REPLACE(SUBSTRING(p.prd_key, 1, 5), '-', '_') cat_id -- Extract category ID
			, SUBSTRING(p.prd_key, 7, LEN(p.prd_key)) prd_key -- Extract product ID
			, TRIM(p.prd_nm) prd_nm
			, COALESCE(p.prd_cost, 0) prd_cost 
			, CASE UPPER(TRIM(p.prd_line))
					WHEN 'M' THEN 'Mountain'
					WHEN 'R' THEN 'Road'
					WHEN 'S' THEN 'other Sales'
					WHEN 'T' THEN 'Touring'
					ELSE 'N/A'
				END prd_line -- Map product line codes to descriptive values
			, p.prd_start_dt
			, CAST(DATEADD(DAY, -1, LEAD(p.prd_start_dt) OVER (PARTITION BY p.prd_key ORDER BY p.prd_start_dt ASC)) AS DATE
					) prd_end_dt -- Calculate end date as one day before the next start date
	FROM bronze.crm_prd_info p
	SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.'
		PRINT '>> ------------'

	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.crm_cust_info'
	TRUNCATE TABLE silver.crm_cust_info
	PRINT '>> Inserting Data Into: silver.crm_cust_info'
	INSERT INTO silver.crm_cust_info (
		cst_id
		, cst_key
		, cst_firstname
		, cst_lastname
		, cst_marital_status
		, cst_gnder
		, cst_create_date)
	SELECT sub.cst_id
			, sub.cst_key
			, TRIM(sub.cst_firstname) cst_firstname
			, TRIM(sub.cst_lastname) cst_lastname
			, CASE WHEN UPPER(TRIM(sub.cst_marital_status)) = 'M' THEN 'Married'
					WHEN UPPER(TRIM(sub.cst_marital_status)) = 'S' THEN 'Single'
					ELSE 'N/A'
			END cst_marital_status -- Normalize marital status values to readable format.
			, CASE WHEN UPPER(TRIM(sub.cst_gnder)) = 'F' THEN 'Female'
					WHEN UPPER(TRIM(sub.cst_gnder)) = 'M' THEN 'Male'
					ELSE 'N/A'
			END cst_gnder --Normalize gender values to readable format
			, sub.cst_create_date
	FROM (

	SELECT c.*
			, ROW_NUMBER() OVER (PARTITION BY c.cst_id ORDER BY c.cst_create_date DESC) [Most Recent]
	FROM bronze.crm_cust_info c
	WHERE c.cst_id IS NOT NULL
	) sub WHERE sub.[Most Recent] = 1 -- Select the most recent record per customer
	SET @end_time = GETDATE()
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.'
		PRINT '>> ------------'

	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.crm_sales_details'
	TRUNCATE TABLE silver.crm_sales_details
	PRINT '>> Inserting Data Into: silver.crm_sales_details'
	INSERT INTO silver.crm_sales_details (
		 sls_ord_num 
		, sls_prd_key
		, sls_cust_id
		, sls_order_dt
		, sls_ship_dt 
		, sls_due_dt
		, sls_sales
		, sls_quantity
		, sls_price
	)
	SELECT s.sls_ord_num
		  ,s.sls_prd_key
		  ,s.sls_cust_id
		  ,CASE WHEN s.sls_order_dt = 0 OR LEN(s.sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(s.sls_order_dt AS VARCHAR) AS DATE) 
				END sls_order_dt
		  ,CASE WHEN s.sls_ship_dt = 0 OR LEN(s.sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(s.sls_ship_dt AS VARCHAR) AS DATE)
				END sls_ship_dt
		  ,CASE WHEN s.sls_due_dt = 0 OR LEN(s.sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(s.sls_due_dt AS VARCHAR) AS DATE) 
				END sls_due_dt
		  ,CASE WHEN s.sls_sales <= 0 OR s.sls_sales IS NULL OR s.sls_sales != s.sls_quantity * ABS(s.sls_price) 
					THEN s.sls_quantity * ABS(s.sls_price)
				ELSE s.sls_sales
				END sls_sales -- Recalculate sales if original value is missing or incorrect
		  ,CASE WHEN s.sls_price <= 0 OR s.sls_price IS NULL 
					THEN s.sls_sales / NULLIF(s.sls_quantity, 0)
				ELSE s.sls_price
				END sls_price -- Derive price if original value is invalid
		  ,s.sls_quantity
	FROM bronze.crm_sales_details s
	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.'
	PRINT '>> ------------'

	PRINT '----------------------------------------------'
	PRINT 'Loading ERP Tables'
	PRINT '----------------------------------------------'
	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.erp_CUST_AZ12'
	TRUNCATE TABLE silver.erp_CUST_AZ12
	PRINT '>> Inserting Data Into: silver.erp_CUST_AZ12'
	INSERT INTO silver.erp_CUST_AZ12 (cid, bdate, gen)
	SELECT CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID)) -- Remove 'NAS' prefix if present
				   ELSE CID
			  END CID
			,CASE WHEN BDATE > GETDATE() THEN NULL -- Set future birthdays to NULL
					ELSE bdate
			END AS bdate
			, CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
				   WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
				   ELSE 'N/A'
			   END AS gen -- Normalize gender values and handle unknown cases
	FROM bronze.erp_CUST_AZ12
	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.'
	PRINT '>> ------------'


	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.erp_LOCA101'
	TRUNCATE TABLE silver.erp_LOCA101
	PRINT '>> Inserting Data Into: silver.erp_LOCA101'
	INSERT INTO silver.erp_LOCA101(cid, cntry)
	SELECT REPLACE(cid, '-', '') cid
			, CASE WHEN UPPER(TRIM(cntry)) IN ('US', 'UNITED STATES', 'USA') THEN 'United States'
					WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
					WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'N/A'
					ELSE TRIM(cntry)
				END cntry -- Normalize and Handle missing or bank country codes
	FROM bronze.erp_loca101
	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.'
	PRINT '>> ------------'


	SET @start_time = GETDATE()
	PRINT '>> Truncating Table: silver.erp_PX_CAT_G1V2'
	TRUNCATE TABLE silver.erp_PX_CAT_G1V2
	PRINT '>> Inserting Data Into: silver.erp_PX_CAT_G1V2'
	INSERT INTO silver.erp_PX_CAT_G1V2 (id, cat, subcat, MAINTENANCE)
	SELECT id
			, cat
			, subcat
			, maintenance
	FROM bronze.erp_PX_CAT_G1V2
	SET @end_time = GETDATE()
	PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds.'
	PRINT '>> ------------'
	SET @batch_end_time = GETDATE()
		PRINT '============================='
		PRINT '>> Total Load Duration of Silver Layer: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds.'
		PRINT '============================='
	END TRY
	BEGIN CATCH
		PRINT '==============================='
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE()
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT '==============================='
	END CATCH
END
