CREATE OR REPLACE FUNCTION public.pmdu_mfg_get_validated_sn_list(v_workorder_id text)
 RETURNS TABLE(t_validated_sn_list character varying)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		SELECT serial_number FROM mfg_serialnumber WHERE workorder_id = v_workorder_id and serial_number not in (SELECT UNNEST(STRING_TO_ARRAY(validated_sn, ',')) AS scanned_sn FROM mfg_auditsortedtracking WHERE value = v_workorder_id);
	END;
$function$
;
