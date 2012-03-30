BEGIN;
ALTER TABLE base.dc_conference_person ADD COLUMN disabilities boolean not null default false;
SELECT log.activate_logging();
COMMIT;
