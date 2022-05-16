-- Drop table

-- DROP TABLE public.mfg_route;

CREATE TABLE public.mfg_route (
	route_id varchar(255) NOT NULL,
	plant_code varchar(50) NULL,
	last_edit_by varchar(50) NOT NULL,
	last_edit timestamptz NOT NULL,
	prod_version_id varchar(255) NULL,
	CONSTRAINT mfg_route_pkey PRIMARY KEY (route_id),
	CONSTRAINT mfg_route_prod_version_id_95630c7b_fk_mfg_produ FOREIGN KEY (prod_version_id) REFERENCES public.mfg_productversion(prod_version_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_route_prod_version_id_95630c7b ON public.mfg_route USING btree (prod_version_id);
CREATE INDEX mfg_route_prod_version_id_95630c7b_like ON public.mfg_route USING btree (prod_version_id varchar_pattern_ops);
CREATE INDEX mfg_route_route_id_007bb1af_like ON public.mfg_route USING btree (route_id varchar_pattern_ops);
