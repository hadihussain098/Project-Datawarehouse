/*
===============================================================================
DDL Script: Create Silver Layer Tables
===============================================================================
Description:
    This script defines the schemas and data blueprints for the Silver layer.
    Data types have been optimized, constraints applied, and spaces cleaned 
    relative to the raw staging tables in the Bronze layer.
===============================================================================
*/

-- Create the Silver schema if it doesn't already exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END;
GO

-- 1. CRM Customer Info Blueprint
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_material_status VARCHAR(20),
    cst_gnder           VARCHAR(20),
    cst_create_date     DATE
);
GO

-- 2. CRM Product Info Blueprint
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info (
    prd_id              INT,
    cat_id              VARCHAR(50),
    prd_key             VARCHAR(50),
    prd_nm              VARCHAR(100),
    prd_cost            INT,
    prd_line            VARCHAR(50),
    prd_start_dt        DATE,
    prd_end_dt          DATE
);
GO

-- 3. CRM Sales Details Blueprint
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO
CREATE TABLE silver.crm_sales_details (
    sls_ord_num         VARCHAR(50),
    sls_prd_key         VARCHAR(50),
    sls_cust_id         INT,
    sls_order_dt        DATE,
    sls_ship_dt         DATE,
    sls_due_dt          DATE,
    sls_sales           INT,
    sls_quant           INT,
    sls_price           INT
);
GO

-- 4. ERP Customer Details Blueprint
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO
CREATE TABLE silver.erp_cust_az12 (
    cid                 VARCHAR(50),
    bdate               DATE,
    gen                 VARCHAR(20)
);
GO

-- 5. ERP Location Details Blueprint
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO
CREATE TABLE silver.erp_loc_a101 (
    cid                 VARCHAR(50),
    cntry               VARCHAR(50)
);
GO

-- 6. ERP Product Category Blueprint
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO
CREATE TABLE silver.erp_px_cat_g1v2 (
    id                  INT,
    cat                 VARCHAR(50),
    subcat              VARCHAR(50),
    maintenance         VARCHAR(50)
);
GO
