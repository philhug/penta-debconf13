BEGIN TRANSACTION;

--- add new column to dc_food_preferences
ALTER TABLE base.dc_food_preferences ADD COLUMN conference_id integer NOT NULL DEFAULT 1;

--- constraint for it
ALTER TABLE ONLY debconf.dc_food_preferences ADD CONSTRAINT dc_food_preferences_conference_id FOREIGN KEY (conference_id) REFERENCES conference(conference_id);

--- Update logging routines
SELECT * FROM log.activate_logging();

--- Add new preferences
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (11, 'Regular', 2);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (12, 'Vegetarian', 2);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (13, 'Vegan (strict vegetarian)', 2);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (14, 'Lactose-free', 2);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (15, 'Coelic', 2);
INSERT INTO debconf.dc_food_preferences (food_id, food, conference_id) VALUES (16, 'Other', 2);


COMMIT;


