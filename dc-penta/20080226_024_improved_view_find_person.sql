BEGIN;
CREATE INDEX event_person_person_id_idx on event_person(person_id);
CREATE INDEX account_person_id_idx on auth.account(person_id);

CREATE OR REPLACE VIEW debconf.dc_view_find_person AS
  SELECT
   view_find_person.person_id,
   view_find_person.name,
   view_find_person.first_name,
   view_find_person.last_name,
   view_find_person.nickname,
   view_find_person.public_name,
   view_find_person.email,
   view_find_person.gender,
   view_find_person.country,
   view_find_person.mime_type,
   view_find_person.file_extension,
   view_find_person.conference_id,
   view_find_person.arrived,
   view_find_person.event_role,
   view_find_person.role,
   debconf.dc_conference_person.attend,
   debconf.dc_accomodation.accom,
   debconf.dc_debcamp.debcamp_option,
   debconf.dc_person_type.description,
   debconf.dc_participant_category.participant_category,
   debconf.dc_food_preferences.food
  FROM view_find_person
    LEFT OUTER JOIN debconf.dc_conference_person USING (person_id,conference_id)
    LEFT OUTER JOIN debconf.dc_person USING (person_id)
        LEFT OUTER JOIN debconf.dc_person_type USING(person_type_id)
    LEFT OUTER JOIN debconf.dc_participant_category ON (dc_participant_category_id = participant_category_id)
        LEFT OUTER JOIN debconf.dc_debcamp USING (debcamp_id)
        LEFT OUTER JOIN debconf.dc_accomodation USING (accom_id,conference_id)
    LEFT OUTER JOIN debconf.dc_food_preferences USING (food_id)
  ORDER BY view_find_person.name, view_find_person.person_id;

