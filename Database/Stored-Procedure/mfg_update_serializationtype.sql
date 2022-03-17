CREATE OR REPLACE PROCEDURE public.mfg_update_serializationtype(v_model_id text DEFAULT ''::text, mfg_pn text DEFAULT ''::text, aws_pn text DEFAULT ''::text, v_desc text DEFAULT ''::text, t_desc text DEFAULT ''::text, v_fracc_nico text DEFAULT ''::text, v_uom_value text DEFAULT ''::text, v_uom text DEFAULT ''::text, v_hst_usa text DEFAULT ''::text, v_build_type text DEFAULT ''::text, v_user text DEFAULT ''::text, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE 
BEGIN
	CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
	IF v_build_type = '1' OR v_build_type = '0' THEN
		UPDATE mfg_materialmaster
		SET build_type = v_build_type,
		manufacturer_pn = mfg_pn,
		manufacturer = aws_pn,
		last_update = now(),
		last_update_by = v_user
		WHERE model_id = v_model_id;
	
		IF NOT EXISTS (SELECT 0 FROM mfg_materialdatarelated mm WHERE model_id= v_model_id) THEN 
			INSERT INTO mfg_materialdatarelated (model_id ,spanish_description, technical_description ,fracc_nico,uom_value,uom,hst_usa,last_update,last_update_by)
			VALUES (v_model_id,v_desc,t_desc,v_fracc_nico,v_uom_value,v_uom,v_hst_usa,now(),v_user);
		ELSE
			UPDATE mfg_materialdatarelated 
			SET spanish_description = v_desc,
			technical_description = t_desc,
			fracc_nico  = v_fracc_nico,
			uom_value  = v_uom_value,
			uom =  v_uom,
			hst_usa =v_hst_usa,
			last_update = now(),
			last_update_by = v_user
			WHERE model_id = v_model_id;
		END IF;
	
		sp_result := '';
	ELSE 
		sp_result := 'Serialization Type Can Only Be 0 (Non-Serialized) or 1 (Serialized).';
	END IF;	 
	
	EXCEPTION
	    WHEN OTHERS THEN
	        sp_result := SQLERRM;
				
END;
$procedure$
;
