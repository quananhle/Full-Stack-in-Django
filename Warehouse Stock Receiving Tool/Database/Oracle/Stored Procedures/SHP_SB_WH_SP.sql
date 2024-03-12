CREATE OR REPLACE PROCEDURE DFMS_MAZ.SHP_SB_WH_SP(
    v_component_number			IN VARCHAR2 := '',
	v_fxn_model			        IN VARCHAR2 := '',
	v_aws_pn			        IN VARCHAR2 := '',
	v_mfg_pn				    IN VARCHAR2 := '',
	--v_sloc		                IN VARCHAR2 := '',
	v_user_name 		        IN VARCHAR2 := '',
	o_res 					    OUT VARCHAR2
	)
IS

	-- LOCAL VARIABLES	
	p_rowid					VARCHAR2(100) := '' ;
	v_count         		INTEGER;
    temp_fxn_model          VARCHAR2(100) := '' ;
   
	v_event_active			VARCHAR2(100) := '' ;
	TYPE StringArray IS TABLE OF VARCHAR2(200) INDEX BY PLS_INTEGER ;
	array_list 				StringArray;
	v_key					VARCHAR(100) := NULL ;
	v_val					VARCHAR(100) := NULL ;
  	ex               		EXCEPTION;

BEGIN

  	SELECT COUNT(*) INTO v_count FROM SHP_SB_WH WHERE component_sn = v_component_number;
  
    temp_fxn_model := v_fxn_model;

  	if substr(upper(v_fxn_model),1,2) ='AM'
  	THEN
        temp_fxn_model := substr(v_fxn_model,3);
  	END IF;
  
	-- Added by Quan: Validate content to detect non-digit and non-alphabet character. Accept dash but not two or more consecutive dashes - BEGIN (12/27/2023)
	SELECT FN_ISINCONTROLVALUE_EX('CHECK_BS_MTS_VALUE' , 'Y') INTO v_event_active FROM dual;
	IF v_event_active = 'N'
	/* 
	 * UPDATE DFMS_MAZ.WIP_D_CONTROL_VALUE SET CONTROL_VALUE = 'Y', UPDATER = USER, UPDATE_DATE = SYSDATE 
	 * WHERE PLANT_CODE = 'EPS1' AND CONTROL_NAME = 'CHECK_BS_MTS_VALUE' ;
	 */
	THEN
	    array_list(1) := 'COMPONENT_SN,' || v_component_number ;
	    array_list(2) := 'FXN_MODEL_ID,' || v_fxn_model ;
	    array_list(3) := 'AWS_MODEL_ID,' || v_aws_pn ;
	    array_list(4) := 'MFG_MODEL_ID,' || v_mfg_pn ;

	    -- Access the values from the array
	    FOR i IN 1..array_list.COUNT LOOP
		    SELECT REGEXP_SUBSTR(array_list(i), '[^,]+', 1, 1) ,
		    	   REGEXP_SUBSTR(array_list(i), '[^,]+', 1, 2)
		   	INTO v_key , v_val
			FROM dual;

		    IF REGEXP_LIKE(v_val, '[^[:alnum:]-]|-{2,}') THEN
		        RAISE_APPLICATION_ERROR(-20001, 'Illegal character in column ' || v_key || ' value: ' || v_val);
		    END IF;
	    END LOOP;
	END IF;
	-- Added by Quan: Validate content to detect non-digit and non-alphabet character. Accept dash but not two or more consecutive dashes - END (12/27/2023)


    IF v_count > 0
    THEN
        SELECT count(*) INTO v_count 
        FROM SHP_SB_WH WHERE component_sn = v_component_number and  fxn_model_id = temp_fxn_model; --v_fxn_model;
        
        if v_count = 0
        then
            update SHP_SB_WH set 
            fxn_model_id = temp_fxn_model, --v_fxn_model,
            --aws_model_id = v_aws_pn, 
            --mfg_model_id     = v_mfg_pn,
            --sloc         = v_sloc,
            last_update  =sysdate,
            last_update_by = v_user_name
            where component_sn = v_component_number;
        end if;
        --return;
    else
        insert into SHP_SB_WH (component_sn,fxn_model_id,aws_model_id, mfg_model_id,/*sloc,*/ extra_data, created_by)
        values (v_component_number,temp_fxn_model /*v_fxn_model*/,v_aws_pn,v_mfg_pn,/*v_sloc,*/'',v_user_name);
        
        -- select * from SHP_SB_WH;
        
        --delete SHP_SB_WH
        
        --return;
    end if;
    
   	o_res :='OK';
   	commit;
EXCEPTION
WHEN OTHERS
THEN
	o_res := o_res || ' ' || SQLERRM;
  	ROLLBACK;
  	sp_insert_track (' ', 'SHP_SB_WH_SP' , '3' , '4' , '5' , o_res);

END SHP_SB_WH_SP;
