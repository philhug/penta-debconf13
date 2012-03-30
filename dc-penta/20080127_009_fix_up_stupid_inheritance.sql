-- Backup data

CREATE TABLE debconf.dc_accomodation_backup AS SELECT * FROM debconf.dc_accomodation;
CREATE TABLE debconf.dc_computer_backup AS SELECT * FROM debconf.dc_computer;
CREATE TABLE debconf.dc_conference_person_backup AS SELECT * FROM debconf.dc_conference_person;
CREATE TABLE debconf.dc_daytrip_backup AS SELECT * FROM debconf.dc_daytrip;
CREATE TABLE debconf.dc_food_preferences_backup AS SELECT * FROM debconf.dc_food_preferences;
CREATE TABLE debconf.dc_person_backup AS SELECT * FROM debconf.dc_person;
CREATE TABLE debconf.dc_person_type_backup AS SELECT * FROM debconf.dc_person_type;
CREATE TABLE debconf.dc_t_shirt_sizes_backup AS SELECT * FROM debconf.dc_t_shirt_sizes;
CREATE TABLE debconf.dc_event_license_backup AS SELECT * FROM debconf.dc_event_license;
CREATE TABLE debconf.dc_event_backup AS SELECT * FROM debconf.dc_event;

-- Drop views
DROP VIEW debconf.view_dc_accomodation;
DROP VIEW debconf.view_dc_computer;
DROP VIEW debconf.view_dc_daytrip;
DROP VIEW debconf.view_dc_food_preferences;
DROP VIEW debconf.view_dc_person_type;
DROP VIEW debconf.view_dc_t_shirt_sizes;
DROP VIEW debconf.view_dc_event_license;
DROP VIEW debconf.view_dc_event;

-- Remove tables

DROP TABLE debconf.dc_conference_person;
DROP TABLE debconf.dc_person;
DROP TABLE debconf.dc_event;
DROP TABLE debconf.dc_accomodation;
DROP TABLE debconf.dc_computer;
DROP TABLE debconf.dc_daytrip;
DROP TABLE debconf.dc_food_preferences;
DROP TABLE debconf.dc_person_type;
DROP TABLE debconf.dc_t_shirt_sizes;
DROP TABLE debconf.dc_event_license;

DROP TABLE public.dc_conference_person;
DROP TABLE public.dc_person;
DROP TABLE public.dc_event;
DROP TABLE public.dc_accomodation;
DROP TABLE public.dc_computer;
DROP TABLE public.dc_daytrip;
DROP TABLE public.dc_food_preferences;
DROP TABLE public.dc_person_type;
DROP TABLE public.dc_t_shirt_sizes;
DROP TABLE public.dc_event_license;

DROP TABLE log.dc_conference_person;
DROP TABLE log.dc_person;
DROP TABLE log.dc_event;
DROP TABLE log.dc_accomodation;
DROP TABLE log.dc_computer;
DROP TABLE log.dc_daytrip;
DROP TABLE log.dc_food_preferences;
DROP TABLE log.dc_person_type;
DROP TABLE log.dc_t_shirt_sizes;
DROP TABLE log.dc_event_license;

DROP TABLE base.dc_conference_person;
DROP TABLE base.dc_person;
DROP TABLE base.dc_event;
DROP TABLE base.dc_accomodation;
DROP TABLE base.dc_computer;
DROP TABLE base.dc_daytrip;
DROP TABLE base.dc_food_preferences;
DROP TABLE base.dc_person_type;
DROP TABLE base.dc_t_shirt_sizes;
DROP TABLE base.dc_event_license;

-- Drop old logging functions
DROP FUNCTION log.dc_accomodation_log_function();
DROP FUNCTION log.dc_daytrip_log_function();
DROP FUNCTION log.dc_food_preferences_log_function();
DROP FUNCTION log.dc_t_shirt_sizes_log_function();
DROP FUNCTION log.dc_computer_log_function();
DROP FUNCTION log.dc_event_license_log_function();
DROP FUNCTION log.dc_person_log_function();
DROP FUNCTION log.dc_conference_person_log_function();
DROP FUNCTION log.dc_event_log_function();
DROP FUNCTION log.dc_person_type_log_function();


-- Add some new tables

CREATE TABLE base.dc_accomodation (
    accom_id integer NOT NULL,
    accom character varying(60)
);

CREATE TABLE base.dc_computer (
    computer_id integer NOT NULL,
    computer character varying(60)
);

