DROP TABLE IF EXISTS bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,    -- Changed from DATE to INT
    sls_ship_dt  INT,    -- Changed from DATE to INT
    sls_due_dt   INT,    -- Changed from DATE to INT
    sls_sales    FLOAT,
    sls_quant    INT,
    sls_price    FLOAT
);


Create Table bronze.crm_cust_info(
	cst_id INT,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_gnder nvarchar(50),
	cst_create_date Date
	);


CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(100),
    prd_cost float,
    prd_line NVARCHAR(10),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

CREATE TABLE bronze.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATETIME,
    gen NVARCHAR(50)
);

CREATE TABLE bronze.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(10)
);
