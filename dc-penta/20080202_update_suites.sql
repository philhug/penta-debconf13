BEGIN TRANSACTION;

UPDATE debconf.dc_accomodation SET accom = 'Junior Suite (USD 110 per night)' where accom_id = 7;
DELETE FROM debconf.dc_accomodation where accom_id = 8;

COMMIT;
