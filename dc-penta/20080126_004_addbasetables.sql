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
CREATE TABLE public.dc_accomodation (
) INHERITS (base.dc_accomodation);

CREATE TABLE public.dc_computer (
) INHERITS (base.dc_computer);

CREATE TABLE public.dc_conference_person (
) INHERITS (base.dc_conference_person);

CREATE TABLE public.dc_daytrip (
) INHERITS (base.dc_daytrip);

CREATE TABLE public.dc_food_preferences (
) INHERITS (base.dc_food_preferences);

CREATE TABLE public.dc_person (
) INHERITS (base.dc_person);

CREATE TABLE public.dc_person_type (
) INHERITS (base.dc_person_type);

CREATE TABLE public.dc_t_shirt_sizes (
) INHERITS (base.dc_t_shirt_sizes);

-- Add the constraints (these go on the public tables, not the base ones)
ALTER TABLE ONLY public.dc_accomodation
    ADD CONSTRAINT dc_accomodation_accom_id_pkey PRIMARY KEY (accom_id);

ALTER TABLE ONLY public.dc_computer
    ADD CONSTRAINT dc_computer_computer_id_pkey PRIMARY KEY (computer_id);

ALTER TABLE ONLY public.dc_conference_person
    ADD CONSTRAINT dc_conference_person_pkey PRIMARY KEY (person_id, conference_id);

ALTER TABLE ONLY public.dc_daytrip
    ADD CONSTRAINT dc_daytrip_daytrip_id_key PRIMARY KEY (daytrip_id);

ALTER TABLE ONLY public.dc_food_preferences
    ADD CONSTRAINT dc_food_preferences_food_id_pkey PRIMARY KEY (food_id);

ALTER TABLE ONLY public.dc_person
    ADD CONSTRAINT dc_person_pkey PRIMARY KEY (person_id);

ALTER TABLE ONLY public.dc_person_type
    ADD CONSTRAINT dc_person_type_person_type_id_key PRIMARY KEY (person_type_id);

ALTER TABLE ONLY public.dc_t_shirt_sizes
    ADD CONSTRAINT dc_t_shirt_sizes_t_shirt_sizes_id_pkey PRIMARY KEY (t_shirt_sizes_id);

ALTER TABLE ONLY public.dc_conference_person
    ADD CONSTRAINT dc_conference_person_accom_id_fkey FOREIGN KEY (accom_id) REFERENCES public.dc_accomodation(accom_id);

ALTER TABLE ONLY public.dc_conference_person
    ADD CONSTRAINT dc_conference_person_computer_id_fkey FOREIGN KEY (computer_id) REFERENCES public.dc_computer(computer_id);

ALTER TABLE ONLY public.dc_conference_person
    ADD CONSTRAINT dc_conference_person_conference_id_fkey FOREIGN KEY (conference_id) REFERENCES public.conference(conference_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.dc_conference_person
    ADD CONSTRAINT dc_conference_person_daytrip_id_fkey FOREIGN KEY (daytrip_id) REFERENCES public.dc_daytrip(daytrip_id);

ALTER TABLE ONLY public.dc_conference_person
    ADD CONSTRAINT dc_conference_person_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.dc_person
    ADD CONSTRAINT dc_person_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.dc_food_preferences(food_id);

ALTER TABLE ONLY public.dc_person
    ADD CONSTRAINT dc_person_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY public.dc_person
    ADD CONSTRAINT dc_person_person_type_id_fkey FOREIGN KEY (person_type_id) REFERENCES public.dc_person_type(person_type_id);

ALTER TABLE ONLY public.dc_person
    ADD CONSTRAINT dc_person_t_shirt_sizes_id_fkey FOREIGN KEY (t_shirt_sizes_id) REFERENCES public.dc_t_shirt_sizes(t_shirt_sizes_id);

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

-- Initialize the logging tables
SELECT * FROM log.activate_logging();

-- Add the debconf tables
CREATE TABLE debconf.dc_accomodation (
) INHERITS (public.dc_accomodation);

CREATE TABLE debconf.dc_computer (
) INHERITS (public.dc_computer);

CREATE TABLE debconf.dc_conference_person (
) INHERITS (public.dc_conference_person);

CREATE TABLE debconf.dc_daytrip (
) INHERITS (public.dc_daytrip);

CREATE TABLE debconf.dc_food_preferences (
) INHERITS (public.dc_food_preferences);

CREATE TABLE debconf.dc_person (
) INHERITS (public.dc_person);

CREATE TABLE debconf.dc_person_type (
) INHERITS (public.dc_person_type);

CREATE TABLE debconf.dc_t_shirt_sizes (
) INHERITS (public.dc_t_shirt_sizes);

-- Manually add logging triggers
CREATE TRIGGER debconf_dc_accomodation_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_accomodation FOR EACH ROW EXECUTE PROCEDURE log.dc_accomodation_log_function();
CREATE TRIGGER debconf_dc_computer_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_computer FOR EACH ROW EXECUTE PROCEDURE log.dc_computer_log_function();
CREATE TRIGGER debconf_dc_conference_person_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_conference_person FOR EACH ROW EXECUTE PROCEDURE log.dc_conference_person_log_function();
CREATE TRIGGER debconf_dc_daytrip_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_daytrip FOR EACH ROW EXECUTE PROCEDURE log.dc_daytrip_log_function();
CREATE TRIGGER debconf_dc_food_preferences_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_food_preferences FOR EACH ROW EXECUTE PROCEDURE log.dc_food_preferences_log_function();
CREATE TRIGGER debconf_dc_person_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_person FOR EACH ROW EXECUTE PROCEDURE log.dc_person_log_function();
CREATE TRIGGER debconf_dc_person_type_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_person_type FOR EACH ROW EXECUTE PROCEDURE log.dc_person_type_log_function();
CREATE TRIGGER debconf_dc_t_shirt_sizes_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_t_shirt_sizes FOR EACH ROW EXECUTE PROCEDURE log.dc_t_shirt_sizes_log_function();

-- Copy the data
INSERT INTO debconf.dc_accomodation SELECT * FROM debconf.accomodation;
INSERT INTO debconf.dc_computer SELECT * FROM debconf.computer;
INSERT INTO debconf.dc_daytrip SELECT * FROM debconf.daytrip;
INSERT INTO debconf.dc_food_preferences SELECT * FROM debconf.food_preferences;
INSERT INTO debconf.dc_person_type SELECT * FROM debconf.person_type;
INSERT INTO debconf.dc_t_shirt_sizes SELECT * FROM debconf.t_shirt_sizes;
INSERT INTO debconf.dc_person SELECT * FROM debconf.person;
INSERT INTO debconf.dc_conference_person SELECT * FROM debconf.conference_person;

-- Drop the old views
DROP VIEW debconf.view_accomodation;
DROP VIEW debconf.view_computer;
DROP VIEW debconf.view_daytrip;
DROP VIEW debconf.view_food_preferences;
DROP VIEW debconf.view_person_type;
DROP VIEW debconf.view_t_shirt_sizes;

-- Drop the old tables
DROP TABLE debconf.conference_person;
DROP TABLE debconf.person;
DROP TABLE debconf.accomodation;
DROP TABLE debconf.computer;
DROP TABLE debconf.daytrip;
DROP TABLE debconf.food_preferences;
DROP TABLE debconf.person_type;
DROP TABLE debconf.t_shirt_sizes;


-- Create new views
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
