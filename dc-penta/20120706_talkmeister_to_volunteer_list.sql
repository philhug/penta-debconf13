BEGIN TRANSACTION;
INSERT INTO event_role (event_role, rank) VALUES ('Talkmeister', NULL);
INSERT INTO conference_room_role  (conference_id, event_role, conference_room, amount) VALUES (6, 'Talkmeister', 'Aula Magna', 1);
INSERT INTO conference_room_role  (conference_id, event_role, conference_room, amount) VALUES (6, 'Talkmeister', 'Roberto Terán', 1);
COMMIT;
