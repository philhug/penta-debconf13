
CREATE OR REPLACE VIEW view_event_attachment AS
  SELECT event_attachment_id,
         attachment_type_id,
         view_attachment_type.name AS attachment_type,
         view_attachment_type.tag AS attachment_type_tag,
         event_id,
         conference_id,
         mime_type_id,
         mime_type AS mime_type_tag,
         view_mime_type.name AS mime_type,
         filename,
         title,
         pages,
         f_public,
         last_modified,
         octet_length( data ) AS filesize,
         view_attachment_type.language_id
    FROM event_attachment
         INNER JOIN (
             SELECT event_id,
                    conference_id
               FROM event
         ) AS event USING (event_id)
         INNER JOIN view_attachment_type USING (attachment_type_id)
         INNER JOIN view_mime_type USING (mime_type_id, language_id)
;

