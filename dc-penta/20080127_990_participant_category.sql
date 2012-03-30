-- Add some new tables

CREATE TABLE base.dc_participant_category (
    category_id integer NOT NULL,
    category TEXT
);

-- Add the public tables
CREATE TABLE debconf.dc_participant_category (
) INHERITS (base.dc_participant_category);

-- Add the constraints (these go on the public tables, not the base ones)
ALTER TABLE ONLY debconf.dc_participant_category
    ADD CONSTRAINT dc_participant_category_category_id_pkey PRIMARY KEY (category_id);

-- And the logging tables
CREATE TABLE log.dc_participant_category (
) INHERITS (base.logging, base.dc_participant_category);

-- Add a new field to conference_person
ALTER TABLE base.dc_conference_person ADD COLUMN participant_category_id INTEGER;

-- And the constraint
ALTER TABLE debconf.dc_conference_person ADD CONSTRAINT dc_conference_person_participant_category_id FOREIGN KEY (participant_category_id) REFERENCES debconf.dc_participant_category(category_id);

-- Initialize the logging tables
SELECT * FROM log.activate_logging();

-- Recreate views
CREATE VIEW debconf.view_dc_participant_category AS
  SELECT dc_participant_category.category_id, dc_participant_category.category FROM debconf.dc_participant_category;

INSERT INTO debconf.dc_participant_category (category_id, category) VALUES (1, 'Independent');
INSERT INTO debconf.dc_participant_category (category_id, category) VALUES (2, 'Professional (250 USD per week)');
INSERT INTO debconf.dc_participant_category (category_id, category) VALUES (3, 'Corporate (1000 USD per week)');


ALTER TABLE base.dc_participant_category OWNER TO pentabarf;
ALTER TABLE log.dc_participant_category OWNER TO pentabarf;
ALTER TABLE debconf.dc_participant_category OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_participant_category OWNER TO pentabarf;
ALTER FUNCTION log.dc_participant_category_log_function() OWNER TO pentabarf;