CREATE TABLE base.dc_conference_person (
    person_id integer NOT NULL,
    conference_id integer NOT NULL,
    accom_id integer,
    daytrip_id integer,
    computer_id integer,
    f_game boolean DEFAULT false NOT NULL,
    f_public_data boolean DEFAULT false NOT NULL,
    f_wireless boolean DEFAULT false,
    f_badge boolean DEFAULT false NOT NULL,
    f_foodtickets boolean DEFAULT false NOT NULL,
    f_nsh boolean DEFAULT false NOT NULL,
    paid text,
    paid_number integer,
    cancelled boolean DEFAULT false NOT NULL,
    f_bag boolean DEFAULT false NOT NULL,
    f_shirt boolean DEFAULT false NOT NULL,
    hostel text,
    f_proceeded boolean,
    f_paiddaytrip boolean DEFAULT false NOT NULL,
    f_googled boolean DEFAULT false NOT NULL,
    f_drunken boolean DEFAULT false NOT NULL,
    f_gotdaytrip boolean DEFAULT false NOT NULL
);

CREATE TABLE base.dc_daytrip (
    daytrip_id integer NOT NULL,
    daytrip_option character varying(60)
);

CREATE TABLE base.dc_event (
    event_id integer NOT NULL,
    license_id integer
);

CREATE TABLE base.dc_event_license (
    license_id integer NOT NULL,
    license character varying(60)
);

CREATE TABLE base.dc_food_preferences (
    food_id integer NOT NULL,
    food character varying(60)
);

CREATE TABLE base.dc_person (
    person_id integer NOT NULL,
    person_type_id integer,
    emergency_name text,
    emergency_contact text,
    t_shirt_sizes_id integer,
    food_id integer,
    f_proceedings boolean
);

CREATE TABLE base.dc_person_type (
    person_type_id integer NOT NULL,
    description character varying(50)
);

CREATE TABLE base.dc_t_shirt_sizes (
    t_shirt_sizes_id integer NOT NULL,
    t_shirt_size text
);

-- Add the public tables
CREATE TABLE debconf.dc_accomodation (
) INHERITS (base.dc_accomodation);

CREATE TABLE debconf.dc_computer (
) INHERITS (base.dc_computer);

CREATE TABLE debconf.dc_conference_person (
) INHERITS (base.dc_conference_person);

CREATE TABLE debconf.dc_daytrip (
) INHERITS (base.dc_daytrip);

CREATE TABLE debconf.dc_event (
) INHERITS (base.dc_event);

CREATE TABLE debconf.dc_event_license (
) INHERITS (base.dc_event_license);

CREATE TABLE debconf.dc_food_preferences (
) INHERITS (base.dc_food_preferences);

CREATE TABLE debconf.dc_person (
) INHERITS (base.dc_person);

CREATE TABLE debconf.dc_person_type (
) INHERITS (base.dc_person_type);

CREATE TABLE debconf.dc_t_shirt_sizes (
) INHERITS (base.dc_t_shirt_sizes);

-- Add the constraints (these go on the public tables, not the base ones)
ALTER TABLE ONLY debconf.dc_event_license
    ADD CONSTRAINT dc_event_license_license_id_pkey PRIMARY KEY (license_id);

ALTER TABLE ONLY debconf.dc_accomodation
    ADD CONSTRAINT dc_accomodation_accom_id_pkey PRIMARY KEY (accom_id);

ALTER TABLE ONLY debconf.dc_computer
    ADD CONSTRAINT dc_computer_computer_id_pkey PRIMARY KEY (computer_id);

ALTER TABLE ONLY debconf.dc_conference_person
    ADD CONSTRAINT dc_conference_person_pkey PRIMARY KEY (person_id, conference_id);

ALTER TABLE ONLY debconf.dc_daytrip
    ADD CONSTRAINT dc_daytrip_daytrip_id_key PRIMARY KEY (daytrip_id);

ALTER TABLE ONLY debconf.dc_food_preferences
    ADD CONSTRAINT dc_food_preferences_food_id_pkey PRIMARY KEY (food_id);

ALTER TABLE ONLY debconf.dc_person
    ADD CONSTRAINT dc_person_pkey PRIMARY KEY (person_id);

ALTER TABLE ONLY debconf.dc_person_type
    ADD CONSTRAINT dc_person_type_person_type_id_key PRIMARY KEY (person_type_id);

ALTER TABLE ONLY debconf.dc_t_shirt_sizes
    ADD CONSTRAINT dc_t_shirt_sizes_t_shirt_sizes_id_pkey PRIMARY KEY (t_shirt_sizes_id);

