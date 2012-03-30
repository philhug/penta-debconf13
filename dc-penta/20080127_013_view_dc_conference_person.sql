CREATE VIEW debconf.view_dc_conference_person AS (SELECT
view_conference_person.conference_person_id,
view_conference_person.person_id,
view_conference_person.conference_id,
view_conference_person.name,
view_conference_person.abstract,
view_conference_person.description,
view_conference_person.remark,
view_conference_person.email,
debconf.dc_conference_person.accom_id,
debconf.dc_conference_person.daytrip_id,
debconf.dc_conference_person.computer_id,
debconf.dc_conference_person.assassins,
debconf.dc_conference_person.public_data,
debconf.dc_conference_person.wireless,
debconf.dc_conference_person.badge,
debconf.dc_conference_person.foodtickets,
debconf.dc_conference_person.nsh,
debconf.dc_conference_person.paid,
debconf.dc_conference_person.paid_number,
debconf.dc_conference_person.cancelled,
debconf.dc_conference_person.bag,
debconf.dc_conference_person.shirt,
debconf.dc_conference_person.hostel,
debconf.dc_conference_person.proceeded,
debconf.dc_conference_person.paiddaytrip,
debconf.dc_conference_person.googled,
debconf.dc_conference_person.drunken,
debconf.dc_conference_person.gotdaytrip,
debconf.dc_conference_person.proceedings,
debconf.dc_conference_person.t_shirt_sizes_id,
debconf.dc_conference_person.food_id
   FROM debconf.dc_conference_person
   JOIN view_conference_person USING (person_id)
);


