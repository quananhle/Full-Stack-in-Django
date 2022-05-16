-- Drop table

-- DROP TABLE public.srv_labelconfig;

CREATE TABLE public.srv_labelconfig (
	row_id serial4 NOT NULL,
	object_type varchar(255) NOT NULL,
	"object" varchar(255) NOT NULL,
	station varchar(255) NOT NULL,
	customer varchar(255) NOT NULL,
	label_id varchar(255) NOT NULL,
	body_qty int4 NULL,
	printer_id varchar(255) NOT NULL,
	printer_webservice varchar(255) NOT NULL,
	last_update_by varchar(50) NULL,
	last_update timestamptz NULL,
	reprint int4 NULL DEFAULT 0,
	reprint_values varchar(255) NULL,
	CONSTRAINT srv_labelconfig_pkey PRIMARY KEY (row_id)
);
