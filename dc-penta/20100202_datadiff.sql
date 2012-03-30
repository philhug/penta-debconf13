BEGIN;

INSERT INTO debconf.dc_accomodation
(accom_id, accom, conference_id)
VALUES
(13, 'I will arrange my own accommodation', 4);



INSERT INTO debconf.dc_accomodation
(accom_id, accom, conference_id)
VALUES
(12, 'On-campus room', 4);



UPDATE debconf.dc_debcamp
   SET debcamp_option = 'I don''t have a specific plan for DebCamp (week payment (650 USD) required)'
  WHERE debcamp_id = 3;



INSERT INTO debconf.dc_food_preferences
(food_id, food, conference_id)
VALUES
(29, 'Other (contact organizers)', 4);



INSERT INTO debconf.dc_food_preferences
(food_id, food, conference_id)
VALUES
(30, 'Not eating with the group', 4);



INSERT INTO debconf.dc_food_preferences
(food_id, food, conference_id)
VALUES
(28, 'Vegan (strict vegetarian)', 4);



INSERT INTO debconf.dc_food_preferences
(food_id, food, conference_id)
VALUES
(26, 'No dietary restrictions', 4);



INSERT INTO debconf.dc_food_preferences
(food_id, food, conference_id)
VALUES
(27, 'Vegetarian', 4);



INSERT INTO debconf.dc_participant_category
(participant_category_id, participant_category, conference_id)
VALUES
(7, 'Basic; want sponsored food and accommodation', 4);



INSERT INTO debconf.dc_participant_category
(participant_category_id, participant_category, conference_id)
VALUES
(8, 'Basic; want sponsored food', 4);



INSERT INTO debconf.dc_participant_category
(participant_category_id, participant_category, conference_id)
VALUES
(9, 'Basic; want sponsored accommodation', 4);



INSERT INTO debconf.dc_participant_category
(participant_category_id, participant_category, conference_id)
VALUES
(10, 'Basic; no sponsored food or accommodation', 4);



INSERT INTO debconf.dc_participant_category
(participant_category_id, participant_category, conference_id)
VALUES
(11, 'Professional (650 USD per full or partial week)', 4);



INSERT INTO debconf.dc_participant_category
(participant_category_id, participant_category, conference_id)
VALUES
(12, 'Corporate (1300 USD per full or partial week)', 4);



UPDATE debconf.dc_participant_category
   SET conference_id = 4
  WHERE participant_category_id = 0;



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(58, 7, 1);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(59, 7, 2);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(60, 7, 3);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(61, 7, 5);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(62, 7, 6);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(66, 8, 1);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(67, 8, 2);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(68, 8, 3);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(69, 8, 5);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(70, 8, 6);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(71, 9, 1);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(72, 9, 2);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(73, 9, 3);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(74, 9, 5);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(75, 9, 6);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(76, 10, 1);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(77, 10, 2);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(78, 10, 3);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(79, 10, 5);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(80, 10, 6);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(81, 11, 1);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(82, 11, 2);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(83, 11, 3);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(84, 11, 4);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(85, 11, 5);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(86, 11, 6);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(87, 11, 7);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(88, 11, 8);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(89, 12, 1);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(90, 12, 2);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(91, 12, 3);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(92, 12, 4);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(93, 12, 5);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(94, 12, 6);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(95, 12, 7);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(96, 12, 8);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(97, 0, 0);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(98, 10, 4);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(99, 10, 7);



INSERT INTO debconf.dc_participant_mapping
(participant_mapping_id, participant_category_id, person_type_id)
VALUES
(100, 10, 8);



UPDATE debconf.dc_person_type
   SET description = 'Otherwise involved in Debian'
  WHERE person_type_id = 2;



UPDATE debconf.dc_person_type
   SET description = 'Not yet involved but interested'
  WHERE person_type_id = 3;



UPDATE debconf.dc_person_type
   SET description = 'Accompanying a Debian participant'
  WHERE person_type_id = 4;



UPDATE debconf.dc_person_type
   SET description = 'DebConf Organizer'
  WHERE person_type_id = 5;



UPDATE debconf.dc_person_type
   SET description = 'DebConf Volunteer'
  WHERE person_type_id = 6;



UPDATE ui_message_localized
   SET name = 'City (& state/province where applicable)'
  WHERE name = 'City of residence';



UPDATE ui_message_localized
   SET name = 'Country'
  WHERE name = 'Country of residence';

COMMIT;
