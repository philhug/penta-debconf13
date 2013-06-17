BEGIN TRANSACTION;

# add additional option to upgrade to 4-bed rooms for sponsored attendees
INSERT INTO debconf.dc_accomodation (accom_id, conference_id, accom) VALUES (27, 7, 'upgrade to 4-bed room (20 CHF/day/person, only sponsored)');

COMMIT TRANSACTION;
