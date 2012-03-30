BEGIN TRANSACTION;

CREATE TABLE base.dc_debcamp (
  debcamp_id	SERIAL,
  debcamp_option TEXT
);

-- Add the public tables
CREATE TABLE debconf.dc_debcamp (
) INHERITS (base.dc_debcamp);

-- Add the constraints (these go on the public tables, not the base ones)
ALTER TABLE ONLY debconf.dc_debcamp
    ADD CONSTRAINT dc_debcamp_id_pkey PRIMARY KEY (debcamp_id);

-- And the logging tables
CREATE TABLE log.dc_debcamp (
) INHERITS (base.logging, base.dc_debcamp);

ALTER TABLE base.dc_debcamp OWNER TO pentabarf;
ALTER TABLE log.dc_debcamp OWNER TO pentabarf;
ALTER TABLE debconf.dc_debcamp OWNER TO pentabarf;
ALTER FUNCTION log.dc_debcamp_log_function() OWNER TO pentabarf;

-- Add new column
ALTER TABLE base.dc_conference_person ADD COLUMN debcamp_id integer NOT NULL DEFAULT 1;

ALTER TABLE debconf.dc_conference_person ADD CONSTRAINT dc_conference_person_debcamp_id FOREIGN KEY (debcamp_id) REFERENCES debconf.dc_debcamp(debcamp_id);

-- Update logging routines
SELECT * FROM log.activate_logging();

INSERT INTO debconf.dc_debcamp (debcamp_option) VALUES ('I won''t be attending DebCamp');
INSERT INTO debconf.dc_debcamp (debcamp_option) VALUES ('I have a specific work plan for DebCamp');
INSERT INTO debconf.dc_debcamp (debcamp_option) VALUES ('I don''t have a specific plan for DebCamp (week payment (250 USD) required)');


COMMIT;


