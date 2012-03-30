-- Move proceedings column

 -- Add new column
 ALTER TABLE base.dc_conference_person ADD COLUMN proceedings BOOLEAN;
 -- Move data
 UPDATE debconf.dc_conference_person SET proceedings = debconf.dc_person.f_proceedings FROM debconf.dc_person WHERE conference_id = 1 AND debconf.dc_conference_person.person_id = debconf.dc_person.person_id;
 -- Drop old column
 ALTER TABLE base.dc_person DROP COLUMN f_proceedings;

-- Move t_shirt_sizes column
 -- Add new column
 ALTER TABLE base.dc_conference_person ADD COLUMN t_shirt_sizes_id INTEGER;
 
 -- Add constraint
 ALTER TABLE debconf.dc_conference_person ADD CONSTRAINT dc_conference_person_t_shirt_sizes_id FOREIGN KEY (t_shirt_sizes_id) REFERENCES debconf.dc_t_shirt_sizes(t_shirt_sizes_id);
 -- Move data
 UPDATE debconf.dc_conference_person SET t_shirt_sizes_id = debconf.dc_person.t_shirt_sizes_id FROM debconf.dc_person WHERE conference_id = 1 AND debconf.dc_conference_person.person_id = debconf.dc_person.person_id;
 -- Drop old column
 ALTER TABLE base.dc_person DROP COLUMN t_shirt_sizes_id;

-- Update logging routines
SELECT * FROM log.activate_logging();