ALTER TABLE ONLY debconf.dc_conference_person
    ADD CONSTRAINT dc_conference_person_accom_id_fkey FOREIGN KEY (accom_id) REFERENCES debconf.dc_accomodation(accom_id);

ALTER TABLE ONLY debconf.dc_conference_person
    ADD CONSTRAINT dc_conference_person_computer_id_fkey FOREIGN KEY (computer_id) REFERENCES debconf.dc_computer(computer_id);

ALTER TABLE ONLY debconf.dc_conference_person
    ADD CONSTRAINT dc_conference_person_conference_id_fkey FOREIGN KEY (conference_id) REFERENCES public.conference(conference_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY debconf.dc_conference_person
    ADD CONSTRAINT dc_conference_person_daytrip_id_fkey FOREIGN KEY (daytrip_id) REFERENCES debconf.dc_daytrip(daytrip_id);

ALTER TABLE ONLY debconf.dc_conference_person
    ADD CONSTRAINT dc_conference_person_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY debconf.dc_person
    ADD CONSTRAINT dc_person_food_id_fkey FOREIGN KEY (food_id) REFERENCES debconf.dc_food_preferences(food_id);

ALTER TABLE ONLY debconf.dc_person
    ADD CONSTRAINT dc_person_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY debconf.dc_person
    ADD CONSTRAINT dc_person_person_type_id_fkey FOREIGN KEY (person_type_id) REFERENCES debconf.dc_person_type(person_type_id);

ALTER TABLE ONLY debconf.dc_person
    ADD CONSTRAINT dc_person_t_shirt_sizes_id_fkey FOREIGN KEY (t_shirt_sizes_id) REFERENCES debconf.dc_t_shirt_sizes(t_shirt_sizes_id);

ALTER TABLE ONLY debconf.dc_event
    ADD CONSTRAINT dc_event_event_id_pkey PRIMARY KEY (event_id);

ALTER TABLE ONLY debconf.dc_event
    ADD CONSTRAINT dc_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(event_id);

ALTER TABLE ONLY debconf.dc_event
    ADD CONSTRAINT dc_event_license_id_fkey FOREIGN KEY (license_id) REFERENCES debconf.dc_event_license(license_id);

-- And the logging tables
CREATE TABLE log.dc_accomodation (
) INHERITS (base.logging, base.dc_accomodation);

CREATE TABLE log.dc_computer (
) INHERITS (base.logging, base.dc_computer);

CREATE TABLE log.dc_conference_person (
) INHERITS (base.logging, base.dc_conference_person);

CREATE TABLE log.dc_daytrip (
) INHERITS (base.logging, base.dc_daytrip);

CREATE TABLE log.dc_food_preferences (
) INHERITS (base.logging, base.dc_food_preferences);

CREATE TABLE log.dc_person (
) INHERITS (base.logging, base.dc_person);

CREATE TABLE log.dc_person_type (
) INHERITS (base.logging, base.dc_person_type);

CREATE TABLE log.dc_t_shirt_sizes (
) INHERITS (base.logging, base.dc_t_shirt_sizes);

CREATE TABLE log.dc_event (
) INHERITS (base.logging, base.dc_event);

CREATE TABLE log.dc_event_license (
) INHERITS (base.logging, base.dc_event_license);

-- Initialize the logging tables
SELECT * FROM log.activate_logging();

-- Copy the data
INSERT INTO debconf.dc_accomodation SELECT * FROM debconf.dc_accomodation_backup;
INSERT INTO debconf.dc_event_license SELECT * FROM debconf.dc_event_license_backup;
INSERT INTO debconf.dc_computer SELECT * FROM debconf.dc_computer_backup;
INSERT INTO debconf.dc_daytrip SELECT * FROM debconf.dc_daytrip_backup;
INSERT INTO debconf.dc_food_preferences SELECT * FROM debconf.dc_food_preferences_backup;
INSERT INTO debconf.dc_person_type SELECT * FROM debconf.dc_person_type_backup;
INSERT INTO debconf.dc_t_shirt_sizes SELECT * FROM debconf.dc_t_shirt_sizes_backup;
INSERT INTO debconf.dc_person SELECT * FROM debconf.dc_person_backup;
INSERT INTO debconf.dc_conference_person SELECT * FROM debconf.dc_conference_person_backup;
INSERT INTO debconf.dc_event SELECT * FROM debconf.dc_event_backup;

-- Drop the backup tables
DROP TABLE debconf.dc_conference_person_backup;
DROP TABLE debconf.dc_person_backup;
DROP TABLE debconf.dc_accomodation_backup;
DROP TABLE debconf.dc_computer_backup;
DROP TABLE debconf.dc_daytrip_backup;
DROP TABLE debconf.dc_food_preferences_backup;
DROP TABLE debconf.dc_person_type_backup;
DROP TABLE debconf.dc_t_shirt_sizes_backup;
DROP TABLE debconf.dc_event_backup;
DROP TABLE debconf.dc_event_license_backup;

-- Recreate views
CREATE VIEW debconf.view_dc_accomodation AS
    SELECT debconf.dc_accomodation.accom_id, debconf.dc_accomodation.accom FROM debconf.dc_accomodation;

CREATE VIEW debconf.view_dc_computer AS
    SELECT debconf.dc_computer.computer_id, debconf.dc_computer.computer FROM debconf.dc_computer;

CREATE VIEW debconf.view_dc_daytrip AS
    SELECT debconf.dc_daytrip.daytrip_id, debconf.dc_daytrip.daytrip_option FROM debconf.dc_daytrip;

CREATE VIEW debconf.view_dc_food_preferences AS
    SELECT debconf.dc_food_preferences.food_id, debconf.dc_food_preferences.food FROM debconf.dc_food_preferences;

CREATE VIEW debconf.view_dc_person_type AS
    SELECT debconf.dc_person_type.person_type_id, debconf.dc_person_type.description FROM debconf.dc_person_type;

CREATE VIEW debconf.view_dc_t_shirt_sizes AS
    SELECT debconf.dc_t_shirt_sizes.t_shirt_sizes_id, debconf.dc_t_shirt_sizes.t_shirt_size FROM debconf.dc_t_shirt_sizes;

CREATE VIEW debconf.view_dc_event_license AS
    SELECT debconf.dc_event_license.license_id, debconf.dc_event_license.license FROM debconf.dc_event_license;

CREATE VIEW debconf.view_dc_event AS
    SELECT debconf.dc_event.event_id, debconf.dc_event.license_id FROM debconf.dc_event;

ALTER TABLE base.dc_accomodation OWNER TO pentabarf;
ALTER TABLE base.dc_computer OWNER TO pentabarf;
ALTER TABLE base.dc_conference_person OWNER TO pentabarf;
ALTER TABLE base.dc_daytrip OWNER TO pentabarf;
ALTER TABLE base.dc_food_preferences OWNER TO pentabarf;
ALTER TABLE base.dc_person OWNER TO pentabarf;
ALTER TABLE base.dc_person_type OWNER TO pentabarf;
ALTER TABLE base.dc_t_shirt_sizes OWNER TO pentabarf;
ALTER TABLE base.dc_event OWNER TO pentabarf;
ALTER TABLE base.dc_event_license OWNER TO pentabarf;
ALTER TABLE log.dc_accomodation OWNER TO pentabarf;
ALTER TABLE log.dc_computer OWNER TO pentabarf;
ALTER TABLE log.dc_conference_person OWNER TO pentabarf;
ALTER TABLE log.dc_daytrip OWNER TO pentabarf;
ALTER TABLE log.dc_food_preferences OWNER TO pentabarf;
ALTER TABLE log.dc_person OWNER TO pentabarf;
ALTER TABLE log.dc_person_type OWNER TO pentabarf;
ALTER TABLE log.dc_t_shirt_sizes OWNER TO pentabarf;
ALTER TABLE log.dc_event OWNER TO pentabarf;
ALTER TABLE log.dc_event_license OWNER TO pentabarf;
ALTER TABLE debconf.dc_accomodation OWNER TO pentabarf;
ALTER TABLE debconf.dc_computer OWNER TO pentabarf;
ALTER TABLE debconf.dc_conference_person OWNER TO pentabarf;
ALTER TABLE debconf.dc_daytrip OWNER TO pentabarf;
ALTER TABLE debconf.dc_food_preferences OWNER TO pentabarf;
ALTER TABLE debconf.dc_person OWNER TO pentabarf;
ALTER TABLE debconf.dc_person_type OWNER TO pentabarf;
ALTER TABLE debconf.dc_t_shirt_sizes OWNER TO pentabarf;
ALTER TABLE debconf.dc_event OWNER TO pentabarf;
ALTER TABLE debconf.dc_event_license OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_accomodation OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_computer OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_daytrip OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_food_preferences OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_person_type OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_t_shirt_sizes OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_event OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_event_license OWNER TO pentabarf;

