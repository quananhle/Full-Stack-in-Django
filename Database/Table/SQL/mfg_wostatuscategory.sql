-- Drop table

-- DROP TABLE public.mfg_wostatuscategory;

CREATE TABLE public.mfg_wostatuscategory (
	status_id int4 NOT NULL,
	"name" varchar(50) NOT NULL,
	description varchar(255) NULL,
	seq_no int4 NULL,
	last_update timestamptz NOT NULL,
	last_update_by varchar(50) NULL,
	CONSTRAINT mfg_wostatuscategory_pkey PRIMARY KEY (status_id)
);
