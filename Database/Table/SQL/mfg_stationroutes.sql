-- Drop table

-- DROP TABLE public.mfg_stationroutes;

CREATE TABLE public.mfg_stationroutes (
	row_id serial4 NOT NULL,
	audit_sort int4 NULL,
	"sequence" int4 NULL,
	station_action int4 NULL,
	audit_station_id varchar(255) NULL,
	fail_station_id varchar(255) NULL,
	next_station_id varchar(255) NULL,
	repaired_station_id varchar(255) NULL,
	route_id varchar(255) NOT NULL,
	station_id varchar(255) NOT NULL,
	flow_action varchar(30) NULL,
	last_edit timestamptz NOT NULL,
	last_edit_by varchar(50) NULL,
	alt_repaired_station_id varchar(255) NULL,
	visible int4 NULL,
	CONSTRAINT mfg_stationroutes_pkey PRIMARY KEY (row_id),
	CONSTRAINT mfg_stationroutes_alt_repaired_station_df51b11f_fk_mfg_stati FOREIGN KEY (alt_repaired_station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_stationroutes_audit_station_id_2cc02688_fk_mfg_stati FOREIGN KEY (audit_station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_stationroutes_fail_station_id_79f7963c_fk_mfg_stati FOREIGN KEY (fail_station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_stationroutes_next_station_id_2ad3c031_fk_mfg_stati FOREIGN KEY (next_station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_stationroutes_repaired_station_id_e45410dd_fk_mfg_stati FOREIGN KEY (repaired_station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_stationroutes_route_id_8665b3ed_fk_mfg_route_route_id FOREIGN KEY (route_id) REFERENCES public.mfg_route(route_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT mfg_stationroutes_station_id_e06284b9_fk_mfg_station_station_id FOREIGN KEY (station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_stationroutes_alt_repaired_station_id_df51b11f ON public.mfg_stationroutes USING btree (alt_repaired_station_id);
CREATE INDEX mfg_stationroutes_alt_repaired_station_id_df51b11f_like ON public.mfg_stationroutes USING btree (alt_repaired_station_id varchar_pattern_ops);
CREATE INDEX mfg_stationroutes_audit_station_id_2cc02688 ON public.mfg_stationroutes USING btree (audit_station_id);
CREATE INDEX mfg_stationroutes_audit_station_id_2cc02688_like ON public.mfg_stationroutes USING btree (audit_station_id varchar_pattern_ops);
CREATE INDEX mfg_stationroutes_fail_station_id_79f7963c ON public.mfg_stationroutes USING btree (fail_station_id);
CREATE INDEX mfg_stationroutes_fail_station_id_79f7963c_like ON public.mfg_stationroutes USING btree (fail_station_id varchar_pattern_ops);
CREATE INDEX mfg_stationroutes_next_station_id_2ad3c031 ON public.mfg_stationroutes USING btree (next_station_id);
CREATE INDEX mfg_stationroutes_next_station_id_2ad3c031_like ON public.mfg_stationroutes USING btree (next_station_id varchar_pattern_ops);
CREATE INDEX mfg_stationroutes_repaired_station_id_e45410dd ON public.mfg_stationroutes USING btree (repaired_station_id);
CREATE INDEX mfg_stationroutes_repaired_station_id_e45410dd_like ON public.mfg_stationroutes USING btree (repaired_station_id varchar_pattern_ops);
CREATE INDEX mfg_stationroutes_route_id_8665b3ed ON public.mfg_stationroutes USING btree (route_id);
CREATE INDEX mfg_stationroutes_route_id_8665b3ed_like ON public.mfg_stationroutes USING btree (route_id varchar_pattern_ops);
CREATE INDEX mfg_stationroutes_station_id_e06284b9 ON public.mfg_stationroutes USING btree (station_id);
CREATE INDEX mfg_stationroutes_station_id_e06284b9_like ON public.mfg_stationroutes USING btree (station_id varchar_pattern_ops);
