CREATE OR REPLACE FUNCTION public.lrm_get_wo_info(v_workorder_id text)
	RETURNS TABLE(t_workorder_id character varying, t_status_id character varying, t_target_qty character varying, t_skuno character varying, t_workorder_type character varying, t_sn_from character varying, t_sn_to character varying, t_order_type character varying, t_object_type character varying)
	LANGUAGE plpgsql
AS $function$
DECLARE
    v_production_version           text;
	BEGIN
		SELECT mw.production_version INTO v_production_version FROM mfg_workorder mw WHERE mw.workorder_id = v_workorder_id;
		CASE
			WHEN v_production_version = 'FBWO' THEN
			RETURN QUERY
				SELECT a.workorder_id , mw."name" AS status , CAST(a.target_qty AS VARCHAR(50)), a.skuno , a.production_version , a.serial_number AS sn_from , b.serial_number AS sn_to , CAST(c.customer || ' WELDING ORDER' AS VARCHAR(50)) AS order_type , c.object_type
				FROM (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
					  FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number LIMIT 1) a
				FULL OUTER JOIN (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
								 FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number DESC LIMIT 1) b
				ON a.workorder_id = b.workorder_id
				JOIN mfg_wostatuscategory mw ON a.status_id = mw.status_id, srv_labelconfig c WHERE c.row_id = 29;
			WHEN v_production_version = 'FBRACK' THEN
			RETURN QUERY
				SELECT a.workorder_id , mw."name" AS status , CAST(a.target_qty AS VARCHAR(50)), a.skuno , a.production_version , a.serial_number AS sn_from , b.serial_number AS sn_to , CAST(c.customer || ' RACK ORDER' AS VARCHAR(50)) AS order_type , c.object_type
				FROM (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
					  FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number LIMIT 1) a
				FULL OUTER JOIN (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
								 FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number DESC LIMIT 1) b
				ON a.workorder_id = b.workorder_id
				JOIN mfg_wostatuscategory mw ON a.status_id = mw.status_id, srv_labelconfig c WHERE c.row_id = 31;
			WHEN v_production_version = 'PMWO' THEN
			RETURN QUERY
				SELECT a.workorder_id , mw."name" AS status , CAST(a.target_qty AS VARCHAR(50)), a.skuno , a.production_version , a.serial_number AS sn_from , b.serial_number AS sn_to , CAST(c.customer || ' PMDU PRODUCTION ORDER' AS VARCHAR(50)) AS order_type , c.object_type
				FROM (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
					  FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number LIMIT 1) a
				FULL OUTER JOIN (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
								 FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number DESC LIMIT 1) b
				ON a.workorder_id = b.workorder_id
				JOIN mfg_wostatuscategory mw ON a.status_id = mw.status_id, srv_labelconfig c WHERE c.row_id = 15;
			WHEN v_production_version = 'PMCK' THEN
			RETURN QUERY
				SELECT a.workorder_id , mw."name" AS status , CAST(a.target_qty AS VARCHAR(50)), a.skuno , a.production_version , a.serial_number AS sn_from , b.serial_number AS sn_to , CAST(c.customer || ' PMDU COUNTRY KIT ORDER' AS VARCHAR(50)) AS order_type , c.object_type
				FROM (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
					  FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number LIMIT 1) a
				FULL OUTER JOIN (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
								 FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number DESC LIMIT 1) b
				ON a.workorder_id = b.workorder_id
				JOIN mfg_wostatuscategory mw ON a.status_id = mw.status_id, srv_labelconfig c WHERE c.row_id = 16;
			WHEN v_production_version = '1GWO' THEN
			RETURN QUERY	
				SELECT a.workorder_id , mw."name" AS status , CAST(a.target_qty AS VARCHAR(50)), a.skuno , a.production_version , a.serial_number AS sn_from , b.serial_number AS sn_to , CAST(c.customer || ' 1G PRODUCTION ORDER' AS VARCHAR(50)) AS order_type , c.object_type
				FROM (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
					  FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number LIMIT 1) a
				FULL OUTER JOIN (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
								 FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number DESC LIMIT 1) b
				ON a.workorder_id = b.workorder_id
				JOIN mfg_wostatuscategory mw ON a.status_id = mw.status_id, srv_labelconfig c WHERE c.row_id = 22;
			ELSE
			RETURN QUERY	
				SELECT a.workorder_id , mw."name" AS status , CAST(a.target_qty AS VARCHAR(50)), a.skuno , a.production_version , a.serial_number AS sn_from , b.serial_number AS sn_to , CAST(c.customer || '' AS VARCHAR(50)) AS order_type
				FROM (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
					  FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number LIMIT 1) a
				FULL OUTER JOIN (SELECT ms.workorder_id , ms.serial_number , ms.failed , ms.completed , ms.shipped , ms.model_id , mw3.production_version , mw3.target_qty , mw3.skuno , mw3.status_id 
								 FROM mfg_serialnumber ms JOIN mfg_workorder mw3 ON ms.workorder_id = mw3.workorder_id WHERE mw3.workorder_id = v_workorder_id ORDER BY ms.serial_number DESC LIMIT 1) b
				ON a.workorder_id = b.workorder_id
				JOIN mfg_wostatuscategory mw ON a.status_id = mw.status_id;
		END CASE;
	END;
$function$
;
