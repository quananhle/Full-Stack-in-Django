CREATE OR REPLACE FUNCTION public.lrm_get_wo_info(v_workorder_id text)
 RETURNS TABLE(t_workorder_id character varying, t_status_id character varying, t_target_qty character varying, t_skuno character varying, t_workorder_type character varying, t_sn_from character varying, t_sn_to character varying)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		RETURN QUERY
		SELECT a.workorder_id , mw."name" AS status , CAST(a.target_qty AS VARCHAR(50)), 
			CASE WHEN d.customer_pn IS NULL THEN 'N/A'::VARCHAR ELSE d.customer_pn END, 
             		a.production_version , a.serial_number AS sn_from , b.serial_number AS sn_to
		FROM (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
		      FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id 
            	      WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number LIMIT 1) a
		FULL OUTER JOIN (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
				 FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id 
                       		 WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number DESC LIMIT 1) b
		ON a.workorder_id = b.workorder_id
		JOIN mfg_wostatuscategory mw ON a.status_id = mw.status_id 
		LEFT JOIN mfg_materialmaster d ON a.skuno = d.model_id 
      		LIMIT 1;
	END;
$function$
;
