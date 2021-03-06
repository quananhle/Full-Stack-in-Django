CREATE OR REPLACE FUNCTION public.print_get_data_pack_pallet_fn(transtype text DEFAULT ''::text, v_value text DEFAULT ''::text)
 RETURNS TABLE(t_section text, t_variable text, t_value text)
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_pack_id           	text;
	v_pallet_id         	text;
	v_skuno             	text;
	v_template_name     	text;
	v_printer_name      	text;
	v_mat_description   	text;
	v_pack_table        	text;
	v_pallet_table      	text;
    	v_serial_number     	text;
	v_coo 		    	text;
	v_qty 		    	text;
	v_snlist	    	text;
	r_sn		    	record;
   	v_counter	    	int;
   	v_idx		    	int;
	v_sn                	varchar(255);
   	v_foxpn		    	text;
	v_custpn	    	text;
	v_foxrev	    	text;
	v_custrev	    	text;
	v_wo		    	text;
	v_csn		    	text;
	v_prod_type	    	text;
	v_pack_date         	text;
	v_mac_id	    	text;
	v_mac_list	    	text[];
	v_mac_wo_table	    	text;
	item		    	text;
	v_salesorder_id	    	text;


	v_cn_qty	    	text;
	v_sales_order_id    	text;
	v_customer_po	    	text;
	v_revision	    	text;
	v_gross_weight	    	text;
	v_customerpn	    	text;
	v_model_desc	    	text;
	v_vendor	    	text;
	v_vendor_name	    	text;
	v_ship_from	    	text;
	v_ship_to	    	text;
	v_delivery_number   	text;
	v_model_id	    	text;
	v_customer_pn	    	text;	
	v_ship_date 	    	text;
	v_customer_shipto	text;
	v_ship_to_street	text;
	v_ship_to_city		text;
	v_ship_to_region	text;
	v_ship_to_zipcode	text;
	
