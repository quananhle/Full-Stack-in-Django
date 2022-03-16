-- Drop table

-- DROP TABLE public.shp_palletdeliverynumber;

CREATE TABLE public.shp_palletdeliverynumber (
	row_id serial4 NOT NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	deliverynumber_id varchar(255) NOT NULL,
	pallet_id varchar(200) NOT NULL,
	CONSTRAINT shp_palletdeliverynumber_pkey PRIMARY KEY (row_id),
	CONSTRAINT shp_palletdeliverynu_deliverynumber_id_dc41a9a8_fk_shp_deliv FOREIGN KEY (deliverynumber_id) REFERENCES public.shp_deliverynumber(deliverynumber_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT shp_palletdeliverynu_pallet_id_c4ea8142_fk_shp_palle FOREIGN KEY (pallet_id) REFERENCES public.shp_pallet(pallet_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX shp_palletdeliverynumber_deliverynumber_id_dc41a9a8 ON public.shp_palletdeliverynumber USING btree (deliverynumber_id);
CREATE INDEX shp_palletdeliverynumber_deliverynumber_id_dc41a9a8_like ON public.shp_palletdeliverynumber USING btree (deliverynumber_id varchar_pattern_ops);
CREATE INDEX shp_palletdeliverynumber_pallet_id_c4ea8142 ON public.shp_palletdeliverynumber USING btree (pallet_id);
CREATE INDEX shp_palletdeliverynumber_pallet_id_c4ea8142_like ON public.shp_palletdeliverynumber USING btree (pallet_id varchar_pattern_ops);
