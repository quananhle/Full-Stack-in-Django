-- Drop table

-- DROP TABLE public.shp_salesorderdetail;

CREATE TABLE public.shp_salesorderdetail (
	row_id serial4 NOT NULL,
	salesorder_item varchar(255) NOT NULL,
	salesorder_qty int4 NOT NULL,
	ship_qty int4 NULL,
	subtotal numeric(12, 2) NULL,
	customer_po varchar(255) NOT NULL,
	customer_pn varchar(255) NOT NULL,
	unit_price numeric(12, 2) NOT NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	salesorder_id varchar(50) NOT NULL,
	skuno_id varchar(100) NOT NULL,
	currency varchar(50) NULL,
	CONSTRAINT shp_salesorderdetail_pkey PRIMARY KEY (row_id),
	CONSTRAINT shp_salesorderdetail_salesorder_id_7c22868f_fk_shp_sales FOREIGN KEY (salesorder_id) REFERENCES public.shp_salesorder(salesorder_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT shp_salesorderdetail_skuno_id_21d8d2e0_fk_mfg_mater FOREIGN KEY (skuno_id) REFERENCES public.mfg_materialmaster(model_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX shp_salesorderdetail_salesorder_id_7c22868f ON public.shp_salesorderdetail USING btree (salesorder_id);
CREATE INDEX shp_salesorderdetail_salesorder_id_7c22868f_like ON public.shp_salesorderdetail USING btree (salesorder_id varchar_pattern_ops);
CREATE INDEX shp_salesorderdetail_skuno_id_21d8d2e0 ON public.shp_salesorderdetail USING btree (skuno_id);
CREATE INDEX shp_salesorderdetail_skuno_id_21d8d2e0_like ON public.shp_salesorderdetail USING btree (skuno_id varchar_pattern_ops);
