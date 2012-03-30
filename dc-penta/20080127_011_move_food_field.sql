-- Move food_id column
 -- Add new column
 ALTER TABLE base.dc_conference_person ADD COLUMN food_id INTEGER;
 
 -- Add constraint
 ALTER TABLE debconf.dc_conference_person ADD CONSTRAINT dc_conference_person_food_id FOREIGN KEY (food_id) REFERENCES debconf.dc_food_preferences(food_id);
 -- Move data
 UPDATE debconf.dc_conference_person SET food_id = debconf.dc_person.food_id FROM debconf.dc_person WHERE conference_id = 1 AND debconf.dc_conference_person.person_id = debconf.dc_person.person_id;
 -- Drop old column
 ALTER TABLE base.dc_person DROP COLUMN food_id;

-- Update logging routines
SELECT * FROM log.activate_logging();
