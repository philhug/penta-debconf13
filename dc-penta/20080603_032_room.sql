BEGIN;

-- Add new column
ALTER TABLE base.dc_conference_person ADD COLUMN room_preference TEXT;

-- Update logging routines
SELECT * FROM log.activate_logging();


COMMIT;

BEGIN;

INSERT INTO debconf.dc_participant_category (participant_category_id, participant_category) VALUES (5, 'Non-Hosted Independent');

INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Debian Developer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-DD maintainer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-maintainer but interested'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Accompanying'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Organizer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Press'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Sponsor'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Non-Hosted Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Volunteer'));

COMMIT;
