-- Drop table

-- DROP TABLE public.mfg_materialdatarelated;

CREATE TABLE public.mfg_materialdatarelated (
	row_id serial4 NOT NULL,
	spanish_description varchar(255) NULL,
	fracc_nico varchar(100) NULL,
	uom_value varchar(100) NULL,
	uom varchar(100) NULL,
	hst_usa varchar(100) NULL,
	fracc_digits varchar(100) NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	model_id varchar(100) NOT NULL,
	technical_description varchar(255) NULL,
	CONSTRAINT mfg_materialdatarelated_pkey PRIMARY KEY (row_id),
	CONSTRAINT mfg_materialdatarela_model_id_41c71eba_fk_mfg_mater FOREIGN KEY (model_id) REFERENCES public.mfg_materialmaster(model_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_materialdatarelated_model_id_41c71eba ON public.mfg_materialdatarelated USING btree (model_id);
CREATE INDEX mfg_materialdatarelated_model_id_41c71eba_like ON public.mfg_materialdatarelated USING btree (model_id varchar_pattern_ops);
