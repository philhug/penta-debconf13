BEGIN;
DROP VIEW debconf.dc_when_do_they_get_here;

CREATE OR REPLACE VIEW debconf.dc_when_do_they_get_here AS

 SELECT DISTINCT person.person_id,
    person.nickname,
    person.country,
    dc_person_type.description,
    person.first_name,
    person.last_name,
    conference_person_travel.arrival_date,
    conference_person_travel.departure_date
  FROM conference_person_travel
   JOIN conference_person USING (conference_person_id)
   JOIN debconf.view_find_person_entrance USING (person_id)
   JOIN person USING (person_id)
   JOIN debconf.dc_conference_person USING (person_id, conference_id)
   JOIN debconf.dc_person_type USING (person_type_id)
   JOIN debconf.dc_participant_mapping ON dc_participant_mapping.participant_mapping_id = dc_conference_person.person_type_id
  WHERE conference_person.conference_id = 3
        AND conference_person_travel.arrival_date IS NOT NULL
        AND conference_person_travel.departure_date IS NOT NULL
        AND dc_conference_person.attend = true
        AND conference_person.reconfirmed = true
  ORDER BY  person.nickname,
            person.country,
            dc_person_type.description,
            person.first_name,
            person.last_name,
            conference_person_travel.arrival_date,
            conference_person_travel.departure_date,
            person.person_id;

COMMIT;
