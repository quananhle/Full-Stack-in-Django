-- Drop table

-- DROP TABLE public.mfg_serializationrule;

CREATE TABLE public.mfg_serializationrule (
	rule_id serial4 NOT NULL,
	rule_type varchar(20) NULL,
	rule_length int4 NOT NULL,
	start_sequence int4 NOT NULL,
	current_sequence int4 NOT NULL,
	create_date timestamptz NULL,
	create_by varchar(100) NULL,
	last_edit_by varchar(100) NULL,
	last_edit_date timestamptz NULL,
	CONSTRAINT mfg_serializationrule_pkey PRIMARY KEY (rule_id)
);
