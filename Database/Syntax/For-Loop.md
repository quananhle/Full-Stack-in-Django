```{SQL}
CREATE OR REPLACE FUNCTION public.tls_get_sn_info(v_serial_number text)
 RETURNS TABLE(t_workorder_id character varying, t_station character varying, t_last_station character varying, t_skuno character varying, t_production_version character varying, t_route_id character varying, t_status character varying, t_row_id character varying, t_passed_station character varying, t_action character varying, t_scan_date character varying, t_scan_by character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
	BEGIN
 		DROP TABLE IF EXISTS tmp_get_sn_info;
		CREATE TEMP TABLE tmp_get_sn_info 
		(
        tmp_workorder			        VARCHAR(255) DEFAULT NULL,
        tmp_station				        VARCHAR(255) DEFAULT NULL,
        tmp_last_station		      VARCHAR(255) DEFAULT NULL,
        tmp_skuno				          VARCHAR(255) DEFAULT NULL,
        tmp_production_ver		    VARCHAR(255) DEFAULT NULL,
        tmp_route_id			        VARCHAR(255) DEFAULT NULL,
        tmp_status				        VARCHAR(255) DEFAULT NULL,
        tmp_rowid              	  VARCHAR(255) DEFAULT NULL PRIMARY KEY,
        tmp_station_id	          VARCHAR(255) DEFAULT NULL,
        tmp_action				        VARCHAR(255) DEFAULT NULL,
        tmp_scan_date			        VARCHAR(255) DEFAULT NULL,
        tmp_scan_by				        VARCHAR(255) DEFAULT NULL,
        tmp_group_seq			        INTEGER DEFAULT 10
		) ON COMMIT DROP;	
	
		INSERT INTO tmp_get_sn_info (tmp_workorder , tmp_station , tmp_last_station , tmp_skuno , tmp_production_ver , tmp_route_id , tmp_status , tmp_rowid, tmp_station_id, tmp_action, tmp_scan_date, tmp_scan_by)
		SELECT ms.workorder_id , ms.station_id , ms.last_station_id , ms.model_id AS skuno, mw.production_version , mw.route_id ,
				CASE 
            WHEN ms.shipped = 1 THEN 'SHIPPED'
            WHEN ms.completed = 1 THEN 'COMPLETED'
            WHEN ms.failed = 1 THEN 'FAILED'
            ELSE mssc.description
				END::VARCHAR AS status,
				CAST(msnt.row_id AS VARCHAR(50)) , msnt.station_id , 
				CASE 
            WHEN msnt.scan_type = 1 THEN 'IN'
            WHEN msnt.scan_type = 0 THEN 'OUT'
				END::VARCHAR AS "action",
				TO_CHAR(msnt.scan_date, 'YYYY-MM-DD HH24:MI:SS')::VARCHAR , msnt.scan_by 
		FROM mfg_serialnumber ms  JOIN mfg_serialstatuscategory mssc ON ms.sn_status_category = mssc.status_id 
								              JOIN mfg_workorder mw ON ms.workorder_id = mw.workorder_id 
								              JOIN mfg_serialnumbertrack msnt ON ms.serial_number = msnt.serial_number
		WHERE ms.serial_number = v_serial_number
		ORDER BY msnt.row_id DESC ;
	
		DO $$
			DECLARE
				v_row			tmp_get_sn_info%rowtype;
				v_station		VARCHAR(255) DEFAULT NULL;
				v_counter		INT := 1;
				v_group_seq		INTEGER;
			BEGIN
				FOR v_row IN 
					SELECT * FROM tmp_get_sn_info 
				LOOP
					SELECT tmp_group_seq INTO v_group_seq FROM tmp_get_sn_info WHERE tmp_rowid = v_row.tmp_rowid;
					IF v_station IS NULL THEN
						SELECT tmp_station_id INTO v_station FROM tmp_get_sn_info WHERE tmp_rowid = v_row.tmp_rowid;
					ELSE
						IF v_station = (SELECT tmp_station_id FROM tmp_get_sn_info WHERE tmp_rowid = v_row.tmp_rowid) THEN
							v_group_seq := v_group_seq * v_counter;
						ELSE
							SELECT tmp_station_id INTO v_station FROM tmp_get_sn_info WHERE tmp_rowid = v_row.tmp_rowid;
							v_counter := v_counter + 1;
							v_group_seq := v_group_seq * v_counter;
						END IF;
					END IF;
	        UPDATE tmp_get_sn_info SET tmp_group_seq = v_group_seq WHERE tmp_rowid = v_row.tmp_rowid;
	    		END LOOP;
		END$$;
	
		RETURN QUERY
			SELECT tmp_workorder , tmp_station , tmp_last_station , tmp_skuno , tmp_production_ver , tmp_route_id , tmp_status , tmp_rowid, tmp_station_id, tmp_action, tmp_scan_date, tmp_scan_by 
			FROM tmp_get_sn_info
			ORDER BY tmp_group_seq, tmp_scan_date;
	END;
$function$
;
```
