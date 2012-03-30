DROP VIEW debconf.view_find_person_entrance;
DROP VIEW debconf.view_dc_conference_person;
DROP VIEW public.view_conference_person;
CREATE VIEW public.view_conference_person AS (SELECT 
  conference_person.conference_person_id, 
  conference_person.person_id, 
  conference_person.conference_id, 
  view_person.name, 
  conference_person.abstract, 
  conference_person.description, 
  conference_person.remark, 
  conference_person.email,
  conference_person.arrived,
  conference_person.reconfirmed
     FROM conference_person
       JOIN view_person USING (person_id));

CREATE VIEW debconf.view_dc_conference_person AS (SELECT
view_conference_person.conference_person_id,
view_conference_person.person_id,
view_conference_person.conference_id,
view_conference_person.name,
view_conference_person.abstract,
view_conference_person.description,
view_conference_person.remark,
view_conference_person.email,
view_conference_person.arrived,
view_conference_person.reconfirmed,
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

CREATE VIEW debconf.view_find_person_entrance AS (SELECT
  public.view_person.person_id,
  public.view_person.name,
  public.view_person.first_name,
  public.view_person.last_name,
  public.view_person.nickname,
  public.view_person.public_name,
  auth.account.login_name,
  auth.account.email,
  public.view_person.gender,
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
  debconf.dc_conference_person.food_id,
  public.view_conference_person.reconfirmed,
  public.view_conference_person.arrived
     FROM (((debconf.dc_conference_person
   JOIN public.view_person USING (person_id))
   JOIN public.view_conference_person USING (person_id, conference_id))
   JOIN auth.account USING (person_id))
);

CREATE VIEW debconf.view_person_is_an_idiot AS SELECT * FROM debconf.view_find_person_entrance
    WHERE ((NOT reconfirmed) OR (reconfirmed IS NULL));
