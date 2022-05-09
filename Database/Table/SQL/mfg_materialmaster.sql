-- Drop table

-- DROP TABLE public.mfg_materialmaster;

CREATE TABLE public.mfg_materialmaster (
	model_id varchar(100) NOT NULL,
	plant_code varchar(50) NOT NULL,
	material_group varchar(50) NOT NULL,
	material_type varchar(50) NOT NULL,
	model_desc text NOT NULL,
	manufacturer_pn varchar(100) NULL,
	alternative_pn text NULL,
	measure_unit varchar(10) NOT NULL,
	dimension_unit varchar(10) NOT NULL,
	build_type varchar(100) NULL,
	part_type varchar(100) NULL,
	manufacturer varchar(100) NULL,
	sap_create_date timestamptz NULL,
	sap_change_date timestamptz NULL,
	sap_change_time time NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	volume_unit varchar(100) NULL,
	weight_unit varchar(100) NULL,
	customer varchar(100) NULL,
	customer_pn varchar(100) NULL,
	project varchar(100) NULL,
	keypart int4 NULL,
	mask_rule varchar(100) NULL,
	unit_price numeric(12, 2) NULL,
	category_id varchar(100) NULL,
	revision varchar(30) NULL,
	CONSTRAINT mfg_materialmaster_model_id_0ac921c2_pk PRIMARY KEY (model_id),
	CONSTRAINT mfg_materialmaster_model_id_0ac921c2_uniq UNIQUE (model_id),
	CONSTRAINT mfg_materialmaster_category_id_cbf1c25d_fk_mfg_scanc FOREIGN KEY (category_id) REFERENCES public.mfg_scancategory(category_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX "mfg_materialmaster_Scan Category_d7f6040d" ON public.mfg_materialmaster USING btree (category_id);
CREATE INDEX mfg_materialmaster_model_id_0ac921c2_like ON public.mfg_materialmaster USING btree (model_id varchar_pattern_ops);
