CREATE OR REPLACE PROCEDURE public.serialization_mask_rule_sp(transtype text DEFAULT ''::text, v_model text DEFAULT ''::text, rule_string integer DEFAULT 0, INOUT sp_result text DEFAULT ''::text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE 
	v_mask_id				  int;
	v_mask_rule				text = '';
	r_min 					integer := 0 ; 
	r_max 					integer := 0 ;
	v_segment				text;
	var_num_sample			text;
	var_datatype			text;
	var_length              int;
	var_value				text;
	var_workweek			int;
	var_mask_string			text;
	var_remainder			int;
	i						int;
	_mask_rule				varchar(50);
begin
	CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
	if transtype = '' then
		RAISE EXCEPTION 'Transaction Type cannot be null/empty' USING HINT = 'Custom Error';
	end if;
	
	if transtype = 'GET_MASK_RULE' then		
		select mask_rule into _mask_rule from mfg_maskmodels where model_id = v_model;
	
		select mask_id into v_mask_id from mfg_mask where mask_rule = _mask_rule;
		-- Temp solution for maskmodelattributes --
		if sp_result <> '' then
			select a.mask_id, a.mask_rule into v_mask_id, _mask_rule from mfg_mask a inner join mfg_maskmodelattributes b on a.mask_id = b.mask_id where b.model_id = v_model;
		end if;
		-- Temp solution for maskmodelattributes --
		CREATE TEMP TABLE sn_rule (
			row_id			serial primary key,
		   	t_data_type		text,
		   	t_length		int,
		   	t_value			text
		) on commit DROP;
	
		insert into sn_rule (t_data_type, t_length, t_value) select data_type, length, value 
		from mfg_segment where mask_id = v_mask_id order by position;
				
		select MIN(row_id) into r_min from sn_rule;
		select MAX(row_id) into r_max from sn_rule;
	
		v_segment := '';
		var_num_sample := '';
		
		WHILE (r_min <= r_max)
	    loop 		
	    
			select t_data_type, t_length, t_value into var_datatype, var_length, var_value from sn_rule where row_id = r_min;			    	
	    						
			CASE var_datatype
			   	WHEN 'Shift Code' THEN
			   		IF var_length = 1 THEN
			    		IF rule_string = 0 THEN
			    			v_segment := v_segment || 'S';
			    		ELSE
			    			--get shift code
							IF (to_timestamp(to_char(now(),'HH24:MI:SS'),'HH24:MI:SS')::time > to_timestamp(to_char(cast('07:00:00' as TIME),'HH24:MI:SS'),'HH24:MI:SS')::time) AND 
							   (to_timestamp(to_char(now(),'HH24:MI:SS'),'HH24:MI:SS')::time < to_timestamp(to_char(cast('15:00:00' as TIME),'HH24:MI:SS'),'HH24:MI:SS')::time)
							THEN
								v_segment := v_segment || 'A';
							ELSIF (to_timestamp(to_char(now(),'HH24:MI:SS'),'HH24:MI:SS')::time > to_timestamp(to_char(cast('15:00:00' as TIME),'HH24:MI:SS'),'HH24:MI:SS')::time) AND 
							   	  (to_timestamp(to_char(now(),'HH24:MI:SS'),'HH24:MI:SS')::time < to_timestamp(to_char(cast('22:30:00' as TIME),'HH24:MI:SS'),'HH24:MI:SS')::time)
							THEN
								v_segment := v_segment || 'B';
							ELSE
								v_segment := v_segment || 'C';
							END IF;	
			    		END IF;
			    	END IF;			
			
			    WHEN 'Fixed' then
			    	v_segment := v_segment || var_value;
			   	WHEN 'Numeric' then
			   		if rule_string = 0 then
				   		for i in 1..var_length loop
				   			var_num_sample := var_num_sample || '#';
				   		end loop;
				        v_segment := var_num_sample;
				    end if;
			    WHEN 'Day' then
			    	if var_length = 1 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'D';
			    		else
			    			v_segment := v_segment || to_char(now(),'d');
			    		end if;
			    	elseif var_length = 2 then			    		
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'DD';
			    		else
			    			v_segment := v_segment || to_char(now(),'dd');
			    		end if;
			    	end if;
			    WHEN 'Day Code' then
			    	var_mask_string := '123456789ABCDEFGHIJKLMNOPQRSTUV';
			    	if var_length = 1 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'D';
			    		else
			    			v_segment := v_segment || substr(var_mask_string, extract(day from now())::int,1);
			    		end if;
			    	end if;
			    WHEN 'Month' then
			    	if var_length = 1 then			    		
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'M';
			    		else
			    			v_segment := v_segment || to_char(now(),'m');
			    		end if;
			    	elseif var_length = 2 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'MM';
			    		else
			    			v_segment := v_segment || to_char(now(),'mm');
			    		end if;
			    	elseif var_length = 3 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'MMM';
			    		else
			    			v_segment := v_segment || to_char(now(),'mmm');
			    		end if;
			    	end if;
			    WHEN 'Month Code' then
			    	if var_length = 1 then			    		
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'M';
			    		else
			    			var_mask_string := '123456789ABC';
			    			v_segment := v_segment || (select substring(var_mask_string,(select extract(month from current_date)::int),1));
			    		end if;
			    	end if;
			    WHEN 'Year' then
			   		if var_length = 1 then
			   			if rule_string = 0 then
			   				v_segment := v_segment || 'Y';
			   			else
			   				v_segment := v_segment || to_char(now(),'y');
			   			end if;
			    	elseif var_length = 2 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'YY';
			    		else
			   				v_segment := v_segment || to_char(now(),'yy');
			   			end if;
			    	elseif var_length = 3 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'YYY';
			    		else
			   				v_segment := v_segment || to_char(now(),'yyy');
			   			end if;
			    	elseif var_length = 4 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'YYYY';
			    		else
			   				v_segment := v_segment || to_char(now(),'yyyy');
			   			end if;
			    	end if;
			    when 'Year Code' then
			    	if var_length = 1 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'Y';
			    		else
			    			var_mask_string := '0123456789ABCDEFGHJKLMNPRSTUVW';
			    			var_remainder = mod(((select extract(year FROM CURRENT_DATE )::int)-2010),30);
			    			v_segment := v_segment || (select substring(var_mask_string, var_remainder+1, 1));
			    		end if;
			    	end if;
			    when 'Week' then
			    	if rule_string = 0 then
			    		v_segment := v_segment || 'WW';
			    	else
			    		v_segment := v_segment || (select get_working_week_fn(current_date));
			    	end if;
			    when 'Work Week' then
			    	if rule_string = 0 then
			    		v_segment := v_segment || 'WW';
			    	else
			    		select get_working_week_fn(current_date) into var_workweek;
			    		v_segment := v_segment || REPEAT('0', var_length - LENGTH(cast(var_workweek as text))) || var_workweek;
			    	end if;
			    when 'Check Code' then
			    	if var_length = 1 then
			    		if rule_string = 0 then
			    			v_segment := v_segment || 'C';
			    		else
			    			--get check code
			    			v_segment := '@';
			    		end if;
			    	end if;
			    when 'Model' then
			    	v_segment := v_segment || v_model;
			    when 'Manufacturer SKU' then
			    	v_segment := v_segment || var_value;
			    when 'Alpha Numeric' then
			    	if rule_string = 0 then
				    	for i in 1..var_length loop
				   			var_num_sample := var_num_sample || 'A';
				   		end loop;
			    		v_segment := var_num_sample;
			    	end if;
				else
			   		if rule_string = 0 then
			   			v_segment := '@';
			   		end if;
			END CASE;
	
	    	v_mask_rule := v_mask_rule || v_segment;
			v_segment := '';
			var_num_sample := '';
		
	        r_min := r_min + 1; 
	    end loop;
	   
		sp_result := v_mask_rule;
		
		drop table sn_rule;
	end if;
	 	
	EXCEPTION
	    WHEN OTHERS THEN
	        sp_result := SQLERRM;						
	--commit;    		
end;
$procedure$
;
