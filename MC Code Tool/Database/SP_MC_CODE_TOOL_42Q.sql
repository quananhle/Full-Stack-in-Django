CREATE OR REPLACE PROCEDURE DFMS_MAZ."SP_MC_CODE_TOOL_42Q"(
	i_trans_type		IN VARCHAR2 								:= '',
	i_mc_code			IN WIP_S_MATERIAL_CATEGORY.MC_CODE%TYPE 	:= '',
	i_mc_description	IN WIP_S_MATERIAL_CATEGORY.MC_DESC%TYPE 	:= '',
	i_scan_mode			IN WIP_S_MATERIAL_CATEGORY.SCAN_MODE%TYPE 	:= '',
	i_category			IN WIP_S_MATERIAL_CATEGORY.CATEGORY%TYPE 	:= '',
	i_scannable			IN WIP_S_MATERIAL_CATEGORY.SCANNABLE%TYPE 	:= NULL,
	i_user				IN WIP_S_MATERIAL_CATEGORY.CREATOR%TYPE 	:= '',
	o_res 				OUT VARCHAR2
)
IS
	ex			EXCEPTION;
	v_count		INTEGER;
   	v_mc_code	WIP_S_MATERIAL_CATEGORY.MC_CODE%TYPE;
   	v_mc_desc	WIP_S_MATERIAL_CATEGORY.MC_DESC%TYPE;
   	v_scan_mode	WIP_S_MATERIAL_CATEGORY.SCAN_MODE%TYPE;
   	v_category	WIP_S_MATERIAL_CATEGORY.CATEGORY%TYPE;
   	v_scannable	WIP_S_MATERIAL_CATEGORY.SCANNABLE%TYPE;
