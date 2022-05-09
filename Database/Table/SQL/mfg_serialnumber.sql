-- Drop table

-- DROP TABLE public.mfg_serialnumber;

CREATE TABLE public.mfg_serialnumber (
	serial_number varchar(255) NOT NULL,
	rework int4 NULL,
	rework_id varchar(100) NULL,
	generated_date timestamptz NULL,
	assy_date timestamptz NULL,
	complete_date timestamptz NULL,
	pack_date timestamptz NULL,
	ship_date timestamptz NULL,
	failed int4 NULL,
	completed int4 NULL,
	shipped int4 NULL,
	last_edit_by varchar(50) NULL,
	last_edit timestamptz NOT NULL,
	model_id varchar(100) NULL,
	sn_status_category int4 NULL,
	station_id varchar(255) NULL,
	workorder_id varchar(25) NULL,
	last_station_id varchar(255) NULL,
	product_status varchar(50) NULL,
	CONSTRAINT mfg_serialnumber_pkey PRIMARY KEY (serial_number),
	CONSTRAINT mfg_serialnumber_serial_number_workorder_id_bb21e13d_uniq UNIQUE (serial_number, workorder_id),
	CONSTRAINT mfg_serialnumber_last_station_id_70ae23cd_fk_mfg_stati FOREIGN KEY (last_station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_serialnumber_model_id_414a8bda_fk_mfg_mater FOREIGN KEY (model_id) REFERENCES public.mfg_materialmaster(model_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_serialnumber_sn_status_category_2d9ada1a_fk_mfg_seria FOREIGN KEY (sn_status_category) REFERENCES public.mfg_serialstatuscategory(status_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_serialnumber_station_id_8caa37f0_fk_mfg_station_station_id FOREIGN KEY (station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_serialnumber_workorder_id_82d12731_fk_mfg_worko FOREIGN KEY (workorder_id) REFERENCES public.mfg_workorder(workorder_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_serialnumber_last_station_id_70ae23cd ON public.mfg_serialnumber USING btree (last_station_id);
CREATE INDEX mfg_serialnumber_last_station_id_70ae23cd_like ON public.mfg_serialnumber USING btree (last_station_id varchar_pattern_ops);
CREATE INDEX mfg_serialnumber_model_id_414a8bda ON public.mfg_serialnumber USING btree (model_id);
CREATE INDEX mfg_serialnumber_model_id_414a8bda_like ON public.mfg_serialnumber USING btree (model_id varchar_pattern_ops);
CREATE INDEX mfg_serialnumber_serial_number_4b834893_like ON public.mfg_serialnumber USING btree (serial_number varchar_pattern_ops);
CREATE INDEX mfg_serialnumber_sn_status_category_2d9ada1a ON public.mfg_serialnumber USING btree (sn_status_category);
CREATE INDEX mfg_serialnumber_station_id_8caa37f0 ON public.mfg_serialnumber USING btree (station_id);
CREATE INDEX mfg_serialnumber_station_id_8caa37f0_like ON public.mfg_serialnumber USING btree (station_id varchar_pattern_ops);
CREATE INDEX mfg_serialnumber_workorder_id_82d12731 ON public.mfg_serialnumber USING btree (workorder_id);
CREATE INDEX mfg_serialnumber_workorder_id_82d12731_like ON public.mfg_serialnumber USING btree (workorder_id varchar_pattern_ops);
