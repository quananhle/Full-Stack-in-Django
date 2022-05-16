-- Drop table

-- DROP TABLE public.mfg_serializationrulevalues;

CREATE TABLE public.mfg_serializationrulevalues (
	row_id serial4 NOT NULL,
	"sequence" int4 NOT NULL,
	value_name varchar(30) NULL,
	value varchar(50) NULL,
	rule_length int4 NOT NULL,
	start_sequence int4 NOT NULL,
	current_sequence int4 NOT NULL,
	create_date timestamptz NULL,
	rule_id int4 NOT NULL,
	create_by varchar(100) NULL,
	last_edit_by varchar(100) NULL,
	last_edit_date timestamptz NULL,
	CONSTRAINT mfg_serializationrulevalues_pkey PRIMARY KEY (row_id),
	CONSTRAINT mfg_serializationrul_rule_id_037276d5_fk_mfg_seria FOREIGN KEY (rule_id) REFERENCES public.mfg_serializationrule(rule_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_serializationrulevalues_rule_id_037276d5 ON public.mfg_serializationrulevalues USING btree (rule_id);
