CREATE OR REPLACE PROCEDURE public.get_service_config_by_service_id(trans_type text DEFAULT ''::text, v_service_id text DEFAULT ''::text, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
   	gen_value				text;
begin
	CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
	
	if v_service_id = '' then
		RAISE EXCEPTION 'Value cannot be blank.' USING HINT = 'Custom Error';
	end if;	
	
	if trans_type = 'GET' THEN	
		select service_config into sp_result from sadmin_sysserviceconnection where service_id = v_service_id;
	end if;
	
	EXCEPTION
	    WHEN OTHERS THEN
	        sp_result := SQLERRM;	       		
END;
$procedure$
;

