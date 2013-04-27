BEGIN TRANSACTION;

DROP VIEW debconf.view_dc_accomodation;
DROP VIEW debconf.dc_view_participant_changes;
DROP VIEW debconf.dc_view_numbers;
DROP VIEW debconf.dc_view_find_person;
DROP VIEW debconf.dc_view_participant;

--- sigh, why character varying?

ALTER TABLE base.dc_accomodation ALTER COLUMN accom TYPE varchar(120);
ALTER TABLE base.dc_debconf_role ADD conference_id INTEGER NOT NULL DEFAULT 6;
ALTER TABLE base.dc_conference_person ADD debconfbenefit text;
ALTER TABLE base.dc_conference_person ADD whyrequest text;

CREATE VIEW debconf.view_dc_accomodation AS
    SELECT debconf.dc_accomodation.accom_id, debconf.dc_accomodation.accom FROM debconf.dc_accomodation;

CREATE VIEW debconf.dc_view_numbers AS
  SELECT p.person_id AS id, COALESCE(p.public_name, ((COALESCE(p.first_name || ' '::text, ''::text) || p.last_name)::character varying)::text, p.nickname) AS name,
        p.nickname AS nick,
        p.city,
        p.email,
        ( SELECT country_localized.name
           FROM country_localized
          WHERE p.country = country_localized.country AND country_localized.translated = 'en'::text) AS country,
        dcpt.description AS status,
	ddr.description AS role_in_debian,
	ddcr.description AS role_in_debconf,
        dca.accom,
        dca.accom_id,
        dccp.attend,
        dcvpm.participant_category,
        dcd.debcamp_option AS debcamp,
        dccp.debcamp_reason,
        dcfp.food,
        dcfp.food_id,
        dctss.t_shirt_size,
        cpt.arrival_from,
        dccp.travel_to_venue,
        dccp.travel_from_venue,
        cpt.arrival_date,
        cpt.departure_date,
        cpt.arrival_time,
        cpt.departure_time,
        cpt.travel_cost AS total_cost,
        cpt.travel_currency AS total_cost_currency,
        cpt.fee AS cantfund,
        cpt.fee_currency AS cantfund_currency,
        date_part('days'::text, age(cpt.arrival_date::timestamp with time zone, cpt.departure_date::timestamp with time zone)) AS days,
        cp.reconfirmed
   FROM person p
   JOIN conference_person cp USING (person_id)
   JOIN debconf.dc_conference_person dccp USING (person_id)
   LEFT JOIN debconf.dc_person_type dcpt USING (person_type_id) -- Will be empty, but we don't want to break existing code
   JOIN debconf.dc_debian_role ddr USING (debian_role_id)
   JOIN debconf.dc_debconf_role ddcr USING (debconf_role_id)
   JOIN debconf.dc_accomodation dca USING (accom_id)
   JOIN conference_person_travel cpt USING (conference_person_id)
   LEFT JOIN debconf.dc_view_participant_map dcvpm ON dccp.dc_participant_category_id = dcvpm.participant_mapping_id
   JOIN debconf.dc_debcamp dcd USING (debcamp_id)
   JOIN debconf.dc_food_preferences dcfp USING (food_id)
   JOIN debconf.dc_t_shirt_sizes dctss USING (t_shirt_sizes_id)
  WHERE cp.conference_id = 7 AND dccp.conference_id = 7;

CREATE VIEW debconf.dc_view_participant_changes AS
 SELECT llt.log_transaction_id, llt.log_timestamp, ldccp.attend,
    llt.person_id AS actor_id,
    ( SELECT dcvn.name FROM debconf.dc_view_numbers dcvn WHERE dcvn.id = llt.person_id)
      AS actor_name,
    lcp.person_id, dcvn.name, dcvpm.participant_category, dcfp.food, dca.accom,
    lcpt.need_travel_cost, lcpt.travel_cost, lcpt.travel_currency, lcpt.fee,
    lcpt.fee_currency, lcp.reconfirmed, ldccp.room_preference, lcp.arrived
   FROM log.log_transaction llt
     JOIN log.conference_person lcp ON lcp.log_transaction_id = llt.log_transaction_id
     LEFT JOIN debconf.dc_view_numbers dcvn ON lcp.person_id = dcvn.id
     FULL JOIN log.dc_conference_person ldccp ON ldccp.log_transaction_id = llt.log_transaction_id
     FULL JOIN debconf.dc_view_participant_map dcvpm ON ldccp.dc_participant_category_id = dcvpm.participant_mapping_id
     FULL JOIN debconf.dc_food_preferences dcfp ON ldccp.food_id = dcfp.food_id AND ldccp.conference_id = dcfp.conference_id
     FULL JOIN debconf.dc_accomodation dca ON ldccp.accom_id = dca.accom_id AND ldccp.conference_id = dca.conference_id
     FULL JOIN log.conference_person_travel lcpt ON lcpt.log_transaction_id = llt.log_transaction_id
  WHERE llt.log_timestamp >= '2013-01-01 00:00:00'::timestamp without time zone
  ORDER BY llt.log_timestamp;

