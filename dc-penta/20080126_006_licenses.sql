CREATE TABLE base.dc_event_license (
    license_id integer NOT NULL,
    license character varying(60)
);

-- Add the public tables
CREATE TABLE public.dc_event_license (
) INHERITS (base.dc_event_license);

-- Add the constraints (these go on the public tables, not the base ones)
ALTER TABLE ONLY public.dc_event_license
    ADD CONSTRAINT dc_event_license_license_id_pkey PRIMARY KEY (license_id);

-- And the logging tables
CREATE TABLE log.dc_event_license (
) INHERITS (base.logging, base.dc_event_license);

-- Initialize the logging tables
SELECT * FROM log.activate_logging();

-- Add the debconf tables
CREATE TABLE debconf.dc_event_license (
) INHERITS (public.dc_event_license);

-- Manually add logging triggers
CREATE TRIGGER debconf_dc_event_license_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_event_license FOR EACH ROW EXECUTE PROCEDURE log.dc_event_license_log_function();

-- Copy the data
INSERT INTO debconf.dc_event_license SELECT * FROM public.event_license;

-- Drop the old views
DROP VIEW public.view_event_license;

-- Drop the old tables
DROP TABLE public.event_license;

-- Create new views
CREATE VIEW debconf.view_dc_event_license AS
    SELECT debconf.dc_event_license.license_id, debconf.dc_event_license.license FROM debconf.dc_event_license;

ALTER TABLE base.dc_event_license OWNER TO pentabarf;
ALTER TABLE public.dc_event_license OWNER TO pentabarf;
ALTER TABLE log.dc_event_license OWNER TO pentabarf;
ALTER TABLE debconf.dc_event_license OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_event_license OWNER TO pentabarf;
