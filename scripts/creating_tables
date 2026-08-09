USE DataWarehouse
GO

--Creating the Tables 
CREATE TABLE bronze.crm_cust_info (
	cst_id INT
	, cst_key NVARCHAR(50)
	, cst_firstname VARCHAR(50)
	, cst_lastname VARCHAR(50)
	, cst_marital_status CHAR(1)
	, cst_gnder CHAR(2)
	, cst_create_date DATE
)

CREATE TABLE bronze.crm_prd_info (
	prd_id INT
	, prd_key NVARCHAR(50)
	, prd_nm NVARCHAR(50)
	, prd_cost INT
	, prd_start_dt DATE
	, prd_end_dt DATE
)

CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50)
	, sls_prd_key NVARCHAR(50)
	, sls_cust_id INT
	, sls_order_dt INT
	, sls_ship_dt INT
	, sls_due_dt INT
	, sls_sales INT
	, sls_quantity INT
	, sls_price INT
)

CREATE TABLE bronze.erp_CUST_AZ12 (
	CID NVARCHAR(50)
	, BDATE DATE
	, GEN VARCHAR(10)
)

CREATE TABLE bronze.erp_LOCA101 (
	CID NVARCHAR(50)
	, CNTRY VARCHAR(50)
)

CREATE TABLE bronze.erp_PX_CAT_G1V2 (
	ID NVARCHAR(10)
	, CAT VARCHAR(50)
	, SUBCAT VARCHAR(50)
	, MAINTENANCE VARCHAR(10)
)
