CREATE TABLE base.dc_event (
    event_id integer NOT NULL,
    license_id integer
);

-- Add the public tables
CREATE TABLE public.dc_event (
) INHERITS (base.dc_event);

-- Add the constraints (these go on the public tables, not the base ones)
ALTER TABLE ONLY public.dc_event
    ADD CONSTRAINT dc_event_event_id_pkey PRIMARY KEY (event_id);

ALTER TABLE ONLY public.dc_event
    ADD CONSTRAINT dc_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(event_id);

ALTER TABLE ONLY public.dc_event
    ADD CONSTRAINT dc_event_license_id_fkey FOREIGN KEY (license_id) REFERENCES public.dc_event_license(license_id);

-- And the logging tables
CREATE TABLE log.dc_event (
) INHERITS (base.logging, base.dc_event);

-- Initialize the logging tables
SELECT * FROM log.activate_logging();

-- Add the debconf tables
CREATE TABLE debconf.dc_event (
) INHERITS (public.dc_event);

-- Manually add logging triggers
CREATE TRIGGER debconf_dc_event_log_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_event FOR EACH ROW EXECUTE PROCEDURE log.dc_event_log_function();

-- Create new views
CREATE VIEW debconf.view_dc_event AS
    SELECT debconf.dc_event.event_id, debconf.dc_event.license_id FROM debconf.dc_event;

ALTER TABLE base.dc_event OWNER TO pentabarf;
ALTER TABLE public.dc_event OWNER TO pentabarf;
ALTER TABLE log.dc_event OWNER TO pentabarf;
ALTER TABLE debconf.dc_event OWNER TO pentabarf;
ALTER TABLE debconf.view_dc_event OWNER TO pentabarf;