BEGIN
    IF transtype = 'PRD-SN-LABEL'  THEN
      v_pack_table := 'tmp_pack' || v_value;

      SELECT b.customer_pn INTO v_skuno FROM mfg_serialnumber a JOIN mfg_materialmaster b ON a.model_id = b.model_id WHERE a.serial_number = v_value;

      DROP TABLE IF EXISTS v_pack_table;
      CREATE TEMP TABLE v_pack_table 
      (
          _rowid              INT GENERATED BY DEFAULT AS IDENTITY,
          _section       		text,
          _variable			text,
          _value				text
      ) ON COMMIT DROP;	

      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'serial_number', v_value);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'production_sku', v_skuno);

      RETURN QUERY
      SELECT _section, _variable, _value FROM v_pack_table ORDER BY _rowid;
       
    END IF;
   
    IF transtype = 'CK-SN-LABEL'  THEN
      v_pack_table := 'tmp_pack' || v_value;

      SELECT b.customer_pn INTO v_skuno FROM mfg_serialnumber a JOIN mfg_materialmaster b ON a.model_id = b.model_id WHERE a.serial_number = v_value;

      DROP TABLE IF EXISTS v_pack_table;
      CREATE TEMP TABLE v_pack_table 
      (
          _rowid              INT GENERATED BY DEFAULT AS IDENTITY,
          _section       		text,
          _variable			text,
          _value				text
      ) ON COMMIT DROP;	

      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'serial_number', v_value);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'production_sku', v_skuno);

      RETURN QUERY
      SELECT _section, _variable, _value FROM v_pack_table ORDER BY _rowid;

      END IF;

     IF transtype = '1G-PRD-SN-LABEL' then
      v_pack_table := 'tmp_pack' || v_value;

      DROP TABLE IF EXISTS v_pack_table;
      CREATE TEMP TABLE v_pack_table
      (
      _rowid INT GENERATED BY DEFAULT AS IDENTITY,
      _section text,
      _variable text,
      _value text
      ) ON COMMIT DROP;

      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'serial_number', v_value);

      RETURN QUERY
      SELECT _section, _variable, _value FROM v_pack_table ORDER BY _rowid;
	
   END IF;
   
   	IF transtype = '1G-PRESHIP-LABEL'  THEN
      v_pack_table := 'tmp_pallet_id' || v_value;
      SELECT serial_number AS "SN" , model_id AS "Model ID" INTO v_serial_number , v_model_id FROM mfg_serialnumber WHERE serial_number = v_value;
      SELECT customer_pn AS "Part No" , model_desc AS "Part# Desc" , revision AS "Revision" INTO v_customer_pn , v_model_desc , v_revision FROM mfg_materialmaster WHERE model_id = v_model_id;
      SELECT pack_id_id  		  	  	  AS "Carton ID"    INTO v_pack_id   	   FROM mfg_packserialnumber 	 WHERE serialnumber_id = v_serial_number;
      SELECT pallet_id  		  	  	  AS "Pallet ID"    INTO v_pallet_id  	   FROM shp_palletpack  		 WHERE pack_id  	   = v_pack_id;
      SELECT deliverynumber_id 	  	  AS "DN"		    INTO v_delivery_number FROM shp_palletdeliverynumber WHERE pallet_id 	   = v_pallet_id;
      SELECT CAST(gross_weight AS TEXT) AS "Gross Weight" INTO v_gross_weight	   FROM shp_pallet  		   	 WHERE pallet_id 	   = v_pallet_id;	
      SELECT salesorder_id, customer_po AS "PO #", TO_CHAR(ship_date, 'DDMONYYYY') AS "Ship Date" INTO v_sales_order_id, v_customer_po , v_ship_date FROM shp_deliverynumber sd WHERE deliverynumber_id = v_delivery_number;
      SELECT '1' 					  	  AS "Qty" 		    INTO v_cn_qty;
      SELECT 'MX' 				  	  AS "COO" 		    INTO v_coo;
      SELECT '042' 				  	  AS "Vendor"       INTO v_vendor;
      SELECT 'Ingrasys Guadalajara' 	  AS "Vendor Name"  INTO v_vendor_name;
      SELECT 'PCE Paragon Solutions (Mexico), S.A. de C.V., Avenida del Bosque no. 1170, Las Pintas C.P. 45619, San Pedro Tlaquepaque, Jalisco, Mexico' 						 AS "Ship From"	INTO v_ship_from;
      SELECT ship_to_name || ', ' || customer_shipto || ', ' || ship_to_street || ', ' || ship_to_city || ', ' || ship_to_region || ship_to_zipcode || ', ' || ship_to_country AS "Ship To" 	INTO v_ship_to 	
      FROM shp_salesorder ss WHERE salesorder_id = v_sales_order_id;

      DROP TABLE IF EXISTS v_pack_table;
      CREATE TEMP TABLE v_pack_table 
      (
          _rowid              INT GENERATED BY DEFAULT AS IDENTITY,
          _section       		text,
          _variable			text,
          _value				text
      ) ON COMMIT DROP;

      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'cn_qty'  		  , v_cn_qty);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'coo'  	  	  , v_coo);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'customer_po'	  , v_customer_po);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'customerpn'  	  , v_customer_pn);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'delivery_number', v_delivery_number);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'gross_weight'   , v_gross_weight);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'model_desc'	  , v_model_desc);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'pack_id'		  , v_pack_id);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'revision'  	  , v_revision);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'serial_number'  , v_serial_number);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'ship_date'	  , v_ship_date);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'ship_from'	  , v_ship_from);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'ship_to'		  , v_ship_to);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'vendor'		  , v_vendor);
      INSERT INTO v_pack_table (_section, _variable, _value) VALUES ('HEADER', 'vendor_name'	  , v_vendor_name);

      RETURN QUERY
      SELECT _section, _variable, _value FROM v_pack_table ORDER BY _rowid;
       
    END IF;
    
END;
$function$
;
