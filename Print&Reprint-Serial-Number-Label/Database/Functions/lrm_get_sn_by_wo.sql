CREATE OR REPLACE FUNCTION public.lrm_get_sn_by_wo(v_workorder_id text)
 RETURNS TABLE(t_serial_number character varying, t_model_id character varying)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		RETURN QUERY
			SELECT a.serial_number , a.model_id FROM mfg_serialnumber a WHERE a.workorder_id = v_workorder_id ORDER BY serial_number ;
	END;
$function$
;
