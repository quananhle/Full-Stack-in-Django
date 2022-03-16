-- Drop table

-- DROP TABLE public.shp_deliverynumber;

CREATE TABLE public.shp_deliverynumber (
	shipped int4 NOT NULL,
	invoice_no varchar(250) NULL,
	confirmed int4 NOT NULL,
	confirmed_date timestamptz NULL,
	cancelled int4 NOT NULL,
	confirmed_856 int4 NOT NULL,
	deliverynumber_id varchar(255) NOT NULL,
	customer_po varchar(255) NOT NULL,
	customer_name varchar(255) NOT NULL,
	confirmed_856_date timestamptz NULL,
	ship_date timestamptz NULL,
	customer_soldto varchar(255) NOT NULL,
	order_type varchar(255) NOT NULL,
	customer_no varchar(255) NOT NULL,
	bill_of_landing varchar(255) NULL,
	plant_code varchar(100) NOT NULL,
	delivery_type varchar(255) NOT NULL,
	status int4 NOT NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	salesorder_id varchar(50) NOT NULL,
	CONSTRAINT shp_deliverynumber_pkey PRIMARY KEY (deliverynumber_id),
	CONSTRAINT shp_deliverynumber_salesorder_id_87f2f055_fk_shp_sales FOREIGN KEY (salesorder_id) REFERENCES public.shp_salesorder(salesorder_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX shp_deliverynumber_deliverynumber_id_03ef67a7_like ON public.shp_deliverynumber USING btree (deliverynumber_id varchar_pattern_ops);
CREATE INDEX shp_deliverynumber_salesorder_id_87f2f055 ON public.shp_deliverynumber USING btree (salesorder_id);
CREATE INDEX shp_deliverynumber_salesorder_id_87f2f055_like ON public.shp_deliverynumber USING btree (salesorder_id varchar_pattern_ops);
