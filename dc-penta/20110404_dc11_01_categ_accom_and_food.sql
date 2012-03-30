-- log.dc_participant_category is missing a column and aborts any
-- requests - Add it. If this query fails to run, it should not be
-- fatal (say, its effect might already be in place)
BEGIN TRANSACTION;
ALTER TABLE log.dc_participant_category ADD COLUMN conference_id integer;
COMMIT;

-- Replace the debconf.dc_view_participant view to point at the
-- right conference
BEGIN TRANSACTION;
DROP VIEW debconf.dc_view_participant;
CREATE VIEW debconf.dc_view_participant AS
       SELECT dc_participant_mapping.participant_category_id,
       	      dc_participant_mapping.participant_mapping_id,
	      dc_participant_mapping.person_type_id,
	      dc_participant_category.participant_category
       FROM debconf.dc_participant_mapping
       JOIN debconf.dc_participant_category USING (participant_category_id)
       WHERE dc_participant_category.conference_id = 5
       ORDER BY dc_participant_mapping.person_type_id, 
       	      dc_participant_mapping.participant_category_id;
COMMIT;

-- Registration categories
BEGIN TRANSACTION;
DELETE FROM debconf.dc_participant_category WHERE
       conference_id = 5 AND participant_category_id >= 13 AND
       participant_category_id <= 17;
DELETE FROM debconf.dc_participant_mapping WHERE
       participant_category_id >= 13 AND participant_category_id <= 17;

-- Base participant categories
INSERT INTO debconf.dc_participant_category 
       (conference_id, participant_category_id, participant_category) VALUES
       (5, 13, ' --- Please select one --- ');
INSERT INTO debconf.dc_participant_category 
       (conference_id, participant_category_id, participant_category) VALUES
       (5, 14, 'Basic registration (no accommodation provided)');
INSERT INTO debconf.dc_participant_category 
       (conference_id, participant_category_id, participant_category) VALUES
       (5, 15, 'Sponsored registration');
INSERT INTO debconf.dc_participant_category 
       (conference_id, participant_category_id, participant_category) VALUES
       (5, 16, 'Professional registration (€450)');
INSERT INTO debconf.dc_participant_category 
       (conference_id, participant_category_id, participant_category) VALUES
       (5, 17, 'Corporate registration (€1000)');

-- And the mapping between participant categories and person_types -
-- Person_types are already loaded: 
--   0 - Please select
--   1 - DD
--   2 - Otherwise involved
--   3 - Not yet involved but interested
--   4 - Accompanying
--   5 - DebConf Organizer
--   6 - DebConf Volunteer
--   7 - Press
--   8 - Sponsor

-- + Everybody gets to "please select one" (13)
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (0, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (1, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (2, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (3, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (4, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (5, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (6, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (7, 13);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (8, 13);

-- + Basic registration (14): Everybody
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (1, 14);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (2, 14);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (3, 14);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (4, 14);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (5, 14);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (6, 14);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (7, 14);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (8, 14);

-- + Sponsored registration (15): DD, involved, interested, orga, volunteer
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (1, 15);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (2, 15);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (3, 15);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (5, 15);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (6, 15);

-- + Professional registration (16)
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (1, 16);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (2, 16);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (3, 16);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (4, 16);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (5, 16);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (6, 16);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (7, 16);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (8, 16);

-- + Corporate registration (17)
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (1, 17);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (2, 17);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (3, 17);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (4, 17);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (5, 17);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (6, 17);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (7, 17);
INSERT INTO debconf.dc_participant_mapping 
       (person_type_id, participant_category_id) VALUES
       (8, 17);

COMMIT;

-- Accommodation
BEGIN TRANSACTION;
DELETE FROM debconf.dc_accomodation WHERE conference_id = 5 AND
       accom_id >= 14 AND accom_id <= 16;
INSERT INTO debconf.dc_accomodation (conference_id, accom_id, accom) VALUES
       (5, 14, ' --- Please select one --- ');
INSERT INTO debconf.dc_accomodation (conference_id, accom_id, accom) VALUES
       (5, 15, 'Regular room');
INSERT INTO debconf.dc_accomodation (conference_id, accom_id, accom) VALUES
       (5, 16, 'I will arrange my own accomodation');
COMMIT;

-- Food preferences
BEGIN TRANSACTION;
DELETE FROM debconf.dc_food_preferences WHERE conference_id = 5 AND
       food_id >= 31 AND food_id <= 36;
INSERT INTO debconf.dc_food_preferences (conference_id, food_id, food) VALUES
       (5, 31, ' --- Please select one --- ');
INSERT INTO debconf.dc_food_preferences (conference_id, food_id, food) VALUES
       (5, 32, 'No dietary restrictions');
INSERT INTO debconf.dc_food_preferences (conference_id, food_id, food) VALUES
       (5, 33, 'Vegetarian');
INSERT INTO debconf.dc_food_preferences (conference_id, food_id, food) VALUES
       (5, 34, 'Vegan (strict vegetarian)');
INSERT INTO debconf.dc_food_preferences (conference_id, food_id, food) VALUES
       (5, 35, 'Other (contact organizers)');
INSERT INTO debconf.dc_food_preferences (conference_id, food_id, food) VALUES
       (5, 36, 'Not eating with the group');
COMMIT;
