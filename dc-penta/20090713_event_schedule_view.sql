BEGIN;

CREATE OR REPLACE VIEW debconf.dc_view_event_schedule_view AS
    SELECT DISTINCT    event_id,
            conference_day,
            start_time,
            conference_room,
            event_state,
            event_state_progress,
            event.title,
            public_name
    FROM event
        JOIN event_person USING (event_id)
        JOIN person USING (person_id)
    WHERE conference_id=3
    ORDER BY conference_day, start_time;

grant select on debconf.dc_view_event_schedule_view to readonly;

COMMIT;
