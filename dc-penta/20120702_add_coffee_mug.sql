BEGIN TRANSACTION;
ALTER TABLE base.dc_conference_person ADD COLUMN coffee_mug boolean DEFAULT false NOT NULL;
COMMIT;
