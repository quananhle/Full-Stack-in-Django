-- Drop table

-- DROP TABLE public.shp_shipload;

CREATE TABLE public.shp_shipload (
	row_id serial4 NOT NULL,
	billoflading_id varchar(50) NULL,
	carrier varchar(20) NULL,
	seal_value varchar(50) NULL,
	container_number varchar(50) NULL,
	ship_method varchar(20) NULL,
	ship_date timestamptz NULL,
	status int4 NOT NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	deliverynumber_id varchar(255) NOT NULL,
	salesorder_id varchar(50) NOT NULL,
	scac_code varchar(30) NULL,
	tracking_no varchar(255) NULL,
	CONSTRAINT shp_shipload_pkey PRIMARY KEY (row_id),
	CONSTRAINT shp_shipload_deliverynumber_id_3e2c2ab9_fk_shp_deliv FOREIGN KEY (deliverynumber_id) REFERENCES public.shp_deliverynumber(deliverynumber_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT shp_shipload_salesorder_id_9719f116_fk_shp_sales FOREIGN KEY (salesorder_id) REFERENCES public.shp_salesorder(salesorder_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX shp_shipload_deliverynumber_id_3e2c2ab9 ON public.shp_shipload USING btree (deliverynumber_id);
CREATE INDEX shp_shipload_deliverynumber_id_3e2c2ab9_like ON public.shp_shipload USING btree (deliverynumber_id varchar_pattern_ops);
CREATE INDEX shp_shipload_salesorder_id_9719f116 ON public.shp_shipload USING btree (salesorder_id);
CREATE INDEX shp_shipload_salesorder_id_9719f116_like ON public.shp_shipload USING btree (salesorder_id varchar_pattern_ops);
