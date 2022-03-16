CREATE OR REPLACE FUNCTION public.pmdu_mfg_sort_sn_audit(v_serial_number text, v_station_id text)
 RETURNS TABLE(t_workorder_id character varying, t_model_id character varying, t_rate character varying, t_total character varying, t_counter character varying)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		RETURN QUERY
			SELECT a.workorder_id , a.model_id, CAST(b.rate AS VARCHAR(50)), CAST(c.total AS VARCHAR(50)), CAST(c.counter AS VARCHAR(50)) 
			FROM mfg_serialnumber a 
			INNER JOIN mfg_auditsortedconfig b ON a.model_id = b.sorted_value
			INNER JOIN mfg_auditsortedtracking c ON a.workorder_id = c.value
			WHERE serial_number = v_serial_number AND a.station_id = v_station_id;
	END;
$function$
;
