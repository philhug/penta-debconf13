BEGIN TRANSACTION;

-- Add new column
ALTER TABLE base.dc_conference_person ADD COLUMN travel_to_venue boolean DEFAULT FALSE NOT NULL;

-- Update logging routines
SELECT * FROM log.activate_logging();


COMMIT;
