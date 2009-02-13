alter table contents rename to parts_data;

alter table parts_data rename id to content_id;
alter table parts_data add id integer;

UPDATE parts_data PD
SET id = p.id
FROM parts P
WHERE P.content_id = PD.content_id;

alter table parts_data drop id;
alter table parts_data rename part_id to id;