CREATE OR REPLACE VIEW debconf.dc_view_find_person AS
 SELECT view_find_person.person_id,
        view_find_person.name,
	view_find_person.first_name,
	view_find_person.last_name,
	view_find_person.nickname,
	view_find_person.public_name,
	view_find_person.email,
	view_find_person.gender,
	view_find_person.country,
	view_find_person.mime_type,
	view_find_person.file_extension,
	view_find_person.conference_id,
	view_find_person.arrived,
	view_find_person.event_role,
	view_find_person.role,
	conference_person.reconfirmed,
	dc_conference_person.attend,
	dc_accomodation.accom,
	dc_debcamp.debcamp_option,
	dc_view_participant_map.person_type,
	debconf.dc_debconf_role.description AS debconf_role,
	debconf.dc_debian_role.description AS debian_role,
	dc_view_participant_map.participant_category,
	dc_food_preferences.food
   FROM view_find_person
        LEFT JOIN conference_person USING (person_id, conference_id)
   	LEFT JOIN debconf.dc_conference_person USING (person_id, conference_id)
   	LEFT JOIN debconf.dc_person USING (person_id)
   	LEFT JOIN debconf.dc_person_type USING (person_type_id)
   	LEFT JOIN (SELECT participant_category_id, participant_category FROM debconf.dc_participant_category) AS dcpc
	     ON dc_conference_person.dc_participant_category_id = dcpc.participant_category_id
   	LEFT JOIN debconf.dc_view_participant_map
	     ON dc_view_participant_map.participant_mapping_id = dc_conference_person.dc_participant_category_id
   	LEFT JOIN debconf.dc_debcamp USING (debcamp_id)
   	LEFT JOIN debconf.dc_accomodation USING (accom_id, conference_id)
   	LEFT JOIN debconf.dc_food_preferences USING (food_id)
	LEFT JOIN debconf.dc_debian_role USING (debian_role_id)
	LEFT JOIN debconf.dc_debconf_role USING (debconf_role_id)
  ORDER BY view_find_person.name, view_find_person.person_id;

  GRANT SELECT ON debconf.dc_view_participant_changes TO readonly;
GRANT SELECT ON debconf.dc_view_numbers TO readonly;
GRANT SELECT ON debconf.dc_view_find_person TO readonly;



-- conference_id 7 means DC13 (Switzerland)
DELETE FROM debconf.dc_participant_mapping WHERE
       participant_category_id IN (SELECT participant_category_id FROM debconf.dc_participant_category WHERE conference_id = 7);
DELETE FROM debconf.dc_participant_category WHERE conference_id = 7;
DELETE FROM debconf.dc_accomodation WHERE conference_id = 7;
DELETE FROM debconf.dc_food_preferences WHERE conference_id = 7;

INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (25, 7, ' --- Please select one --- ');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (26, 7, 'Basic registration (free)');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (27, 7, 'Professional registration (200 CHF)');
INSERT INTO debconf.dc_participant_category (participant_category_id, conference_id, participant_category) VALUES (28, 7, 'Corporate registration (500 CHF)');

INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (20, 7, ' --- Please select one --- ');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (21, 7, 'I will arrange my own accomodation off-site (no fee)');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (22, 7, 'I request sponsored accommodation (Not for Professional/Corporate)');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (23, 7, 'self-paid communal accommodation (20 CHF/day) ');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (24, 7, 'self-paid camping (camper van or tent; 20 CHF/day, limited availability) ');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (25, 7, 'self-paid accommodation in room with up to 8 beds (30 CHF/day) ');
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (26, 7, 'self-paid accommodation in room with 2 beds (40 CHF/day/person, only for Professional/Corporate)');


INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (43, 7, ' --- Please select one --- ');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (44, 7, 'No dietary restrictions');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (45, 7, 'Vegetarian');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (46, 7, 'Vegan (strict vegetarian)');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (47, 7, 'Other (contact organizers)');
INSERT INTO debconf.dc_food_preferences (food_id, conference_id, food) VALUES (48, 7, 'Not eating with the group ');

INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (10, ' --- Please select one --- ', 7);
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (11, 'Regular attendee', 7);
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (12, 'Organizer', 7);
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (13, 'Volunteer', 7);
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (14, 'Sponsor', 7);
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (15, 'Press', 7);
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (16, 'Accompanying a DebConf participant', 7);
INSERT INTO debconf.dc_debconf_role (debconf_role_id, description, conference_id) VALUES (17, 'None', 7);


