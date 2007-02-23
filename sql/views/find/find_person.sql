
CREATE OR REPLACE VIEW view_find_person AS
  SELECT view_person.person_id,
         view_person.name,
         view_person.first_name,
         view_person.last_name,
         view_person.nickname,
         view_person.public_name,
         view_person.login_name,
         view_person.email_contact,
         view_person.gender,
         person_image.mime_type_id,
         mime_type.mime_type,
         mime_type.file_extension,
         conference_person.conference_id
    FROM view_person
         LEFT OUTER JOIN conference_person USING (person_id)
         LEFT OUTER JOIN person_image USING (person_id)
         LEFT OUTER JOIN mime_type USING (mime_type_id);

