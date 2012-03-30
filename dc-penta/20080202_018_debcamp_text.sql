BEGIN TRANSACTION;

-- Add new column
ALTER TABLE base.dc_conference_person ADD COLUMN debcamp_reason TEXT;

-- Update logging routines
SELECT * FROM log.activate_logging();


COMMIT;


