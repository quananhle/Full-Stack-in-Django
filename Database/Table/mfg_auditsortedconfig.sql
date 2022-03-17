### mfg_auditsortedconfig
![Audit Sorted Config](https://user-images.githubusercontent.com/35042430/158834018-1abab3e1-e13a-4fc7-bb9e-bc22dc56b8e0.png)

-- Drop table

-- DROP TABLE public.mfg_auditsortedconfig;

CREATE TABLE public.mfg_auditsortedconfig (
	row_id serial4 NOT NULL,
	sorted_type varchar(100) NULL,
	sorted_value varchar(100) NULL,
	rate numeric(5, 2) NULL,
	last_edit_by varchar(100) NULL,
	last_edit_date timestamptz NULL,
	station_id varchar(255) NOT NULL,
	CONSTRAINT mfg_auditsortedconfig_pkey PRIMARY KEY (row_id),
	CONSTRAINT mfg_auditsortedconfi_station_id_e2a30b23_fk_mfg_stati FOREIGN KEY (station_id) REFERENCES public.mfg_station(station_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_auditsortedconfig_station_id_e2a30b23 ON public.mfg_auditsortedconfig USING btree (station_id);
CREATE INDEX mfg_auditsortedconfig_station_id_e2a30b23_like ON public.mfg_auditsortedconfig USING btree (station_id varchar_pattern_ops);
