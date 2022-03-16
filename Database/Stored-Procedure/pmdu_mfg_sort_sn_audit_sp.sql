CREATE OR REPLACE PROCEDURE public.pmdu_mfg_sort_sn_audit_sp(transtype text DEFAULT ''::text, v_workorder_id text DEFAULT ''::text, v_serial_number text DEFAULT ''::text, v_user text DEFAULT ''::text, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$
	BEGIN
		CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

		IF transtype = '' THEN 
			RAISE EXCEPTION 'Transaction Type Cannot Be Empty.' USING HINT = 'Custom Error';
		END IF;	
		IF v_workorder_id = '' THEN 
			RAISE EXCEPTION 'Workd Order ID Cannot Be Empty.' USING HINT = 'Custom Error';
		END IF;			
		IF v_serial_number = '' THEN 
			RAISE EXCEPTION 'Serial Number Value Cannot Be Empty.' USING HINT = 'Custom Error';
		END IF;		


		IF NOT EXISTS(SELECT 1 FROM mfg_workorder ms WHERE workorder_id = v_workorder_id) THEN
	        RAISE EXCEPTION 'WORKORDER ID % NOT FOUND.', v_workorder_id USING HINT = 'Custom Error';
	    END IF;
		IF NOT EXISTS(SELECT 1 FROM mfg_serialnumber ms WHERE serial_number = v_serial_number) THEN
	        RAISE EXCEPTION 'SERIAL NUMBER % NOT FOUND.', v_serial_number USING HINT = 'Custom Error';
	    END IF;


	    IF transtype = 'UPDATE-COUNTER' THEN
			UPDATE mfg_auditsortedtracking SET counter = counter - 1, validated_sn = CASE 
													WHEN (validated_sn IS NULL OR validated_sn = '') THEN v_serial_number
													ELSE CONCAT(validated_sn, ',', v_serial_number) 
												 END 
										, last_edit_date = now(), last_edit_by = v_user WHERE value = v_workorder_id;
	    END IF;	    

	    IF transtype = 'UPDATE-VALIDATED-SN-LIST-ONLY' THEN
	    	UPDATE mfg_auditsortedtracking SET validated_sn = CASE 
									WHEN (validated_sn IS NULL OR validated_sn = '') THEN v_serial_number
									ELSE CONCAT(validated_sn, ',', v_serial_number) 
								  END
						 , last_edit_date = now(), last_edit_by = v_user WHERE value = v_workorder_id;
	    END IF;
	END;
$procedure$
;
