BEGIN;

/* we need food options */
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (18, 'Regular, I (or my company) will pay', 3);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (19, 'Vegetarian, I (or my company) will pay', 3);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (20, 'Vegan (strict vegetarian), I (or my company) will pay', 3);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (21, 'Other (contact organizers), I (or my company) will pay', 3);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (22, 'Regular, I need food sponsorship', 3);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (23, 'Vegetarian, I need food sponsorship', 3);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (24, 'Vegan (strict vegetarian), I need food sponsorship', 3);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (25, 'Other (contact organizers), I need food sponsorship', 3);

/* and some for the accommodation */

INSERT INTO debconf.dc_accomodation (accom_id, accom, conference_id) VALUES (10, 'Regular Room', 3);
INSERT INTO debconf.dc_accomodation (accom_id, accom, conference_id) VALUES (11, 'I will arrange my own accommodation', 3);


COMMIT;
