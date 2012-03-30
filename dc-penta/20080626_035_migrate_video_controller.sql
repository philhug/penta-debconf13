-- migrate old debconf7 data
BEGIN;
ALTER TABLE video_recording ADD COLUMN conference_id integer;
ALTER TABLE video_recording ADD COLUMN conference_room text;
UPDATE video_recording SET conference_id = 1, conference_room = CASE
  WHEN room_id = 2 THEN 'Upper Talk Room'
  WHEN room_id = 3 THEN 'Basement Talk Room'
  WHEN room_id = 4 THEN 'Lower BoF Room'
  WHEN room_id = 5 THEN 'Upper BoF Room'
  ELSE 'Elsewhere'
END;
   
ALTER TABLE video_recording DROP COLUMN room_id;
ALTER TABLE video_recording ALTER COLUMN conference_id SET NOT NULL;
ALTER TABLE video_recording ALTER COLUMN conference_room SET NOT NULL;
ALTER TABLE video_recording ADD CONSTRAINT video_recording_conference_id_conference_room_fkey FOREIGN KEY (conference_id, conference_room) REFERENCES conference_room(conference_id, conference_room);

COMMIT;

BEGIN;
-- sql/views/view_event_recording_distance.sql
CREATE OR REPLACE VIEW view_event_recording_distance AS
  SELECT distinct ve.conference_id, ve.event_id, r.id AS recording_id, ve.conference_room,
    ve.start_datetime, r.recording_time,
    CAST(absinter(ve.start_datetime - r.recording_time) AS TEXT) AS distance,
    absinter(ve.start_datetime - r.recording_time) AS distance_interval
  FROM conference c, view_event ve, video_recording r ORDER BY distance_interval;
COMMIT;

-- sql/data/auth.object_domain.sql
BEGIN;
INSERT INTO auth.object_domain ("object", "domain") VALUES ('video_recording', 'public');
INSERT INTO auth.object_domain ("object", "domain") VALUES ('video_event_recording', 'public');
INSERT INTO auth.object_domain ("object", "domain") VALUES ('video_target_file', 'public');
COMMIT;

BEGIN;
-- from sql/trigger.sql
CREATE OR REPLACE FUNCTION event_on_valid_room_trigger() RETURNS TRIGGER AS $$
  DECLARE
    event_r record;
    recording_r record;
  BEGIN
    SELECT INTO event_r conference_room, conference_id FROM event WHERE event_id = NEW.event_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Huh?! (cannot find the right event)';
    END IF;
    SELECT INTO recording_r conference_room, conference_id FROM video_recording WHERE id = NEW.recording_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Huh?! (cannot find the right recording)';
    END IF;
    IF event_r.conference_room != recording_r.conference_room OR event_r.conference_id != recording_r.conference_id OR event_r IS NULL OR recording_r IS NULL THEN
      RAISE EXCEPTION 'Event room and recording room do not match.';
    END IF;
    RETURN NEW;
  END;
$$ LANGUAGE 'plpgsql';

COMMIT;

BEGIN;
-- from sql/data/ui_message.sql
INSERT INTO ui_message (ui_message) VALUES ('video::index');
INSERT INTO ui_message (ui_message) VALUES ('video::list_recordings');
INSERT INTO ui_message (ui_message) VALUES ('video::associate');
INSERT INTO ui_message (ui_message) VALUES ('video::no_recordings');
INSERT INTO ui_message (ui_message) VALUES ('video::associating_recording');
INSERT INTO ui_message (ui_message) VALUES ('video::recording_filename');
INSERT INTO ui_message (ui_message) VALUES ('video::recording_started_at');
INSERT INTO ui_message (ui_message) VALUES ('video::events_scheduled_for_room');
INSERT INTO ui_message (ui_message) VALUES ('video::sorted_by_proximity_to_video');
INSERT INTO ui_message (ui_message) VALUES ('video::distance_to_recording');
INSERT INTO ui_message (ui_message) VALUES ('video::link_event_to_recording');
INSERT INTO ui_message (ui_message) VALUES ('video::unlink');
INSERT INTO ui_message (ui_message) VALUES ('video_event_recording::start_time');
INSERT INTO ui_message (ui_message) VALUES ('video_event_recording::end_time');
INSERT INTO ui_message (ui_message) VALUES ('video_event_recording::event_recording_base_name');
INSERT INTO ui_message (ui_message) VALUES ('video_event_recording::rate');
INSERT INTO ui_message (ui_message) VALUES ('video::rate_file');
INSERT INTO ui_message (ui_message) VALUES ('video::associated_recordings');
INSERT INTO ui_message (ui_message) VALUES ('video::linking_recording');
INSERT INTO ui_message (ui_message) VALUES ('video::empty_means_beginning');
INSERT INTO ui_message (ui_message) VALUES ('video::empty_means_end');
INSERT INTO ui_message (ui_message) VALUES ('video::just_short_form');
INSERT INTO ui_message (ui_message) VALUES ('video::claimed_by');
INSERT INTO ui_message (ui_message) VALUES ('video::associate_recording_first');
INSERT INTO ui_message (ui_message) VALUES ('video::list_events');
INSERT INTO ui_message (ui_message) VALUES ('video::transcoding_status');
INSERT INTO ui_message (ui_message) VALUES ('video::recording');
-- from sql/data/ui_message_localized.sql
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::index', 'en', 'Video index');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::list_recordings', 'en', 'List of available recordings');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::associate', 'en', 'Associate');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::no_recordings', 'en', 'There are no recording for this conference');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::associating_recording', 'en', 'Associating video recording');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::recording_filename', 'en', 'Recording filename');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::recording_started_at', 'en', 'This recording started at');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::events_scheduled_for_room', 'en', 'Events scheduled for room');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::sorted_by_proximity_to_video', 'en', 'sorted by proximity to the video starting time');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::distance_to_recording', 'en', 'Distance to recording start');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::link_event_to_recording', 'en', 'Link recording to event');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::unlink', 'en', 'Unlink');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video_event_recording::start_time', 'en', 'Event start time');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video_event_recording::end_time', 'en', 'Event end time');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video_event_recording::event_recording_base_name', 'en', 'Recording base name (just the short form of the event title. dont include speaker name)');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video_event_recording::rate', 'en', 'Recording rate');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::rate_file', 'en', 'Rate file');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::associated_recordings', 'en', 'Associated Recordings');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::linking_recording', 'en', 'Linking recording to event');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::empty_means_beginning', 'en', 'Empty means beginning of file');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::empty_means_end', 'en', 'Empty means end of file');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::just_short_form', 'en', 'Just the short form of the event title. dont include speaker name');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::claimed_by', 'en', 'Claimed by');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::associate_recording_first', 'en', 'Associate the recording with some event first');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::list_events', 'en', 'Event status');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::transcoding_status', 'en', 'Transcoding status');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('video::recording', 'en', 'Recording');
COMMIT;
