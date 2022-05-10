-- Drop table

-- DROP TABLE public.shp_deliverynumberdetail;

CREATE TABLE public.shp_deliverynumberdetail (
	row_id serial4 NOT NULL,
	salesorder_item varchar(255) NOT NULL,
	request_qty int4 NOT NULL,
	current_qty int4 NOT NULL,
	ship_qty int4 NOT NULL,
	customer_pn varchar(255) NOT NULL,
	customer_po varchar(255) NOT NULL,
	customer_line_item varchar(255) NOT NULL,
	net_weight numeric(12, 2) NOT NULL,
	net_price numeric(12, 2) NOT NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	deliverynumber_id varchar(255) NOT NULL,
	salesorder_id varchar(50) NOT NULL,
	skuno_id varchar(100) NOT NULL,
	CONSTRAINT shp_deliverynumberdetail_pkey PRIMARY KEY (row_id),
	CONSTRAINT shp_deliverynumberde_deliverynumber_id_f1e246bf_fk_shp_deliv FOREIGN KEY (deliverynumber_id) REFERENCES public.shp_deliverynumber(deliverynumber_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT shp_deliverynumberde_salesorder_id_5c53c30c_fk_shp_sales FOREIGN KEY (salesorder_id) REFERENCES public.shp_salesorder(salesorder_id) DEFERRABLE INITIALLY DEFERRED,
	CONSTRAINT shp_deliverynumberde_skuno_id_59d13e59_fk_mfg_mater FOREIGN KEY (skuno_id) REFERENCES public.mfg_materialmaster(model_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX shp_deliverynumberdetail_deliverynumber_id_f1e246bf ON public.shp_deliverynumberdetail USING btree (deliverynumber_id);
CREATE INDEX shp_deliverynumberdetail_deliverynumber_id_f1e246bf_like ON public.shp_deliverynumberdetail USING btree (deliverynumber_id varchar_pattern_ops);
CREATE INDEX shp_deliverynumberdetail_salesorder_id_5c53c30c ON public.shp_deliverynumberdetail USING btree (salesorder_id);
CREATE INDEX shp_deliverynumberdetail_salesorder_id_5c53c30c_like ON public.shp_deliverynumberdetail USING btree (salesorder_id varchar_pattern_ops);
CREATE INDEX shp_deliverynumberdetail_skuno_id_59d13e59 ON public.shp_deliverynumberdetail USING btree (skuno_id);
CREATE INDEX shp_deliverynumberdetail_skuno_id_59d13e59_like ON public.shp_deliverynumberdetail USING btree (skuno_id varchar_pattern_ops);
