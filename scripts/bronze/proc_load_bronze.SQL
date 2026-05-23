USE [DataWarehouse]
GO
/****** Object:  StoredProcedure [bronze].[load_bronze]    Script Date: 5/23/2026 2:19:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   procedure [bronze].[load_bronze] AS


Begin
    Declare @start_time Datetime, @end_time Datetime;
    
    Begin Try

        print '-----------------------------';
        print 'Loading Bronze Layer';
        print 'Loading CRM Tables';


        Set @start_time = GetDate();

        Bulk Insert bronze.crm_prd_info
        From 'C:\Users\hadih\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        with (
	        FirstRow = 2,
	        Fieldterminator = ',',
	        Tablock
        );




        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\hadih\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );


        print '-----------------------------';
        print 'Loading Bronze Layer';
        print 'Loading ERP Tables';

        Print'Inserting Data into table ERP'

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\hadih\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\hadih\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\hadih\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        Set @end_time = GetDate();

        print '>> Load Duration : ' + Cast(Datediff(second, @start_time, @end_time) As nvarchar) + 'seconds'

    End try
    Begin Catch
        print '============================'
        print 'Error Occured During loading bronze layer'

    End Catch

End
