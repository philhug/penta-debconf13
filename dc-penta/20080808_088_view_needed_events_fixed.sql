BEGIN;
CREATE OR REPLACE VIEW view_needed_events AS
SELECT event.event_id,
    max(conference_room_role.amount) as needed,
    count(event_person.person_id) as current,
    max(conference_room_role.amount) - count(event_person.person_id) as missing,
    conference_room_role.event_role,
    conference_room_role.conference_room
  FROM event
    LEFT JOIN conference_room_role using(conference_id, conference_room)
    LEFT JOIN event_person on event_person.event_id = event.event_id AND
      conference_room_role.event_role = event_person.event_role
  WHERE
    event_state = 'accepted' AND
    event_state_progress = 'confirmed'
  GROUP BY event.event_id, conference_room_role.event_role, conference_room_role.conference_room
  HAVING max(conference_room_role.amount) - count(event_person.person_id) > 0
  ORDER BY event.event_id;
COMMIT;
