BEGIN;
UPDATE event_type set rank = -1 where event_type = 'keynote';
INSERT INTO event_type (event_type) VALUES ('tutorial'), ('performance'), ('art_installation'), ('debate');
COMMIT;
