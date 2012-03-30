 -- Add new column
 ALTER TABLE base.dc_conference_person ADD COLUMN attend boolean NOT NULL DEFAULT false;

-- Update logging routines
SELECT * FROM log.activate_logging();

UPDATE debconf.dc_conference_person SET attend = public.conference_person.reconfirmed FROM public.conference_person WHERE public.conference_person.conference_id = 1 AND debconf.dc_conference_person.person_id = public.conference_person.person_id;
