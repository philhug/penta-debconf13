BEGIN;

ALTER TABLE debconf.dc_conference_person ADD COLUMN disabilities bool DEFAULT false NOT NULL;
ALTER TABLE debconf.dc_person ADD COLUMN photo_or_film_ok bool DEFAULT true NOT NULL;
ALTER TABLE debconf.dc_participant_category ADD COLUMN conference_id int4;

CREATE OR REPLACE VIEW debconf.dc_view_participant
(
  participant_category_id,
  participant_mapping_id,
  person_type_id,
  participant_category
)
AS
SELECT dc_participant_mapping.participant_category_id, dc_participant_mapping.participant_mapping_id, dc_participant_mapping.person_type_id, dc_participant_category.participant_category FROM (debconf.dc_participant_mapping JOIN debconf.dc_participant_category USING (participant_category_id)) WHERE (dc_participant_category.conference_id = 4) ORDER BY dc_participant_mapping.person_type_id, dc_participant_mapping.participant_category_id; GRANT TRUNCATE, UPDATE, TRIGGER, DELETE, SELECT, INSERT, REFERENCES ON debconf.dc_view_participant TO pentabarf; GRANT SELECT ON debconf.dc_view_participant TO readonly;;

COMMIT;
