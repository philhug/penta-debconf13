CREATE TABLE debconf.person_type AS SELECT * FROM public.person_type;

ALTER TABLE debconf.person_type ADD CONSTRAINT person_type_person_type_id_key PRIMARY KEY(person_type_id);

DROP VIEW public.view_person_type;

CREATE VIEW debconf.view_person_type AS
  SELECT debconf.person_type.person_type_id, debconf.person_type.description FROM debconf.person_type;
  
ALTER TABLE debconf.person DROP CONSTRAINT person_person_type_id_fkey;

ALTER TABLE debconf.person ADD CONSTRAINT person_person_type_id_fkey FOREIGN KEY (person_type_id) REFERENCES debconf.person_type(person_type_id);

DROP TABLE  public.person_type;

