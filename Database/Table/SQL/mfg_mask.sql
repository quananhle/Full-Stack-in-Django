-- Drop table

-- DROP TABLE public.mfg_mask;

CREATE TABLE public.mfg_mask (
	mask_id serial4 NOT NULL,
	mask_rule varchar(50) NOT NULL,
	"action" varchar(200) NOT NULL,
	creator varchar(20) NOT NULL,
	create_date timestamptz NOT NULL,
	updater varchar(20) NULL,
	update_date timestamptz NULL,
	mask_length int4 NOT NULL,
	mask_start_sequence int4 NOT NULL,
	mask_current_sequence int4 NOT NULL,
	mask_algorism_value varchar(50) NULL,
	model_id varchar(100) NULL,
	CONSTRAINT mfg_mask_pkey PRIMARY KEY (mask_id),
	CONSTRAINT mfg_mask_model_id_984d734c_fk_mfg_materialmaster_model_id FOREIGN KEY (model_id) REFERENCES public.mfg_materialmaster(model_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_mask_model_id_984d734c ON public.mfg_mask USING btree (model_id);
CREATE INDEX mfg_mask_model_id_984d734c_like ON public.mfg_mask USING btree (model_id varchar_pattern_ops);