--- please select one
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (25, 11);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (25, 12);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (25, 13);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (25, 14);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (25, 15);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (25, 16);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (25, 17);

--- basic (free)
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (26, 11);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (26, 12);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (26, 13);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (26, 14);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (26, 15);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (26, 16);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (26, 17);

--- professional
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (27, 11);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (27, 12);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (27, 13);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (27, 14);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (27, 15);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (27, 16);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (27, 17);

--- corporate
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (28, 11);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (28, 12);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (28, 13);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (28, 14);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (28, 15);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (28, 16);
INSERT INTO debconf.dc_participant_mapping (participant_category_id, debconf_role_id) VALUES (28, 17);

CREATE VIEW debconf.dc_view_participant AS
       SELECT dc_participant_mapping.participant_category_id,
       	      dc_participant_mapping.participant_mapping_id,
	      dc_participant_mapping.person_type_id,
	      dc_participant_mapping.debconf_role_id,
	      dc_participant_category.participant_category,
	      dc_participant_category.conference_id
       FROM debconf.dc_participant_mapping
       JOIN debconf.dc_participant_category USING (participant_category_id)
       ORDER BY dc_participant_mapping.person_type_id,
       	      dc_participant_mapping.participant_category_id;


ALTER TABLE base.dc_conference_person ADD COLUMN debcampdc13 boolean NOT NULL DEFAULT FALSE;
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::debcampdc13', 'en', 'I would attend DebCamp if it was held');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::debcampdc13', 'de', 'Wenn DebCamp stattfindet nehme ich teil.');

ALTER TABLE base.dc_conference_person ADD COLUMN camping boolean NOT NULL DEFAULT FALSE;
INSERT INTO ui_message(ui_message) VALUES ('table::dc_conference_person::camping');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::camping', 'en', 'I prefer camping (in my own tent) over communal accommodation if possible');

ALTER TABLE base.dc_conference_person ADD COLUMN com_accom boolean;
INSERT INTO ui_message(ui_message) VALUES ('table::dc_conference_person::com_accom');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::com_accom', 'en', 'I will accept sponsored communal accommodation (12 or more beds per room)');


-- Create/modify base tables
CREATE TABLE base.dc_food_select (
  food_select_id integer NOT NULL,
  description text UNIQUE
);

ALTER TABLE base.dc_conference_person ADD COLUMN food_select integer;

-- Add the public tables
CREATE TABLE debconf.dc_food_select () INHERITS (base.dc_food_select);

-- Add the constraints on the public tables
ALTER TABLE ONLY debconf.dc_food_select
  ADD CONSTRAINT dc_food_select_id_pkey PRIMARY KEY (food_select_id);
ALTER TABLE ONLY debconf.dc_conference_person
  ADD CONSTRAINT dc_conference_person_food_select_id_fkey
  FOREIGN KEY (food_select_id)
  REFERENCES debconf.dc_food_select(food_select_id);

-- Add the logging tables
CREATE TABLE log.dc_food_select () INHERITS (base.logging, base.dc_food_select);

INSERT INTO debconf.dc_food_select(food_select_id, description) VALUES (1, 'I wish to pay for food at the conference (25 CHF/day)');
INSERT INTO debconf.dc_food_select(food_select_id, description) VALUES (2, 'I request sponsored food');
INSERT INTO debconf.dc_food_select(food_select_id, description) VALUES (3, 'I will care for my own food and understand that there are no shops or restaurants nearby.');

INSERT INTO ui_message(ui_message) VALUES ('table::dc_conference_person::food_select');
UPDATE ui_message_localized SET name='Food preferences' WHERE name='Food';
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::food_select', 'en', 'Food');

UPDATE ui_message_localized SET name='Full Name (for e.g. badges)' WHERE ui_message='table::person::public_name' AND translated='en';
UPDATE ui_message_localized SET name='Nome Completo' WHERE ui_message='table::person::public_name' AND translated='pt_BR';


INSERT INTO ui_message(ui_message) VALUES ('table::dc_conference_person::food_select');
UPDATE ui_message_localized SET name='Food preferences' WHERE name='Food';
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::food_select', 'en', 'Food');

INSERT INTO ui_message(ui_message) VALUES ('table::dc_conference_person::debconfbenefit');
INSERT INTO ui_message(ui_message) VALUES ('table::dc_conference_person::whyrequest');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::debconfbenefit', 'en', 'How will your attending this DebConf benefit Debian?');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::whyrequest', 'en', 'Why do you request help paying for your costs?');

SELECT log.activate_logging();

COMMIT TRANSACTION;
