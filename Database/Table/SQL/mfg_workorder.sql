CREATE TABLE public.mfg_workorder (
	workorder_id varchar(25) NOT NULL,
	workorder_type varchar(50) NOT NULL,
	production_version varchar(50) NULL,
	route_id varchar(100) NULL,
	target_qty int4 NOT NULL,
	finished_qty int4 NULL,
	plant_code varchar(100) NOT NULL,
	model_desc varchar(100) NULL,
	line_name varchar(100) NULL,
	sap_release_date timestamptz NULL,
	schedule_date timestamptz NULL,
	labor_time varchar(100) NULL,
	hold_flag varchar(100) NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	skuno varchar(100) NOT NULL,
	status_id int4 NULL,
	started_date timestamptz NULL,
	completed_date timestamptz NULL,
	CONSTRAINT mfg_workorder_pkey PRIMARY KEY (workorder_id),
	CONSTRAINT mfg_workorder_skuno_15b24133_fk_mfg_materialmaster_model_id FOREIGN KEY (skuno) REFERENCES public.mfg_materialmaster(model_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_workorder_status_id_ca35403d_fk_mfg_wosta FOREIGN KEY (status_id) REFERENCES public.mfg_wostatuscategory(status_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_workorder_skuno_15b24133 ON public.mfg_workorder USING btree (skuno);
CREATE INDEX mfg_workorder_skuno_15b24133_like ON public.mfg_workorder USING btree (skuno varchar_pattern_ops);
CREATE INDEX mfg_workorder_status_id_ca35403d ON public.mfg_workorder USING btree (status_id);
CREATE INDEX mfg_workorder_workorder_id_9e693549_like ON public.mfg_workorder USING btree (workorder_id varchar_pattern_ops);
