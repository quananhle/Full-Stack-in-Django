-- Drop table

-- DROP TABLE public.sadmin_syscontrolvalues;

CREATE TABLE public.sadmin_syscontrolvalues (
	row_id serial4 NOT NULL,
	control_name varchar(255) NULL,
	control_value varchar(255) NULL,
	control_description varchar(100) NULL,
	control_type varchar(50) NULL,
	creator varchar(50) NULL,
	create_date timestamptz NULL,
	last_update_by varchar(50) NULL,
	last_update timestamptz NULL,
	CONSTRAINT sadmin_syscontrolvalues_pkey PRIMARY KEY (row_id)
);
