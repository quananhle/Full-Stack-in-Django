-- Drop table

-- DROP TABLE public.mfg_maskmodelattributes;

CREATE TABLE public.mfg_maskmodelattributes (
	row_id int4 NOT NULL DEFAULT nextval('mfg_maskmodelattributes_mask_id_seq'::regclass),
	mask_id serial4 NOT NULL,
	model_id varchar NOT NULL,
	create_by varchar NOT NULL,
	create_date timestamptz NOT NULL DEFAULT now(),
	last_edit_by varchar NULL,
	last_edit_date timestamptz NULL,
	CONSTRAINT mfg_maskmodelattributes_pk PRIMARY KEY (row_id),
	CONSTRAINT mfg_maskmodelattributes_fk FOREIGN KEY (mask_id) REFERENCES public.mfg_mask(mask_id),
	CONSTRAINT mfg_maskmodelattributes_fk_1 FOREIGN KEY (model_id) REFERENCES public.mfg_materialmaster(model_id)
);
