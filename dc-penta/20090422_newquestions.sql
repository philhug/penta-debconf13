-- Add new column
ALTER TABLE base.dc_conference_person ADD COLUMN debianwork text;

-- Update logging routines
SELECT * FROM log.activate_logging();
