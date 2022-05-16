-- Drop table

-- DROP TABLE public.mfg_maskmodels;

CREATE TABLE public.mfg_maskmodels (
	row_id int4 NOT NULL DEFAULT nextval('mfg_maskmodels_mask_id_seq'::regclass),
	mask_rule varchar(50) NOT NULL,
	create_by varchar(20) NULL,
	create_date timestamptz NOT NULL,
	last_edit_by varchar(20) NULL,
	last_edit timestamptz NULL,
	model_id varchar(100) NULL,
	CONSTRAINT mfg_maskmodels_pkey PRIMARY KEY (row_id),
	CONSTRAINT mfg_maskmodels_model_id_fb8f6967_fk_mfg_materialmaster_model_id FOREIGN KEY (model_id) REFERENCES public.mfg_materialmaster(model_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_maskmodels_model_id_id_4710b521 ON public.mfg_maskmodels USING btree (model_id);
CREATE INDEX mfg_maskmodels_model_id_id_4710b521_like ON public.mfg_maskmodels USING btree (model_id varchar_pattern_ops);
