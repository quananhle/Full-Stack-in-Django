CREATE OR REPLACE FUNCTION public.mfg_model_manager_update_fn(v_model_id text)
 RETURNS TABLE(t_model_id character varying, t_keypart character varying, t_mask_rule character varying, t_category_id character varying, t_plant_code character varying, t_sap_changed_date character varying, t_spanish_desc character varying, t_fracc_nico character varying, t_uom_value character varying, t_hst_code character varying, t_fracc_digits character varying, t_technical_desc character varying)
 LANGUAGE plpgsql
AS $function$
	BEGIN
		
		RETURN QUERY
			SELECT a.model_id , CAST(a.keypart AS VARCHAR(50)), a.mask_rule, a.category_id , a.plant_code , CAST(c.sap_change AS VARCHAR(50)), 
				   b.spanish_description , b.fracc_nico , b.uom_value , b.hst_usa, b.fracc_digits , b.technical_description 
			FROM mfg_materialmaster a 
			INNER JOIN mfg_materialdatarelated b ON a.model_id = b.model_id
			INNER JOIN (SELECT model_id, TO_CHAR(sap_change_date, 'YYYY-MM-DD') || ' ' || TO_CHAR(sap_change_time, 'HH:MM:SS') sap_change FROM mfg_materialmaster) c ON a.model_id = c.model_id
			WHERE a.model_id = v_model_id;
	END;
$function$
;
