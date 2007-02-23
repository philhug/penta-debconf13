
CREATE OR REPLACE FUNCTION conflict_person_description_length(INTEGER) RETURNS SETOF conflict_person AS $$
  DECLARE
    cur_conference_id ALIAS FOR $1;
    cur_conference RECORD;
    cur_person RECORD;
  BEGIN
    SELECT INTO cur_conference abstract_length, description_length FROM conference WHERE conference_id = cur_conference_id;
    FOR cur_person IN
      SELECT DISTINCT person_id
        FROM conference_person
             INNER JOIN event_person USING (person_id)
             INNER JOIN event_role ON (
               event_role.event_role_id = event_person.event_role_id AND
               event_role.tag IN ('speaker', 'moderator')
             )
             INNER JOIN event USING (event_id, conference_id)
       WHERE conference_id = cur_conference_id AND
             length(conference_person.description) > cur_conference.description_length
    LOOP
      RETURN NEXT cur_person;
    END LOOP;
  END;
$$ LANGUAGE 'plpgsql' RETURNS NULL ON NULL INPUT;

