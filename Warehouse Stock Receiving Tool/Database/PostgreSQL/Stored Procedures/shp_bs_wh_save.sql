CREATE OR REPLACE PROCEDURE public.shp_bs_wh_save(transtype text DEFAULT ''::text, v_fields_dict jsonb DEFAULT '{}'::jsonb, username text DEFAULT ''::text, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE 
	_key			text = '';
   	_value 			text = '';
	v_sn			text = '';
	v_pn			text = '';
	v_aws_pn		text = '';
	v_building		text = '';
	v_sloc			text = '';
	v_action		text = '';
	v_mfg_pn		text = '';
BEGIN 
	IF transtype = '' THEN
		RAISE EXCEPTION 'Transaction Type cannot be null/empty' USING HINT = 'Custom Error';
	END IF;

	FOR _key, _value IN
		SELECT * FROM JSONB_EACH_TEXT(v_fields_dict)
	LOOP
		-- Added by Quan: Validate content to detect non-digit and non-alphabet character. Accept dash but not two or more consecutive dashes - BEGIN (12/27/2023)
		IF get_controlvalues('CHECK_BS_MTS_VALUE') = 'N'
		/*
		 * UPDATE public.sadmin_syscontrolvalues SET control_value = 'Y' , last_update_by = USER , last_update = CURRENT_TIMESTAMP 
		 * WHERE row_id = 143 AND control_name = 'CHECK_BS_MTS_VALUE';
		 */
		THEN
			IF UPPER(_key) IN ('COMPONENT_SN' , 'FXN_MODEL_ID' , 'AWS_MODEL_ID' , 'BUILDING' , 'SLOC' , 'MFG_MODEL_ID') THEN
				IF _value ~ '[^\w\d-]|-{2,}' THEN		-- _value ~ '[!"#$%&'()*+,./ ]'
	        		RAISE EXCEPTION 'Illegal characters detected in column % for value %', _key, _value;
	    		END IF;
			END IF;
		END IF;
		-- Added by Quan: Validate content to detect non-digit and non-alphabet character. Accept dash but not two or more consecutive dashes - END (12/27/2023)
		
		IF UPPER(_key) = UPPER('Component_SN') THEN 
			v_sn := _value;
   		END IF;

   		IF UPPER(_key) = UPPER('Fxn_Model_ID') THEN 
			v_pn := _value;
		
			IF SUBSTRING(UPPER(v_pn), 1, 2) = 'AM' THEN
					v_pn := SUBSTRING(v_pn, 3);
			END IF;
   		END IF;

		IF UPPER(_key) = UPPER('AWS_Model_ID') THEN 	
			v_aws_pn := _value;
		END IF;

		IF UPPER(_key) = UPPER('Building') THEN 
			v_building := _value;
   		END IF;

		IF UPPER(_key) = UPPER('Sloc') THEN 
			v_sloc := _value;
		END IF;

		IF UPPER(_key) = UPPER('mfg_model_id') THEN 
			v_mfg_pn := _value;
		END IF;
	END LOOP;




   
	if transtype = 'SAVE'  then
		
		-->    select * from sadmin_syslog order by row_id desc;
		--  select * from shp_sb_wh
	
		if not exists(select 0 from  shp_sb_wh where component_sn = v_sn)
		then 
		
			insert INTO shp_sb_wh (component_sn, fxn_model_id, aws_model_id,building,sloc,mfg_model_id, created_by)
			values (v_sn, v_pn, v_aws_pn, v_building, v_sloc, v_mfg_pn,username);
		
			v_action:= 'INSERT';
		else
		
		 	if not exists (select 0 from  shp_sb_wh where component_sn = v_sn and fxn_model_id = v_pn )
		 	then
		 	
				update shp_sb_wh
				set fxn_model_id = v_pn,
				--aws_model_id = v_aws_pn,
				--building = v_building ,
				--sloc = v_sloc, 
				last_update = now(),
				--mfg_model_id= v_mfg_pn,
				last_update_by = username
				where component_sn = v_sn;
			
			end if;
			
			v_action:= 'UPDATE';
		end if;
	
		call sadmin_log(transtype, 'BS WH', 'shp_Bs_Wh_save', v_sn, 'Row has been ' || v_action, username,v_fields_dict::json);
	
	end if;

    EXCEPTION
        WHEN OTHERS THEN 
            sp_result := SQLERRM;
           	sp_result := replace(sp_result, '"', '');
           	call sadmin_log('EXCEPTION', transtype, 'shp_Bs_Wh_save', v_sn, sp_result,  username,v_fields_dict::json);      	
           
   commit;
END;
$procedure$
;

