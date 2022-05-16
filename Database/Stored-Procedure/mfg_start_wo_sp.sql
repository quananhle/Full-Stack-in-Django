CREATE OR REPLACE PROCEDURE public.mfg_start_wo_sp(transtype text DEFAULT ''::text, v_workorder text DEFAULT ''::text, v_maskrulepattern text DEFAULT ''::text, username text DEFAULT ''::text, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$DECLARE 
   	gen_value				        text;
    var_rule_id				      int;
    var_current_sequence 	  int;
    var_length              int;
   
	  v_model					        text;
	  v_wo_qty				        int;
	  v_mask_current_sequence	int = 0;
	  v_mask_rule				      text;
	  v_mask_length			      int;
	  v_mask_rule_length		  int;
	  v_mask_id				        int;
	  i						            int = 1;
	  v_next_sn_value			    text;
	  tmp_val 				        text;
	  tmp_sn					        text;
	  v_mask_alg_value		    text;
	v_update_date			date;
	v_route_id				text;
	v_first_station			text;
	v_wo_status				int;
	v_mask_datatype			text;
	v_prod_version			text;
	v_cn_qty				int;
	c_checkcode				text;
	v_mod_wo_qty			int;
	v_country				text;
	v_ck_tmp				text;
	v_sndetail_sp_result	text;
	v_helper_sp_result		text;
	v_audit_counter			int = 0;
	v_validated_sn			text = '';
	v_revision				text;
	m						record;
	v_maskrule_validation	text;
	v_sn_limit_tst			int;
	v_sn_limit_qa			int;
	_te_rate				int;
begin
	
	if transtype = '' then
		RAISE EXCEPTION 'Transaction Type cannot be null/empty' USING HINT = 'Custom Error';
	end if;
	
	if v_workorder = '' then
		RAISE EXCEPTION 'Workorder value cannot be blank.' USING HINT = 'Custom Error';
	end if;	
	
	if transtype = 'START' then
		select skuno, target_qty, route_id, status_id, CASE WHEN production_version IS NULL THEN '' ELSE production_version end 
		into v_model, v_wo_qty, v_route_id, v_wo_status, v_prod_version
		from mfg_workorder where workorder_id = v_workorder;
	
--		raise notice 'v_model %, v_wo_qty %, v_route_id %, v_wo_status %, v_prod_version %', v_model, v_wo_qty, v_route_id, v_wo_status, v_prod_version;
		
		if v_wo_status <> 20 then
			RAISE EXCEPTION 'This WO % is not in ACCEPTED status.', v_workorder USING HINT = 'Custom Error';
		end if;
	
		if exists(select 0 from mfg_serialnumber where workorder_id = v_workorder) then 
			RAISE EXCEPTION 'This WO % contains already serial numbers.', v_workorder USING HINT = 'Custom Error';
		end if;			
	
		select station_id into v_first_station from mfg_stationroutes where route_id = v_route_id and flow_action = 'START';
		
		if not exists(select 0 from mfg_maskmodels where model_id = v_model) then 
			RAISE EXCEPTION 'There is no serialization record defined for model: %', v_model USING HINT = 'Custom Error';
		end if;
		
		select coalesce(mask_rule, '') into v_mask_rule from mfg_maskmodels where model_id = v_model;
		
--		raise notice 'mask rule %, sku % ', v_mask_rule, v_model;
	
		if length(v_mask_rule) = 0 then
			RAISE EXCEPTION 'There is no serial number rule defined for model: %', v_model USING HINT = 'Custom Error';
		end if;
		
		select mask_id, mask_rule, mask_current_sequence, mask_algorism_value, mask_length, update_date into v_mask_id, v_mask_rule, v_mask_current_sequence, v_mask_alg_value, v_mask_rule_length, v_update_date
		from mfg_mask where mask_rule = v_mask_rule;
	
--		raise notice 'v_mask_id %, v_mask_rule %, v_mask_current_sequence %, v_mask_alg_value %, v_mask_rule_length %', v_mask_id, v_mask_rule, v_mask_current_sequence, v_mask_alg_value, v_mask_rule_length;
		
		if v_mask_rule_length = 0 then	
			RAISE EXCEPTION 'Mask rule length for model: % is 0', v_model USING HINT = 'Custom Error';
		end if;
	
		if not exists(select * from mfg_segment where mask_id = v_mask_id) then 
			RAISE EXCEPTION 'There is no mask rule definition for model: %', v_model USING HINT = 'Custom Error';
		end if;
	
		if not exists(select * from mfg_segment where mask_id = v_mask_id and data_type in('Numeric', 'Alpha Numeric') ) then 
			RAISE EXCEPTION 'There is no sequence rule definition for model: %', v_model USING HINT = 'Custom Error';
		end if;
	
		for m in select model_id from mfg_workorderdetail where workorder_id = v_workorder
		loop
			call mfg_mask_rule_validation_sp('WO_START', m.model_id, v_maskrule_validation);
		end loop;
	
		if v_prod_version in ('2030', '2080') then
			if exists (select 0 from mfg_productversionrules where prod_version_id = v_prod_version and rule_id = 'CN_QTY') then 
				select rule_value into v_cn_qty from mfg_productversionrules where prod_version_id = v_prod_version and rule_id = 'CN_QTY';
				
 				--select mod(v_wo_qty / v_cn_qty) into v_mod_wo_qty;
 				select mod(v_wo_qty,v_cn_qty) into v_mod_wo_qty;
 				if v_mod_wo_qty <> 0 then
 					RAISE EXCEPTION 'WO Qty (%) cannot be divided by (%) based on production version rule', v_wo_qty, v_cn_qty USING HINT = 'Custom Error';
 				end if;
				v_wo_qty := v_wo_qty / v_cn_qty;
 			 						
			end if;
		end if;
		
	
		if not exists(select 0 from sadmin_syscontrolvalues where control_name = 'MSFT_STAMPING_IDENTIFIER' and control_value = v_prod_version) then
	
			if v_mask_rule = '' then
				call serialization_mask_rule_sp ('GET_MASK_RULE', v_model, 0, v_mask_rule);
			
				select data_type into v_mask_datatype from mfg_segment 			
				where mask_id = v_mask_id and data_type in ('Numeric', 'Alpha Numeric');
				
				if v_mask_datatype = 'Numeric' then 
					v_mask_alg_value := '0123456789';
				else 
					v_mask_alg_value := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
				end if; 
				
				update mfg_mask set mask_rule = v_maskRulePattern,
									mask_algorism_value = v_mask_alg_value
				where model_id = v_model;
			end if;
			
--			raise notice 'mask rule if % ', v_mask_rule;
			
			call serialization_mask_rule_sp ('GET_MASK_RULE', v_model, 1, tmp_val);		
		
--			raise notice 'tmp_val % ', tmp_val;
		
			select length into v_mask_length from mfg_segment 
			where mask_id = v_mask_id and data_type in ('Numeric', 'Alpha Numeric');
		
--			raise notice 'v_mask_length % ', v_mask_length;
		
			--save country code from PMDU mask rule string
			if v_prod_version = 'PMWO' then
				--pmdu sn rule sequence, resets daily to 1
				if v_update_date < current_date then
		    		update mfg_mask set mask_current_sequence = 1, update_date = now() where mask_rule = v_mask_rule;
		    	end if;
		    	
		    	v_country := substr(tmp_val, length(tmp_val)-2, 3);
		    	tmp_val := left(tmp_val, length(tmp_val)-3);
		    end if;
		   
			--save fixed values from country kit mask rule string
		    if v_prod_version = 'PMCK' then
		    	--pmdu ck sn rule sequence, resets daily to 1
				if v_update_date < current_date then
		    		update mfg_mask set mask_current_sequence = 1, update_date = now() where mask_rule = v_mask_rule;
		    	end if;
		    
		    	select coalesce(revision, '') into v_revision from mfg_materialmaster mm where customer_pn = 
		    		(select customer_pn from mfg_materialmaster where model_id = v_model);
		    	
		    	if v_revision = '' then 
		    		RAISE EXCEPTION 'Missing revision/customer pn for WO SKU (%)', v_model USING HINT = 'Custom Error';
		    	end if;
		    	
--		    	raise notice 'v_revision % ', v_revision;
		   		v_ck_tmp := substr(tmp_val, length(tmp_val)-3, 4);
--		   		raise notice 'v_ck_tmp % ', v_ck_tmp;
		   		v_ck_tmp := replace(v_ck_tmp, 'REV', v_revision);
--		   		raise notice 'v_ck_tmp % ', v_ck_tmp;
		   		tmp_val := left(tmp_val, length(tmp_val)-4);
		   	
--		   		raise notice 'tmp_val % ', tmp_val;
		   		
		    end if;
		   
--		   raise notice 'before while';

			WHILE (i <= v_wo_qty)
		    loop 
		    	select mask_current_sequence into v_mask_current_sequence from mfg_mask where mask_rule = v_mask_rule;

		    	--1G sn rule sequence, resets monthly to 0
		    	if  v_prod_version = '1GWO' then
		    		if to_char(v_update_date, 'yyyy-mm') < to_char(now(),'yyyy-mm') then
		    			update mfg_mask set mask_current_sequence = 0, update_date = now() where mask_rule = v_mask_rule;
		    		end if;
		    		
		    		call get_algorism_value_sp (v_mask_alg_value, v_mask_current_sequence, v_mask_length, v_next_sn_value);
		    		tmp_val := substr(tmp_val, 0, length(tmp_val));
		    	
		    		--calculate check code
		    		c_checkcode := (select get_check_code(tmp_val || v_next_sn_value));
		    		tmp_val := tmp_val || c_checkcode;
		    	end if;

		    	call get_algorism_value_sp (v_mask_alg_value, v_mask_current_sequence, v_mask_length, v_next_sn_value);
		    			    	
		    	v_mask_current_sequence := v_mask_current_sequence + 1;
		    	update mfg_mask set mask_current_sequence = v_mask_current_sequence, update_date = now() where mask_rule = v_mask_rule;	  

		    	--format country kit sequence value
		    	if v_prod_version = 'PMCK' then 
		    		v_next_sn_value := v_next_sn_value || v_ck_tmp;
		    	end if;
		   
		    	tmp_sn := tmp_val || v_next_sn_value;
		    
--		    	raise notice 'SN TO BE INSERTED: %', tmp_sn;
		    
		    	INSERT INTO mfg_serialnumber
				(serial_number, rework_id, generated_date, failed, sn_status_category, model_id, station_id, workorder_id, last_edit , last_edit_by , completed, shipped, product_status)
				VALUES(tmp_sn, '', NOW(), 0, 10, v_model, v_first_station, v_workorder, NOW(), username, 0, 0, 'FRESH');
		    		    
				--populate serialnumberdetail table
				call mfg_start_wo_sndetail_sp(v_workorder, tmp_sn, username, v_sndetail_sp_result);
				if v_sndetail_sp_result != '' then 
--					raise notice 'ERROR SN DETAIL';
					raise exception '(%)' , v_sndetail_sp_result USING HINT = 'Custom Error';
				end if;
			
		    	i := i + 1;
		    	tmp_sn = '';
		    end loop;
		end if;
		
		--send PMDU WO SNs to audit station
		if v_prod_version = 'PMWO' then 
			--QA SORTED
			if exists (select 0 from mfg_auditsortedtracking where value = v_workorder AND station_type = 'QA') then 
				delete from mfg_auditsortedtracking where value = v_workorder AND station_type = 'QA';
			end if;
			select 	case 
						when a.cnt <= 544 then 32
						when a.cnt <= 960 then 40
						when a.cnt <= 1632 then 48
						when a.cnt > 1632 then 64
					else
						0
					end into v_sn_limit_qa
			from (select count(serial_number) cnt from mfg_serialnumber where workorder_id = v_workorder) a;

			INSERT INTO mfg_auditsortedtracking (value, total, counter, last_edit_by, last_edit_date, validated_sn, station_type)
			select v_workorder, count(a.serial_number), 0, username, now(), string_agg(a.serial_number,','), 'QA'
			from (select serial_number from mfg_serialnumber
					where workorder_id = v_workorder
					order by serial_number
					limit v_sn_limit_qa) a;
			
			--TE SORTED
			if exists (select 0 from mfg_auditsortedtracking where value = v_workorder AND station_type = 'TST') then 
				delete from mfg_auditsortedtracking where value = v_workorder AND station_type = 'TST';
			end if;
			select coalesce(control_value::int, 0) into _te_rate from sadmin_syscontrolvalues where control_name = 'TE_AUDIT_RATE'; 		
			select ceil(count(serial_number)::float * _te_rate / 100) * 6 into v_sn_limit_tst
			from mfg_serialnumber
			where workorder_id = v_workorder;
			INSERT INTO mfg_auditsortedtracking (value, total, counter, last_edit_by, last_edit_date, validated_sn, station_type)
			select v_workorder, a.cnt, 0, username, now(), a.sn, 'TST'
			from (SELECT STRING_AGG(t.serial_number, ',') sn, count(t.serial_number) cnt
					FROM (
					  SELECT *, row_number() OVER(ORDER BY serial_number ASC) AS row
					  FROM mfg_serialnumber
					  where workorder_id = v_workorder
					  limit v_sn_limit_tst
					) t
					WHERE t.row % 6 = 1) a;
		end if; 
		
		IF v_prod_version = '1GWO' THEN
			CALL mfg_mac_start_wo (v_workorder,v_model,username,v_helper_sp_result);
		
			IF v_helper_sp_result != '' THEN 
				RAISE EXCEPTION '(%)' , v_helper_sp_result USING HINT = 'Custom Error';
			END IF;
		END IF;
	
	   	update mfg_workorder set 	status_id = 30 ,
	   								last_update = now(),
	   								last_update_by = username
	   	where workorder_id = v_workorder;
			   
	end if;
	 
	
	EXCEPTION
	    WHEN OTHERS THEN
	        sp_result := SQLERRM;

END;
$procedure$
;
