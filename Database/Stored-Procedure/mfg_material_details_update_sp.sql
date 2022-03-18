CREATE OR REPLACE PROCEDURE public.mfg_material_details_update_sp(transtype text DEFAULT ''::text, v_model_id text DEFAULT ''::text, v_keypart text DEFAULT ''::text, v_mask_rule text DEFAULT ''::text, v_category_id text DEFAULT ''::text, v_user text DEFAULT ''::text, v_spanish_desc text DEFAULT ''::text, v_fracc_nico text DEFAULT ''::text, v_uom_value text DEFAULT ''::text, v_hst_code text DEFAULT ''::text, v_fracc_digits text DEFAULT ''::text, v_technical_desc text DEFAULT ''::text, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
	t_error_message		text;
	t_keypart 		int;
	t_scan_category_id  	text;
	t_mask_rule 		text;
	v_scan_type 		text;
	BEGIN
		CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
	
		IF transtype = '' THEN
			RAISE EXCEPTION 'Transaction Type cannot be null/empty' USING HINT = 'Custom Error';
		END IF;

		IF v_model_id = '' THEN
			RAISE EXCEPTION 'Missing model id' USING HINT = 'Custom Error';
		END IF;
		
		IF transtype = 'CHECK' OR v_keypart = '' AND v_mask_rule = '' AND v_category_id = '' AND v_spanish_desc = '' AND v_fracc_nico = '' AND v_uom_value = '' AND v_hst_code = '' AND v_fracc_digits = '' AND v_technical_desc = '' THEN
			RAISE EXCEPTION 'Input Fields Are Empty. No Values To Update.' USING HINT = 'Custom Error';
		END IF;
	
		IF LENGTH(v_category_id) <> 0 THEN
			IF NOT EXISTS(SELECT 1 FROM mfg_scancategory ms WHERE category_id = v_category_id) then
				RAISE EXCEPTION '% is not a valid Category ID.', v_category_id USING HINT = 'Custom Error';
		    END IF;
		END IF;

		SELECT mm.keypart , UPPER(mm.mask_rule) mask_rule
		INTO   t_keypart , t_mask_rule
		FROM mfg_materialmaster mm JOIN mfg_scancategory ms ON mm.category_id = ms.category_id WHERE model_id = v_model_id;		
	
		IF transtype = 'UPDATE-MAIN' THEN
--			UPDATE mfg_materialmaster SET keypart = COALESCE(v_keypart, keypart), mask_rule = COALESCE(v_mask_rule, mask_rule), category_id = COALESCE(v_category_id, category_id), last_update = now(), last_update_by = v_user;
		
--			CALL mfg_mask_rule_validation_sp ('MODEL_DOWNLOAD', v_model_id, t_error_message);
--			IF t_error_message <> '' THEN
--				RAISE EXCEPTION '%', t_error_message USING HINT = 'Custom Error';
--			END IF;		
			
			IF v_keypart = '' AND v_mask_rule = '' AND v_category_id = '' THEN
				RAISE EXCEPTION 'Input Fields For Main Info Are Empty. No Values To Update.' USING HINT = 'Custom Error';
			END IF;

			IF NOT EXISTS (SELECT 0 FROM mfg_materialmaster mm WHERE model_id= v_model_id) THEN 
				INSERT INTO mfg_materialmaster (model_id, keypart, category_id , last_update, last_update_by)
				VALUES (v_model_id, CAST (v_keypart AS INTEGER), v_category_id, now(), v_user);
			ELSE
				-- Users update keypart
				IF LENGTH(v_keypart) <> 0 THEN
					IF v_keypart ~ '^[0-9]+$' THEN
						-- Users set partno with keypart = 1
						IF v_keypart <> '0' THEN
							-- Not assign mask rule, not assign category
			 				IF (LENGTH(v_mask_rule) = 0) AND (LENGTH(v_category_id) = 0) THEN
				 				RAISE EXCEPTION 'Mask Rule And Scan Category ID Must Be Assigned To Turn Keypart On' USING HINT = 'Custom Error';
							END IF;
							-- Not assign mask rule, assign category ID					
			 				IF (LENGTH(v_mask_rule) = 0) AND (LENGTH(v_category_id) <> 0) THEN

			 					SELECT UPPER(ms.category_id) category_id , UPPER(ms.scan_type) scan_type INTO t_scan_category_id , v_scan_type FROM mfg_scancategory ms WHERE ms.category_id = v_category_id;
								-- Category ID assigned has scan type = 'PN'
			 					IF (v_scan_type = 'PN') THEN
									UPDATE mfg_materialmaster SET keypart = CAST (v_keypart AS INTEGER), category_id = v_category_id, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
								-- Category ID assigned has other scan type
								ELSE
									RAISE EXCEPTION 'Category ''%'' Has Scan Type ''%''. Scan Type Must Be ''PN''', v_category_id, v_scan_type USING HINT = 'Custom Error';
								END IF;
							END IF;
							-- Assign mask rule, not assign category ID											
							IF (LENGTH(v_mask_rule) <> 0) AND (LENGTH(v_category_id) = 0) THEN
								RAISE EXCEPTION 'Mask Rule And Scan Category ID Must Be Assigned To Turn Keypart On' USING HINT = 'Custom Error';
							END IF;
							-- Assign mask rule, assign category ID																	
							IF (LENGTH(v_mask_rule) <> 0) AND (LENGTH(v_category_id) <> 0) THEN

			 					SELECT UPPER(ms.category_id) category_id , UPPER(ms.scan_type) scan_type INTO t_scan_category_id , v_scan_type FROM mfg_scancategory ms WHERE ms.category_id = v_category_id;
								-- Category ID assigned has scan type = 'CSN' or 'PNCSN'
								IF (v_scan_type = 'CSN' OR v_scan_type = 'PNCSN') THEN
									UPDATE mfg_materialmaster SET keypart = CAST (v_keypart AS INTEGER), mask_rule = v_mask_rule, category_id = v_category_id, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
								-- Category ID assigned has other scan type
								ELSE
									RAISE EXCEPTION 'Category ''%'' Has Scan Type ''%''. Scan Type Must Be ''CSN'' Or ''PNCSN''', v_category_id, v_scan_type USING HINT = 'Custom Error';
								END IF;
							END IF;						
						
						END IF;
						-- Users set partno with keypart = 0
						IF v_keypart <> '1' THEN
							-- Not assign mask rule, not assign category
							IF (LENGTH(v_mask_rule) = 0) AND (LENGTH(v_category_id) = 0) THEN
				 				UPDATE mfg_materialmaster SET keypart = CAST (v_keypart AS INTEGER), last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
							END IF;
							-- Not assign mask rule, assign category ID											
							IF (LENGTH(v_mask_rule) = 0) AND (LENGTH(v_category_id) <> 0) THEN

			 					SELECT UPPER(ms.category_id) category_id , UPPER(ms.scan_type) scan_type INTO t_scan_category_id , v_scan_type FROM mfg_scancategory ms WHERE ms.category_id = v_category_id;
								-- Category ID assigned has scan type = 'CSN' or 'PNCSN'						
								IF (v_scan_type = 'CSN' OR v_scan_type = 'PNCSN') THEN
									RAISE EXCEPTION 'Keypart Flag Must Be Turned On To Assign Mask and Category ID' USING HINT = 'Custom Error';
								-- Category ID assigned has other scan type								
								ELSE
									RAISE EXCEPTION 'Keypart Flag Must Be Turned On To Assign Mask and Category ID' USING HINT = 'Custom Error';
								END IF;
							END IF;
							-- Assign mask rule, not assign category ID																	
							IF (LENGTH(v_mask_rule) <> 0) AND (LENGTH(v_category_id) = 0) THEN
								RAISE EXCEPTION 'Keypart Flag Must Be Turned On To Assign Mask and Category ID' USING HINT = 'Custom Error';
							END IF;
							-- Assign mask rule, assign category ID																							
							IF (LENGTH(v_mask_rule) <> 0) AND (LENGTH(v_category_id) <> 0) THEN
								RAISE EXCEPTION 'Keypart Flag Must Be Turned On To Assign Mask and Category ID' USING HINT = 'Custom Error';						
							END IF;
						END IF;
					ELSE
			         	RAISE EXCEPTION '% is not a number. Keypart must be a number.', v_keypart USING HINT = 'Custom Error';
					END IF;
				-- Users not update keypart				
				ELSE
					IF CAST(t_keypart AS VARCHAR(2)) ~ '^[0-9]+$' THEN
						IF t_keypart <> '0' THEN
			 				IF (LENGTH(v_mask_rule) = 0) AND (LENGTH(v_category_id) <> 0) THEN
								RAISE EXCEPTION 'Select On For Keypart Before Updating Category ID' USING HINT = 'Custom Error';
							END IF;						
							RAISE EXCEPTION 'Select On For Keypart Before Updating Mask Rule and Category ID' USING HINT = 'Custom Error';
						END IF;
						
						IF t_keypart <> '1' THEN
							RAISE EXCEPTION 'Turn On Keypart Flag Before Updating Mask Rule and Category ID' USING HINT = 'Custom Error';		
						END IF;
					-- Edge case: Category ID and Mask Rule are empty and keypart is not empty
					ELSE
						IF (LENGTH(v_mask_rule) = 0) AND (LENGTH(v_category_id) <> 0) THEN
							RAISE EXCEPTION 'Select Keypart Before Updating Category ID' USING HINT = 'Custom Error';
						ELSE
							RAISE EXCEPTION 'Select Keypart Before Updating Mask Rule and Category ID' USING HINT = 'Custom Error';
						END IF;
					END IF;				
				END IF;
			END IF;
		END IF;
 		
		IF transtype = 'UPDATE-DATA-RELATED' THEN
--			UPDATE mfg_materialdatarelated SET hst_usa = COALESCE(v_hst_code, hst_usa), fracc_digits = COALESCE(v_fracc_digits, fracc_digits), last_update = now(), last_update_by = v_user;
		
--			CALL mfg_mask_rule_validation_sp ('MODEL_DOWNLOAD', v_model_id, t_error_message);
--			IF t_error_message <> '' THEN
--				RAISE EXCEPTION '%', t_error_message USING HINT = 'Custom Error';
--			END IF;	
		
			IF v_spanish_desc = '' AND v_fracc_nico = '' AND v_uom_value = '' AND v_hst_code = '' AND v_fracc_digits = '' AND v_technical_desc = '' THEN
				RAISE EXCEPTION 'Input Fields For Data Related Are Empty. No Values To Update.' USING HINT = 'Custom Error';
			END IF;	
	
			IF NOT EXISTS (SELECT 0 FROM mfg_materialmaster mm WHERE model_id= v_model_id) THEN 
				INSERT INTO mfg_materialmaster (model_id, last_update, last_update_by)
				VALUES (v_model_id, now(), v_user);
			ELSE
				IF LENGTH(v_hst_code) <> 0 THEN UPDATE mfg_materialdatarelated SET hst_usa = v_hst_code, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
				END IF;
				IF LENGTH(v_fracc_digits) <> 0 THEN UPDATE mfg_materialdatarelated SET fracc_digits = v_fracc_digits, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
				END IF;	
				IF LENGTH(v_spanish_desc) <> 0 THEN UPDATE mfg_materialdatarelated SET spanish_description = v_spanish_desc, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
				END IF;
				IF LENGTH(v_fracc_nico) <> 0 THEN UPDATE mfg_materialdatarelated SET fracc_nico = v_fracc_nico, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
				END IF;	
				IF LENGTH(v_uom_value) <> 0 THEN UPDATE mfg_materialdatarelated SET uom_value = v_uom_value, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
				END IF;
				IF LENGTH(v_technical_desc) <> 0 THEN UPDATE mfg_materialdatarelated SET technical_description = v_technical_desc, last_update = now(), last_update_by = v_user WHERE model_id = v_model_id;
				END IF;				
			END IF;
		END IF;
	
        EXCEPTION
            WHEN OTHERS THEN
                sp_result := SQLERRM;
               
        COMMIT;
		
	END;
$procedure$
;
