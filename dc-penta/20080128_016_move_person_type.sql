BEGIN;
-- Move person_type_id column
 -- Add new column
 ALTER TABLE base.dc_conference_person ADD COLUMN person_type_id INTEGER;
 
 -- Add constraint
 ALTER TABLE debconf.dc_conference_person ADD CONSTRAINT dc_conference_person_person_type_id FOREIGN KEY (person_type_id) REFERENCES debconf.dc_person_type(person_type_id);
 -- Move data
 UPDATE debconf.dc_conference_person SET person_type_id = debconf.dc_person.person_type_id FROM debconf.dc_person WHERE conference_id = 1 AND debconf.dc_conference_person.person_id = debconf.dc_person.person_id;
 -- Drop old column
 ALTER TABLE base.dc_person DROP COLUMN person_type_id;

-- Update logging routines
SELECT * FROM log.activate_logging();

COMMIT;
