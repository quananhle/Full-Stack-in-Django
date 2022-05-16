-- Drop table

-- DROP TABLE public.mfg_productversion;

CREATE TABLE public.mfg_productversion (
	prod_version_id varchar(255) NOT NULL,
	prod_version_description varchar(255) NOT NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	CONSTRAINT mfg_productversion_pkey PRIMARY KEY (prod_version_id)
);
CREATE INDEX mfg_productversion_prod_version_id_68a7e61f_like ON public.mfg_productversion USING btree (prod_version_id varchar_pattern_ops);
