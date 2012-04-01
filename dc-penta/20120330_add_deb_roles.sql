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
  REFERENCES debconf.dc_debconf_role(debconf_role_id);
ALTER TABLE ONLY debconf.dc_participant_mapping
  ADD CHECK ((person_type_id IS NOT NULL) OR (debconf_role_id IS NOT NULL));

-- Add the logging tables
CREATE TABLE log.dc_debian_role () INHERITS (base.logging, base.dc_debian_role);
CREATE TABLE log.dc_debconf_role () INHERITS (base.logging, base.dc_debconf_role);

-- Insert the data
--
-- conference_id 6 means DC12 (Managua)
DELETE FROM debconf.dc_participant_category WHERE conference_id = 6;
DELETE FROM debconf.dc_accomodation WHERE conference_id = 6;
DELETE FROM debconf.dc_food_preferences WHERE conference_id = 6;
DELETE FROM debconf.dc_debian_role;
DELETE FROM debconf.dc_debconf_role;

INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, ' --- Please select one --- ');
INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, 'Basic; no sponsored food or accommodation');
INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, 'Basic; want sponsored accommodation');
INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, 'Basic; want sponsored food');
INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, 'Basic; want sponsored food and accommodation');
INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, 'Sponsored registration');
INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, 'Professional registration (US$???)');
INSERT INTO debconf.dc_participant_category (conference_id, participant_category) VALUES (6, 'Corporate registration (US$???)');

INSERT INTO debconf.dc_food_preferences (conference_id, food) VALUES (6, ' --- Please select one --- ');
INSERT INTO debconf.dc_food_preferences (conference_id, food) VALUES (6, 'No dietary restrictions');
INSERT INTO debconf.dc_food_preferences (conference_id, food) VALUES (6, 'Vegetarian');
INSERT INTO debconf.dc_food_preferences (conference_id, food) VALUES (6, 'Vegan (strict vegetarian)');
INSERT INTO debconf.dc_food_preferences (conference_id, food) VALUES (6, 'Other (contact organizers)');
INSERT INTO debconf.dc_food_preferences (conference_id, food) VALUES (6, 'Not eating with the group ');

INSERT INTO debconf.dc_accomodation (conference_id, accom) VALUES (6, ' --- Please select one --- ');
INSERT INTO debconf.dc_accomodation (conference_id, accom) VALUES (6, 'Regular room');
INSERT INTO debconf.dc_accomodation (conference_id, accom) VALUES (6, 'I will arrange my own accomodation');

INSERT INTO debconf.dc_debian_role (description) VALUES ('Debian Developer');
INSERT INTO debconf.dc_debian_role (description) VALUES ('Debian Developer (non-uploading)');
INSERT INTO debconf.dc_debian_role (description) VALUES ('Debian Maintainer');
INSERT INTO debconf.dc_debian_role (description) VALUES ('Otherwise involved in Debian');
INSERT INTO debconf.dc_debian_role (description) VALUES ('Not yet involved but interested');
INSERT INTO debconf.dc_debian_role (description) VALUES ('Accompanying a Debian participant');
INSERT INTO debconf.dc_debian_role (description) VALUES ('None');

INSERT INTO debconf.dc_debconf_role (description) VALUES ('Regular attendee');
INSERT INTO debconf.dc_debconf_role (description) VALUES ('Organizer');
INSERT INTO debconf.dc_debconf_role (description) VALUES ('Volunteer');
INSERT INTO debconf.dc_debconf_role (description) VALUES ('Sponsor');
INSERT INTO debconf.dc_debconf_role (description) VALUES ('Press');
INSERT INTO debconf.dc_debconf_role (description) VALUES ('Accompanying a DebConf participant');
INSERT INTO debconf.dc_debconf_role (description) VALUES ('None');

-- ...And given we don't yet know the IDs we will get, we cannot
-- preload into debconf.dc_participant_mapping. That should be done by
-- hand, sorry!

COMMIT TRANSACTION;
