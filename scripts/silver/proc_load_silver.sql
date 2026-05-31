/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.
Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.
Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/



Create or alter procedure silver.load_silver
As BEGIN

	Set nocount on; 

	DECLARE @batch_error_occurred INT = 0;

	Begin Try
	PRINT '==================================================';
    PRINT 'STARTING SILVER LAYER PIPELINE BATCH PROCESS';
    PRINT '==================================================';


	PRINT '>> Starting Step 1: silver.crm_cust_info';
	print '>> Truncating table: Silver.crm_cust_info';
	Truncate Table silver.crm_cust_info;
	print '>> Inserting Data into: silver.crm_cust_info';

	Insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gnder,
		cst_create_date)
	Select 
	cst_id,
	cst_key,
	trim(cst_firstname) As cst_firstname,
	trim(cst_lastname) as cst_lastname,
	Case when Upper(Trim (cst_material_status)) = 'S' then 'Single'
		when Upper(Trim (cst_material_status)) = 'M' then 'Married'
	End cst_material_status,
	Case when Upper(Trim (cst_gnder)) = 'F' then 'Female'
		when Upper(Trim (cst_gnder )) = 'M' then 'Male'
		Else 'n/a'
	End cst_gnder,
	cst_create_date

	from (

		Select
		*,
		Row_number() over(Partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	)t where flag_last = 1


	PRINT '>> SUCCESS: silver.crm_cust_info fully loaded.';
    PRINT '--------------------------------------------------';

	PRINT '>> Starting Step 2: silver.crm_prd_info';
	
	Print '>> Truncating table: Silver.crm_prd_info';
	Truncate Table silver.crm_prd_info;
	print '>> Inserting Data into: silver.crm_prd_info';


	Insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)


	Select
	prd_id,
	Replace(Substring(prd_key, 1,5), '-', '_') as cat_id,
	Substring(prd_key, 7, len(prd_key)) as prd_key,
	prd_nm,
	Isnull(prd_cost, 0) As prd_cost,

	Case when Upper(Trim(prd_line)) = 'M' Then 'Mountain'
		 when Upper(Trim(prd_line)) = 'R' Then 'Road'
		 when Upper(Trim(prd_line)) = 'S' Then 'Other Sales'
		 when Upper(Trim(prd_line)) = 'T' Then 'Touring'
		Else 'n/a'
	End As prd_line,
	Cast(prd_start_dt As Date) AS prd_start_dt,
	cast(lead(prd_start_dt) over(partition by prd_key Order by prd_start_dt) -1 As Date) As prd_end_dt
	From (

		Select 
	*
	from 
	(
		Select
		*,
		row_number() over(partition by prd_id Order By prd_start_dt Desc) As flag_last
		from bronze.crm_prd_info
	)t
	where flag_last = 1 And prd_id is Not null
	) a

	PRINT '>> SUCCESS: silver.crm_prd_info fully loaded.';
	PRINT '--------------------------------------------------';

	PRINT '>> Starting Step 3: silver.crm_sales_details';

	Print '>> Truncating table: Silver.crm_sales_details';
	Truncate Table silver.crm_sales_details;
	print '>> Inserting Data into: silver.crm_sales_details';

	Insert into silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quant,
		sls_price


	)

	Select 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,

	Case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
		else cast(cast(sls_order_dt as varchar) As Date)
	End As sls_order_dt,

	Case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
		else cast(cast(sls_ship_dt as varchar) As Date)
	End as sls_ship_dt,
	Case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
		else cast(cast(sls_due_dt as varchar) As Date)
	End as sls_due_dt,
	Case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quant * abs(sls_price)
		then sls_quant *  abs(sls_price)
		else sls_sales
	End As sls_sales,
	sls_quant,

	Case when sls_price is null or sls_price <= 0
		then sls_sales/nullif(sls_quant,0)
		else sls_price
	end as sls_price
	from bronze.crm_sales_details

	PRINT '>> SUCCESS: silver.crm_sales_details fully loaded.';
	PRINT '--------------------------------------------------';

	PRINT '>> Starting Step 4: silver.erp_cust_az12';



	Print '>> Truncating table: Silver.erp_cust_az12';
	Truncate Table silver.erp_cust_az12;
	print '>> Inserting Data into: Silver.erp_cust_az12';

	Insert into silver.erp_cust_az12 (
		cid,
		bdate,
		gen
	)
	

	Select

	Case when cid like 'NAS%' Then substring(cid,4, len(cid))
		else cid
	end cid,

	Case when bdate > getdate() then null
		else bdate
	End as bdate,

	Case when Upper(Trim(gen)) in ('F', 'Female') then 'Female'
		when Upper(Trim(gen)) in ('M', 'Male') then 'Male'
		else 'n/a'
	End as gen
	from bronze.erp_cust_az12
	where bdate < '1924-01-01' or bdate > getdate()

	PRINT '>> SUCCESS: silver.erp_cust_az12 fully loaded.';
    PRINT '--------------------------------------------------';


	PRINT '>> Starting Step 5: silver.erp_loc_a101';


	Print '>> Truncating table: Silver.erp_loc_a101';
	Truncate Table silver.erp_loc_a102;
	print '>> Inserting Data into: Silver.erp_loc_a101';

	INSERT INTO silver.erp_loc_a101 (cid, cntry)
	SELECT
		REPLACE(cid, '-', '') AS cid,
		CASE 
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END AS cntry
	FROM bronze.erp_loc_a101;

	PRINT '>> SUCCESS: silver.erp_loc_a101 fully loaded.';
    PRINT '--------------------------------------------------';

	PRINT '>> Starting Step 6: silver.erp_px_cat_g1v2';


	Print '>> Truncating table: Silver.erp_px_cat_g1v2';
	Truncate Table silver.erp_px_cat_g1v2;
	print '>> Inserting Data into: Silver.erp_px_cat_g1v2';

	Insert into silver.erp_px_cat_g1v2(
		id,
		cat,
		subcat,
		maintenance
	)


	Select
	id,
	cat,
	subcat,
	maintenance
	from bronze.erp_px_cat_g1v2

	PRINT '>> SUCCESS: silver.erp_px_cat_g1v2 fully loaded.';
    PRINT '--------------------------------------------------';

    PRINT '==================================================';
    PRINT 'SILVER LAYER PIPELINE BATCH PROCESS COMPLETE';
    PRINT '==================================================';


	End Try 
	Begin Catch 
		Set @batch_error_occurred = 1;

		PRINT '==================================================';
        PRINT '!!! CRITICAL ERROR OCCURRED DURING BATCH LOAD !!!';
        -- ERROR_MESSAGE() captures the exact reason why the query broke
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '==================================================';
    END CATCH;
End