BEGIN
	v_mc_code := i_mc_code ; v_mc_desc := i_mc_description ; v_scan_mode := i_scan_mode ; v_category := i_category ; v_scannable := i_scannable ;

   	-- Validate if MC Code is empty
	IF (v_mc_code = 'N/A') OR (v_mc_code = '') OR (v_mc_code IS NULL)
   	THEN
   		o_res := 'Missing MC Code';
   		DBMS_OUTPUT.PUT_LINE('Missing MC Code');
   		RETURN;
   	END IF;

    -- Validate transaction type
	IF (i_trans_type = 'N/A') OR (i_trans_type = '') OR (i_trans_type IS NULL)
   	THEN
   		o_res := 'Missing transtype';
   		DBMS_OUTPUT.PUT_LINE('Missing transtype');
   		RETURN;
   	ELSIF i_trans_type = 'INSERT'
   	THEN
   		-- Validate if MC Code is not unique
   		SELECT COUNT(1) INTO v_count FROM WIP_S_MATERIAL_CATEGORY WHERE MC_CODE = v_mc_code;
   		IF v_count <> 0
   		THEN
	   		o_res := 'MC Code: "' || v_mc_code || '" already exists. Insert different MC Code.';
	   		DBMS_OUTPUT.PUT_LINE('MC Code: "' || v_mc_code || '" already exists. Insert different MC Code.');
	   		RETURN;
	   	END IF;

   		INSERT INTO WIP_S_MATERIAL_CATEGORY (MC_CODE , MC_DESC , SFG_TYPE , UPLOAD_ASN_FLAG , UOM , IS_KEY_PARTS , KIT_TYPE , BIN_SSN_FLAG , 
   											 KP_REC_FLAG , PREKIT_TYPE , SN_INC_PN_FLAG , SN_PN_FROM_DIGIT , SN_PN_TO_DIGIT , SN_INC_EEE_FLAG , SN_EEE_FROM_DIGIT , 
   											 SN_EEE_TO_DIGIT , SN_INC_COO_FLAG , SN_COO_FROM_DIGIT , SN_COO_TO_DIGIT , CHK_GMID_FLAG , PRODUCTION_GROUP , MATERIAL_TYPE , 
   											 IS_CHASSIS , RECV_FLAG , L6_SUBPART_FLAG , CREATOR , CREATE_DATE , UPDATER , UPDATE_DATE , PICK_GROUP , PTM_FLAG , 
   											 OTHER_MC_CODE , DEF_ROUTE_CODE , DEF_LINE_NAME , WO_TYPE , SCAN_MODE , CATEGORY , SCANNABLE) 
   									 VALUES (v_mc_code , v_mc_desc , 'SYSTEM' , NULL , NULL , 0 , NULL , NULL ,
   											 NULL , NULL , NULL , 4 , 8 , NULL , 2 ,
   											 5 , NULL , 14 , 15 , 0 , NULL , NULL ,
   											 NULL , 0 , NULL , i_user , SYSDATE , NULL , SYSDATE , NULL , 0 ,
   											 NULL , NULL , NULL , NULL , v_scan_mode , v_category , v_scannable);

   	ELSIF i_trans_type = 'EDIT'
   	THEN
   		-- Validate if MC Code is not already existed
   		SELECT COUNT(1) INTO v_count FROM WIP_S_MATERIAL_CATEGORY WHERE MC_CODE = v_mc_code;
   		IF v_count = 0
   		THEN
	   		o_res := 'MC Code: "' || v_mc_code || '" not found. Call I.T.';
	   		DBMS_OUTPUT.PUT_LINE('MC Code: "' || v_mc_code || '" not found. Call I.T.');
	   		RETURN;
	   	END IF;

   		-- Validate if MC Description is same as existing record
	    SELECT COUNT(1) INTO v_count FROM WIP_S_MATERIAL_CATEGORY WHERE MC_CODE = v_mc_code AND MC_DESC = v_mc_desc;
   		IF v_count <> 0
   		THEN
   			NULL;
	   	END IF;
   		-- Validate if MC Description is empty
		IF (v_mc_desc = 'N/A') OR (v_mc_desc = '') OR (v_mc_desc IS NULL)
	   	THEN
	   		v_mc_desc := 'N/A';
	   	END IF;

	    -- Validate if Scan Mode is empty
   		IF (v_scan_mode = '') OR (v_scan_mode IS NULL)
	   	THEN
	   		SELECT SCAN_MODE INTO v_scan_mode FROM WIP_S_MATERIAL_CATEGORY WHERE MC_CODE = v_mc_code ;
	   	END IF;
   		-- Validate Scan Mode
	    SELECT COUNT(1) INTO v_count FROM WIP_S_MATERIAL_CATEGORY WHERE SCAN_MODE = v_scan_mode;
   		IF v_count = 0
   		THEN
	   		o_res := 'Scan Mode: "' || v_scan_mode || '" invalid. Call I.T.';
	   		DBMS_OUTPUT.PUT_LINE('Scan Mode: "' || v_scan_mode || '" invalid. Call I.T.');
	   		RETURN;
	   	END IF;

	    -- Validate if Category is empty
   		IF (v_category = '') OR (v_category IS NULL)
	   	THEN
	   		SELECT CATEGORY INTO v_category FROM WIP_S_MATERIAL_CATEGORY WHERE MC_CODE = v_mc_code ;
	   	END IF;
   		-- Validate Category
	    SELECT COUNT(1) INTO v_count FROM WIP_S_MATERIAL_CATEGORY WHERE CATEGORY = v_category;
   		IF v_count = 0
   		THEN
	   		o_res := 'Category: "' || v_category || '" invalid. Call I.T.';
	   		DBMS_OUTPUT.PUT_LINE('Category: "' || v_category || '" invalid. Call I.T.');
	   		RETURN;
	   	END IF;
	   
	    -- Validate if Scannable is empty
   		IF (v_scannable = '') OR (v_scannable IS NULL) OR (v_scannable NOT IN (0 , 1))
	   	THEN
	   		SELECT SCANNABLE INTO v_scannable FROM WIP_S_MATERIAL_CATEGORY WHERE MC_CODE = v_mc_code ;
	   	END IF;

	   	UPDATE WIP_S_MATERIAL_CATEGORY SET MC_DESC = v_mc_desc , UPDATER = i_user , UPDATE_DATE = SYSDATE , 
	   									   SCAN_MODE = v_scan_mode , CATEGORY = v_category , SCANNABLE = v_scannable 
	   	WHERE MC_CODE = v_mc_code ;

   	ELSE
   		o_res := 'Transtype: "' || i_trans_type || '" does not exist.';
   		DBMS_OUTPUT.PUT_LINE('Transtype: "' || i_trans_type || '" does not exist.');
   		RETURN;
   	END IF;
   
   	o_res := 'OK';

EXCEPTION
WHEN OTHERS
THEN
	o_res := o_res || ' ' || SQLERRM;
  	ROLLBACK;
END SP_MC_CODE_TOOL_42Q;
