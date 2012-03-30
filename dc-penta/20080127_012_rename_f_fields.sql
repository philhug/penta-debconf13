ALTER TABLE base.dc_conference_person RENAME COLUMN f_game TO game;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_public_data TO public_data;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_wireless TO wireless;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_badge TO badge;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_foodtickets TO foodtickets;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_nsh TO nsh;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_bag TO bag;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_shirt TO shirt;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_proceeded TO proceeded;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_paiddaytrip TO paiddaytrip;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_googled TO googled;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_drunken TO drunken;
ALTER TABLE base.dc_conference_person RENAME COLUMN f_gotdaytrip TO gotdaytrip;
ALTER TABLE base.dc_conference_person RENAME COLUMN game TO assassins;

SELECT * FROM log.activate_logging();

