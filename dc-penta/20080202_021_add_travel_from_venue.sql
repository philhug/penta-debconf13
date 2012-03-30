BEGIN TRANSACTION;

 -- Add new column
 ALTER TABLE base.dc_conference_person ADD COLUMN travel_from_venue boolean NOT NULL DEFAULT false;

-- Update logging routines
SELECT * FROM log.activate_logging();

COMMIT;
