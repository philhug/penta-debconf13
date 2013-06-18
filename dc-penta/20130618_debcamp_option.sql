BEGIN TRANSACTION;

UPDATE debconf.dc_debcamp SET debcamp_option = 'I don''t have a specific plan for DebCamp (payment required)' WHERE debcamp_id = 3;

END TRANSACTION;
