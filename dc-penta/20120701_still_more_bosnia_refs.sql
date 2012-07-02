BEGIN TRANSACTION;
CREATE OR REPLACE VIEW debconf.dc_view_person_not_arrived AS
    SELECT COALESCE(p.public_name, ((COALESCE(p.first_name || ''::text, ''::text) || p.last_name)::character varying)::text,
    	   	    p.nickname) AS name, p.person_id, conference_person_travel.arrival_date
    	   FROM person p
	   JOIN conference_person USING (person_id)
   	   JOIN conference_person_travel USING (conference_person_id)
  	   WHERE conference_person.conference_id = 6 AND conference_person.arrived = false AND conference_person_travel.arrival_date <= now() AND conference_person.reconfirmed = true;

CREATE OR REPLACE VIEW debconf.dc_view_find_person_is_an_idiot AS
       SELECT view_person.person_id, view_person.name, view_person.first_name, view_person.last_name, view_person.nickname, view_person.public_name, view_person.email, view_person.gender, view_conference_person.reconfirmed, view_conference_person.arrived, view_conference_person.conference_id
       FROM view_person
       LEFT JOIN view_conference_person USING (person_id)
       WHERE (NOT view_conference_person.reconfirmed OR view_conference_person.reconfirmed IS NULL) AND (view_conference_person.conference_id = 6 OR view_conference_person.conference_id IS NULL);

-- Here we change two fields' data types: arrival and departure are
-- now timestamps instead of dates.
DROP VIEW debconf.dc_when_do_they_get_here;
CREATE VIEW debconf.dc_when_do_they_get_here AS
       SELECT DISTINCT person.person_id, person.nickname, person.country, dc_debconf_role.description, person.first_name, person.last_name, conference_person.arrived, (conference_person_travel.arrival_date + COALESCE(conference_person_travel.arrival_time, '00:00:00'::time)) AS arrival_time, (conference_person_travel.departure_date + COALESCE(conference_person_travel.departure_time, '00:00:00'::time)) AS departure_time
       FROM conference_person_travel
       JOIN conference_person USING (conference_person_id)
       JOIN debconf.view_find_person_entrance USING (person_id)
       JOIN person USING (person_id)
       JOIN debconf.dc_conference_person USING (person_id, conference_id)
       JOIN debconf.dc_debconf_role USING (debconf_role_id)
       JOIN debconf.dc_participant_mapping ON dc_participant_mapping.debconf_role_id = dc_conference_person.debconf_role_id
       WHERE conference_person.conference_id = 6 AND conference_person_travel.arrival_date IS NOT NULL AND conference_person_travel.departure_date IS NOT NULL AND dc_conference_person.attend = true AND conference_person.reconfirmed = true
       ORDER BY person.nickname, person.country, dc_debconf_role.description, person.first_name, person.last_name, arrival_time, departure_time, person.person_id, conference_person.arrived;

COMMIT;
