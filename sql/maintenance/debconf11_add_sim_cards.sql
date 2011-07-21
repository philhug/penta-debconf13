ALTER TABLE debconf.dc_conference_person ADD COLUMN has_sim_card boolean NOT NULL DEFAULT FALSE;
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::has_sim_card', 'en', 'Has received a SIM card?');
