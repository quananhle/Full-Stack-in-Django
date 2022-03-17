-- Drop table

-- DROP TABLE public.mfg_auditsortedtracking;

CREATE TABLE public.mfg_auditsortedtracking (
	row_id serial4 NOT NULL,
	value varchar(100) NULL,
	total int4 NULL,
	counter int4 NULL,
	last_edit_by varchar(100) NULL,
	last_edit_date timestamptz NULL,
	validated_sn text NULL,
	CONSTRAINT mfg_auditsortedtracking_pkey PRIMARY KEY (row_id)
);
