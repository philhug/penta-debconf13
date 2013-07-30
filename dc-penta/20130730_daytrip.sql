BEGIN;

-- daytrip options 
 -- add conference_id, don't duplicate Yes/No, conference_id=1 for existing values
ALTER TABLE debconf.dc_daytrip ADD COLUMN conference_id integer NOT NULL DEFAULT 1;

-- add new values
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (4, 7, '--please select one--');
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (5, 7, 'A: International Clock Museum');
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (6, 7, 'B: Asphalt mine');
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (7, 7, 'C: Absinthe distillery');
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (8, 7, 'D1: Hiking from Les Rochats, 2.5h (7.4km, 300m elevation) ');
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (9, 7, 'D2: Hiking from Le Camp, 5-6h (17km, 950m elevation)');
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (10, 7, 'O: Conference dinner only, I won''t take part in the day trip');
INSERT INTO debconf.dc_daytrip (daytrip_id, conference_id, daytrip_option) VALUES (11, 7, 'X: I won''t take part in the day trip or conference dinner');

-- reset selection for dc13
UPDATE debconf.dc_conference_person set daytrip_id=NULL WHERE conference_id=7;

COMMIT;
