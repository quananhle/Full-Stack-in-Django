CREATE OR REPLACE PROCEDURE public.lrm_wo_status_validation_sp(transtype text DEFAULT ''::text, v_value text DEFAULT ''::text, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE 
	t_workorder_id			text;
	BEGIN
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
       
		IF transtype = '' THEN
			RAISE EXCEPTION 'Transaction Type cannot be null/empty' USING HINT = 'Custom Error';
		END IF;	

		IF transtype = 'PRINT-SN' THEN

			t_workorder_id := v_value;

			IF t_workorder_id = '' THEN
				RAISE EXCEPTION 'Workorder ID cannot be blank.' USING HINT = 'Custom Error';
			END IF; 
		
			IF NOT EXISTS(SELECT 1 FROM mfg_workorder sm WHERE workorder_id = t_workorder_id) THEN
		         RAISE EXCEPTION 'Workorder ID % Not Existed.', t_workorder_id USING HINT = 'Custom Error';
		    END IF;
		   
		    IF NOT EXISTS(SELECT 1 FROM mfg_serialnumber ms WHERE ms.workorder_id = t_workorder_id) THEN
		         RAISE EXCEPTION 'No Serial Number Found Under Workorder ID %', t_workorder_id USING HINT = 'Custom Error';
		    END IF;
		   	       
		    IF NOT EXISTS(SELECT 1 FROM mfg_workorder mw JOIN mfg_wostatuscategory mw1 ON mw.status_id = mw1.status_id WHERE mw.workorder_id = t_workorder_id AND (mw1."name" = 'Started' OR mw.status_id in (30,40,50,60))) THEN
		         RAISE EXCEPTION 'The Workorder % Not At Started Status.', t_workorder_id USING HINT = 'Custom Error';
		    END IF;
		   
		    IF NOT EXISTS(SELECT 1 FROM mfg_workorder mw WHERE mw.workorder_id = t_workorder_id AND (mw.skuno <> '' OR mw.skuno <> null)) THEN
		         RAISE EXCEPTION 'The Workorder ID % Does Not Have SKU Number.', t_workorder_id USING HINT = 'Custom Error';
		    END IF;
		   
		    IF NOT EXISTS(SELECT 1 FROM mfg_workorder mw WHERE mw.workorder_id = t_workorder_id AND mw.production_version IN ('PMCK', 'PMWO', '1GWO')) THEN
		         RAISE EXCEPTION 'The Workorder ID % Is Not Either Production Or Country Kit', t_workorder_id USING HINT = 'Custom Error';
		    END IF;
		   		   
		END IF;	

	    EXCEPTION
            WHEN OTHERS THEN
                sp_result := SQLERRM;
               
	END;
$procedure$
;
