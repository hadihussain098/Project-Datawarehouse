Create view gold.dim_customers As 
SELECT 
row_number() over(Order by cst_id) As customer_key,
    ci.cst_id As customer_id,
    ci.cst_key As customer_number,
    ci.cst_firstname As first_name,

    ci.cst_lastname As last_name,
    la.cntry As country,
    ci.cst_material_status As marital_status,
    Case when ci.cst_gnder != 'n/a' then ci.cst_gnder
        else coalesce(ca.gen, 'n/a')
    End As gender,
    ci.cst_create_date As create_date,
    ca.bdate As birthdate
    
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid

Create view gold.dim_products AS 

Select
	Row_number() over(order by pn.prd_start_dt) As product_key,
pn.prd_id As product_id,
pn.prd_key As prduct_number,
pn.prd_nm As product_name,
pn.cat_id As category_id,
pc.cat As category,
pc.subcat As subcategory,
pc.maintenance,

pn.prd_cost As cost,
pn.prd_line As product_line,
pn.prd_start_dt As start_date
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id = pc.id

where prd_end_dt is null -- filter out all historical data

Create view gold.fact_sales As 

Select
sd.sls_ord_num As order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt As order_date,
sd.sls_ship_dt As shipping_date,
sd.sls_due_dt As due_date,
sd.sls_sales As sales_amount,
sd.sls_quant As quantity,
sd.sls_price As price
from silver.crm_sales_details sd

left join gold.dim_products pr
on sd.sls_prd_key = pr.prduct_number
left join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id
