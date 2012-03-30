BEGIN;
ALTER TABLE base.dc_person ADD COLUMN photo_or_film_ok boolean not null default true;
SELECT log.activate_logging();
COMMIT;
