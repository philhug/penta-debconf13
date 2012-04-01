BEGIN TRANSACTION;

-- Create/modify base tables
CREATE TABLE base.dc_debian_role (
  debian_role_id integer NOT NULL,
  description text UNIQUE
);
CREATE TABLE base.dc_debconf_role (
  debconf_role_id integer NOT NULL,
  description text UNIQUE
);
ALTER TABLE base.dc_participant_mapping ALTER COLUMN person_type_id DROP NOT NULL;
ALTER TABLE base.dc_participant_mapping ADD COLUMN debconf_role_id integer;
ALTER TABLE base.dc_conference_person ADD COLUMN debconf_role_id integer;
ALTER TABLE base.dc_conference_person ADD COLUMN debian_role_id integer;

-- Add the public tables
CREATE TABLE debconf.dc_debian_role () INHERITS (base.dc_debian_role);
CREATE TABLE debconf.dc_debconf_role () INHERITS (base.dc_debconf_role);

-- Add the constraints on the public tables
ALTER TABLE ONLY debconf.dc_debian_role
  ADD CONSTRAINT dc_debian_role_id_pkey PRIMARY KEY (debian_role_id);
ALTER TABLE ONLY debconf.dc_debconf_role
  ADD CONSTRAINT dc_debconf_role_id_pkey PRIMARY KEY (debconf_role_id);
ALTER TABLE ONLY debconf.dc_participant_mapping
  ADD CONSTRAINT dc_participant_mapping_debconf_role_id_fkey
  FOREIGN KEY (debconf_role_id)
  REFERENCES debconf.dc_debconf_role(debconf_role_id);
ALTER TABLE ONLY debconf.dc_conference_person
  ADD CONSTRAINT dc_conference_person_debian_role_id_fkey
  FOREIGN KEY (debian_role_id)
  REFERENCES debconf.dc_debian_role(debian_role_id);
ALTER TABLE ONLY debconf.dc_conference_person
  ADD CONSTRAINT dc_conference_person_debconf_role_id_fkey
  FOREIGN KEY (debconf_role_id)
  REFERENCES debconf.dc_debconf_role(debconf_role_id);
ALTER TABLE ONLY debconf.dc_participant_mapping
  ADD CHECK ((person_type_id IS NOT NULL) OR (debconf_role_id IS NOT NULL));

-- Add the logging tables
CREATE TABLE log.dc_debian_role () INHERITS (base.logging, base.dc_debian_role);
CREATE TABLE log.dc_debconf_role () INHERITS (base.logging, base.dc_debconf_role);

-- Adjust debconf.dc_view_participant with the changes (and with DebConf12)
DROP VIEW debconf.dc_view_participant;
CREATE VIEW debconf.dc_view_participant AS
       SELECT dc_participant_mapping.participant_category_id,
       	      dc_participant_mapping.participant_mapping_id,
	      dc_participant_mapping.person_type_id,
	      dc_participant_mapping.debconf_role_id,
	      dc_participant_category.participant_category
       FROM debconf.dc_participant_mapping
       JOIN debconf.dc_participant_category USING (participant_category_id)
       WHERE dc_participant_category.conference_id = 6
       ORDER BY dc_participant_mapping.person_type_id,
       	      dc_participant_mapping.participant_category_id;


-- Insert the data
--
-- conference_id 6 means DC12 (Managua)
DELETE FROM debconf.dc_participant_category WHERE conference_id = 6;
DELETE FROM debconf.dc_accomodation WHERE conference_id = 6;
DELETE FROM debconf.dc_food_preferences WHERE conference_id = 6;
DELETE FROM debconf.dc_debian_role;
DELETE FROM debconf.dc_debconf_role;

INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (18, 6, ' --- Please select one --- ');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (19, 6, 'Basic; no sponsored food or accommodation');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (20, 6, 'Basic; want sponsored accommodation');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (21, 6, 'Basic; want sponsored food');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (22, 6, 'Basic; want sponsored food and accommodation');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (23, 6, 'Professional registration (US$???)');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (24, 6, 'Corporate registration (US$???)');

INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (37, 6, ' --- Please select one --- ');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (38, 6, 'No dietary restrictions');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (39, 6, 'Vegetarian');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (40, 6, 'Vegan (strict vegetarian)');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (41, 6, 'Other (contact organizers)');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (42, 6, 'Not eating with the group ');

INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (17, 6, ' --- Please select one --- ');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (18, 6, 'Regular room');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (19, 6, 'I will arrange my own accomodation');

INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (0, ' --- Please select one --- ');
INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (1, 'Debian Developer');
INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (2, 'Debian Developer (non-uploading)');
INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (3, 'Debian Maintainer');
INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (4, 'Otherwise involved in Debian');
INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (5, 'Not yet involved but interested');
INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (6, 'Accompanying a Debian participant');
INSERT INTO debconf.dc_debian_role (debian_role_id, description) VALUES (7, 'None');

INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (0, ' --- Please select one --- ');
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (1, 'Regular attendee');
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (2, 'Organizer');
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (3, 'Volunteer');
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (4, 'Sponsor');
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (5, 'Press');
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (6, 'Accompanying a DebConf participant');
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description) VALUES (7, 'None');

-- Non-sponsored categories are open for any debconf role
--
-- "Please select one"
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (139, 18, 1);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (140, 18, 2);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (141, 18, 3);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (142, 18, 4);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (143, 18, 5);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (144, 18, 6);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (145, 18, 7);
-- Basic, unsponsored
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (146, 19, 1);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (147, 19, 2);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (148, 19, 3);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (149, 19, 4);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (150, 19, 5);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (151, 19, 6);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (152, 19, 7);
-- Professional
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (153, 23, 1);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (154, 23, 2);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (155, 23, 3);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (156, 23, 4);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (157, 23, 5);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (158, 23, 6);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (159, 23, 7);
-- Corporate
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (160, 24, 1);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (161, 24, 2);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (162, 24, 3);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (163, 24, 4);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (164, 24, 5);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (165, 24, 6);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (166, 24, 7);


-- Regular attendees, organizers and volunteers can get sponsored categories
-- Basic+accomodation
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (167, 20, 1);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (168, 20, 2);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (169, 20, 3);
-- Basic+food
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (170, 21, 1);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (171, 21, 2);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (172, 21, 3);
-- Basic+food+accomodation
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (173, 22, 1);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (174, 22, 2);
INSERT INTO debconf.dc_participant_mapping (participant_mapping_id, participant_category_id, debconf_role_id) VALUES (175, 22, 3);

COMMIT TRANSACTION;
