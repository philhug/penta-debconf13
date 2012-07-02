BEGIN TRANSACTION;
ALTER TABLE base.dc_conference_person ADD COLUMN coffee_mug boolean DEFAULT false NOT NULL;
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::coffee_mug', 'en', 'Has received coffee mug');
COMMIT;
