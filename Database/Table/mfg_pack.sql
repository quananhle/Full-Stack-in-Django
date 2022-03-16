-- Drop table

-- DROP TABLE public.mfg_pack;

CREATE TABLE public.mfg_pack (
	pack_id varchar(100) NOT NULL,
	pack_type varchar(15) NOT NULL,
	status int4 NOT NULL DEFAULT 0,
	print_label varchar(50) NULL,
	country_kit varchar(50) NULL,
	quantity int4 NULL,
	last_edit_by varchar(50) NULL,
	last_edit timestamptz NOT NULL,
	CONSTRAINT mfg_pack_pkey PRIMARY KEY (pack_id)
);
CREATE INDEX mfg_pack_pack_id_58e8fe46_like ON public.mfg_pack USING btree (pack_id varchar_pattern_ops);
