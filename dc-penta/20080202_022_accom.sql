BEGIN TRANSACTION;

--- add new column to dc_accomodation
ALTER TABLE base.dc_accomodation ADD COLUMN conference_id integer NOT NULL DEFAULT 1;

--- constraint for it
ALTER TABLE ONLY debconf.dc_accomodation ADD CONSTRAINT dc_accomodation_conference_id FOREIGN KEY (conference_id) REFERENCES conference(conference_id);

--- Update logging routines
SELECT * FROM log.activate_logging();

--- Add new preferences
INSERT INTO debconf.dc_accomodation (accom_id, accom, conference_id) VALUES (6, 'Regular room', 2);
INSERT INTO debconf.dc_accomodation (accom_id, accom, conference_id) VALUES (7, 'Junior suite (extra payment required)', 2);
INSERT INTO debconf.dc_accomodation (accom_id, accom, conference_id) VALUES (8, 'Executive suite (extra payment required)', 2);


COMMIT;


