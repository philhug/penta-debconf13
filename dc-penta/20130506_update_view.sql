BEGIN TRANSACTION;

DROP VIEW debconf.dc_view_find_person;

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
  conference_person.reconfirmed,
  dc_conference_person.attend,
  dc_accomodation.accom,
  dc_debcamp.debcamp_option,
  dc_view_participant_map.person_type,
  dc_debconf_role.description AS debconf_role,
  dc_debian_role.description AS debian_role,
  dc_view_participant_map.participant_category,
  dc_food_preferences.food,
  debconf.dc_food_select.description as food_select,
  debconf.dc_conference_person.camping,
  debconf.dc_conference_person.debcampdc13
  FROM view_find_person
   LEFT JOIN conference_person USING (person_id, conference_id)
   LEFT JOIN debconf.dc_conference_person USING (person_id, conference_id)
   LEFT JOIN debconf.dc_person USING (person_id)
   LEFT JOIN debconf.dc_person_type USING (person_type_id)
   LEFT JOIN (
      SELECT dc_participant_category.participant_category_id,
             dc_participant_category.participant_category
      FROM debconf.dc_participant_category) dcpc ON dc_conference_person.dc_participant_category_id = dcpc.participant_category_id
   LEFT JOIN debconf.dc_view_participant_map ON dc_view_participant_map.participant_mapping_id = dc_conference_person.dc_participant_category_id
   LEFT JOIN debconf.dc_debcamp USING (debcamp_id)
   LEFT JOIN debconf.dc_accomodation USING (accom_id, conference_id)
   LEFT JOIN debconf.dc_food_preferences USING (food_id)
   LEFT JOIN debconf.dc_debian_role USING (debian_role_id)
   LEFT JOIN debconf.dc_debconf_role USING (debconf_role_id)
   LEFT JOIN debconf.dc_food_select ON debconf.dc_conference_person.food_select = debconf.dc_food_select.food_select_id
  ORDER BY view_find_person.name, view_find_person.person_id;

COMMIT TRANSACTION;
