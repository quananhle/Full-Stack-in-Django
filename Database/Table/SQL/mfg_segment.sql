-- Drop table

-- DROP TABLE public.mfg_segment;

CREATE TABLE public.mfg_segment (
	row_id serial4 NOT NULL,
	"name" varchar(30) NOT NULL,
	"action" varchar(200) NOT NULL,
	"position" int4 NOT NULL,
	data_type varchar(20) NOT NULL,
	length int4 NULL,
	value varchar(100) NULL,
	creator varchar(20) NOT NULL,
	create_date timestamptz NOT NULL,
	updater varchar(20) NULL,
	update_date timestamptz NULL,
	mask_id int4 NULL,
	CONSTRAINT mfg_segment_pkey PRIMARY KEY (row_id),
	CONSTRAINT mfg_segment_mask_id_79e8058a_fk_mfg_mask_mask_id FOREIGN KEY (mask_id) REFERENCES public.mfg_mask(mask_id) DEFERRABLE INITIALLY DEFERRED
);
CREATE INDEX mfg_segment_mask_id_79e8058a ON public.mfg_segment USING btree (mask_id);
