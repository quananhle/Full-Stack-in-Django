CREATE OR REPLACE FUNCTION public.shp_commercial_invoice_header_fn(transtype character varying, v_orderno character varying)
 RETURNS TABLE(rowid integer, field character varying, fieldname character varying, fieldvalue character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_salesorder		VARCHAR(50);

	v_billto_name		VARCHAR(100);
	v_billto_address	VARCHAR(255);
	v_billto_city		VARCHAR(50);
	v_billto_region		VARCHAR(50);
	v_billto_country	VARCHAR(50);
	v_billto_zip		VARCHAR(50);

	v_shipto_name		VARCHAR(50);
	v_shipto_street		VARCHAR(100);
	v_shipto_city		VARCHAR(50);
	v_shipto_region		VARCHAR(50);
	v_shipto_country	VARCHAR(50);
	v_shipto_zip    	VARCHAR(255);

	v_shipdate		VARCHAR(50);
	v_invoice_no		VARCHAR(50);
	v_incoterm		VARCHAR(50);
	v_carrier		VARCHAR(50);
	v_trackingno		VARCHAR(50);

	v_palletqty		INT;
	v_gross_weight		VARCHAR(50);

	v_total_price		INT;

	v_shipper_name		VARCHAR(50);
	v_shipper_add1		VARCHAR(50);
	v_shipper_add2		VARCHAR(50);
	v_shipper_city		VARCHAR(50);
	v_shipper_country	VARCHAR(50);

	v_seller_name		VARCHAR(50);
	v_seller_add1		VARCHAR(50);
	v_seller_add2		VARCHAR(50);
	v_seller_country	VARCHAR(50);
	v_seller_zipcode	VARCHAR(50);
	v_seller_taxID		VARCHAR(50);


BEGIN
    IF transtype IS NULL THEN
        RAISE EXCEPTION 'Transaction type can not be null';
    END IF;

    IF transtype = 'HEADER' THEN

     	SELECT 'Elon Musk'				INTO v_shipper_name;
    	SELECT 'Tesla Headquarters - Gigafactory Texas' INTO v_shipper_add1;
    	SELECT '1 Tesla Road' 				INTO v_shipper_add2;
    	SELECT 'Austin, TX 78725' 			INTO v_shipper_city;
    	SELECT 'USA' 					INTO v_shipper_country;
    	SELECT 'George Washington' 			INTO v_seller_name;
    	SELECT '1600 Pennsylvania Avenue NW' 		INTO v_seller_add1;
    	SELECT 'Washington, DC' 			INTO v_seller_add2;
    	SELECT 'United States' 				INTO v_seller_country;
    	SELECT '20500' 					INTO v_seller_zipcode;
    	SELECT 'TAX ID 777888999' 			INTO v_seller_taxID;
   
    	SELECT salesorder_id INTO v_salesorder FROM shp_deliverynumber WHERE deliverynumber_id = v_orderno;

        IF NOT EXISTS(SELECT 0 FROM shp_shipload WHERE deliverynumber_id = v_orderno AND salesorder_id = v_salesorder) THEN
        	RAISE EXCEPTION 'There is no Truck Load data for this DN. Call IT';
        END IF;

       	SELECT tracking_no, carrier INTO v_trackingno, v_carrier FROM shp_shipload WHERE deliverynumber_id = v_orderno AND salesorder_id = v_salesorder;

       	SELECT bill_to_name, bill_to_address, bill_to_city, bill_to_region, bill_to_country, bill_to_zipcode, ship_to_name, ship_to_street, 
       		   ship_to_city, ship_to_region, ship_to_country, ship_to_zipcode, incoterm
       	INTO v_billto_name, v_billto_address, v_billto_city, v_billto_region, v_billto_country, v_billto_zip, v_shipto_name, v_shipto_street,
       		 v_shipto_city, v_shipto_region, v_shipto_country, v_shipto_zip, v_incoterm
       	FROM shp_salesorder WHERE salesorder_id = v_salesorder;

	v_shipdate := TO_CHAR(NOW(), 'MM/DD/YYYY');
	SELECT SUM(b.ship_qty*a.unit_price) INTO v_total_price FROM shp_salesorderdetail a INNER JOIN shp_deliverynumberdetail b ON a.salesorder_id = b.salesorder_id WHERE b.deliverynumber_id = v_orderno;

	SELECT COUNT(0) INTO v_palletqty FROM shp_palletdeliverynumber WHERE deliverynumber_id = v_orderno;

	SELECT SUM(gross_weight) INTO v_gross_weight
	FROM shp_pallet WHERE pallet_id IN ( SELECT pallet_id FROM shp_palletdeliverynumber WHERE deliverynumber_id = v_orderno);

	v_billto_address := v_billto_address || ' ' || v_billto_city;
	v_billto_region  := v_billto_region || ', ' || v_billto_country || ' ' || v_billto_zip;

	v_shipto_street := v_shipto_street || ', ' || v_shipto_city;
	v_shipto_region := v_shipto_region || ', ' || v_shipto_country || ' ' || v_shipto_zip;

        DROP TABLE IF EXISTS table_comminvoice_header;
        CREATE TEMP TABLE table_comminvoice_header 
        (
            t_rowid              INT GENERATED BY DEFAULT AS IDENTITY,
            t_field	         VARCHAR(255) DEFAULT NULL,
            t_fieldname          VARCHAR(255) DEFAULT NULL,
            t_fieldvalue         VARCHAR(255) DEFAULT NULL
        ) 
       	ON COMMIT DROP;

        -------------------------------------------------
        -- SHIPPER SECTION
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A7' , 'Shipper Name'	    , BTRIM(v_shipper_name));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A8' , 'Shipper Address 1', BTRIM(v_shipper_add1));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A9' , 'Shipper Address 2', BTRIM(v_shipper_add2));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A10', 'Shipper City'     , BTRIM(v_shipper_city));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A11', 'Shipper Country'  , BTRIM(v_shipper_country));
       	       
       -- SELLER SECTION
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D7' , 'Seller Name'	    , BTRIM(v_seller_name));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D8' , 'Seller Address 1' , BTRIM(v_seller_add1));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D9' , 'Seller Address 2' , BTRIM(v_seller_add2));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D10', 'Seller Country'   , BTRIM(v_seller_country));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('E10', 'Seller Zipcode'   , BTRIM(v_seller_zipcode));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D11', 'Seller TaxID'     , BTRIM(v_seller_taxID));
       	
       -- SHIP TO SECTION
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A13', 'ShipTo1', BTRIM(v_shipto_name));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A14', 'ShipTo2', BTRIM(v_shipto_street));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('A15', 'ShipTo3', BTRIM(v_shipto_region));
       	
       -- SOLD TO SECTION
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D13', 'SoldTo1', BTRIM(v_billto_name));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D14', 'SoldTo2', BTRIM(v_billto_address));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D15', 'SoldTo3', BTRIM(v_billto_region));
       
       -- SHIPMENT INFO
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('J6', 'Date'	   , BTRIM(v_shipdate));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('J7', 'InvoiceNo', BTRIM(v_orderno));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('J8', 'Incoterm' , BTRIM(v_incoterm));
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('J9', 'Carrier'  , BTRIM(v_carrier));
        INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('J10','AWS'	   , BTRIM(v_trackingno));

       	-- FOOTER SECTION
        INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D32', 'GrossWeight' , BTRIM(CAST(v_gross_weight AS VARCHAR)) || ' Kgs');
        INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('D33', 'TotalPallets', BTRIM(CAST(v_palletqty AS VARCHAR)));
       	
       -- TOTAL PRICE SECTION
       	INSERT INTO table_comminvoice_header (t_field, t_fieldname, t_fieldvalue) VALUES ('J36', 'TotalPrice', '$' || BTRIM(CAST(v_total_price AS VARCHAR)));

    	RETURN QUERY SELECT * FROM table_comminvoice_header; 

    END IF;

END; 
$function$
;
