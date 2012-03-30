BEGIN;

CREATE TABLE base.dc_press (
	press_id		SERIAL,
	association		TEXT,
	name			TEXT,
	email			TEXT,
	phone			TEXT,
	street			TEXT,
	zip				TEXT,
	city			TEXT,
	country			TEXT,
	fax				TEXT,
	description		TEXT,
	notes			TEXT,
	url				TEXT
);

CREATE TABLE debconf.dc_press (
	PRIMARY KEY (press_id)
) INHERITS(base.dc_press );

CREATE TABLE base.dc_conference_press (
	conference_press_id		SERIAL,
	conference_id 			INTEGER NOT NULL,
	press_id				INTEGER,
	local					BOOL NOT NULL DEFAULT FALSE,
	person_id				INTEGER NOT NULL
);

CREATE TABLE debconf.dc_conference_press (
	FOREIGN KEY (conference_id) REFERENCES conference (conference_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (person_id) REFERENCES person (person_id) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY (conference_press_id),
	UNIQUE( conference_id, press_id)
) INHERITS ( base.dc_conference_press);

CREATE TABLE log.dc_press (
) INHERITS( base.logging, base.dc_press);

CREATE TABLE log.dc_conference_press (
) INHERITS( base.logging, base.dc_conference_press);

-- Update logging routines
SELECT * FROM log.activate_logging();

COMMIT;
