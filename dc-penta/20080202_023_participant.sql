BEGIN TRANSACTION;

CREATE TABLE base.dc_participant_category (
    participant_category_id SERIAL NOT NULL,
    participant_category character varying(50)
);

CREATE TABLE log.dc_participant_category (
) INHERITS (base.logging, base.dc_participant_category);

CREATE TABLE debconf.dc_participant_category (
) INHERITS (base.dc_participant_category);

CREATE TABLE base.dc_participant_mapping (
	participant_mapping_id SERIAL NOT NULL,
	participant_category_id integer NOT NULL,
	description character varying(50)
);

CREATE TABLE log.dc_participant_mapping (
) INHERITS (base.logging, base.dc_participant_mapping);

CREATE TABLE debconf.dc_participant_mapping (
) INHERITS (base.dc_participant_mapping);

-- Add constraint
ALTER TABLE ONLY debconf.dc_participant_category
    ADD CONSTRAINT dc_participant_category__id_pkey PRIMARY KEY (participant_category_id);

ALTER TABLE ONLY debconf.dc_participant_mapping
    ADD CONSTRAINT dc_participant_mapping__id_pkey PRIMARY KEY (participant_mapping_id);

ALTER TABLE ONLY debconf.dc_person_type ADD CONSTRAINT dc_person_type__unique UNIQUE(description);


ALTER TABLE ONLY debconf.dc_participant_mapping ADD CONSTRAINT dc_participant_mapping_description
	FOREIGN KEY (description)
	REFERENCES debconf.dc_person_type(description);

ALTER TABLE debconf.dc_conference_person ADD CONSTRAINT dc_conference_person_participant_mapping_id 
	FOREIGN KEY (dc_participant_category_id) 
	REFERENCES debconf.dc_participant_mapping(participant_mapping_id);

-- Initialize the logging tables
SELECT * FROM log.activate_logging();

CREATE TRIGGER debconf_dc_participant_category_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_participant_category 
	FOR EACH ROW EXECUTE PROCEDURE log.dc_participant_category_log_function();

CREATE TRIGGER debconf_dc_participant_mapping_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_participant_mapping 
	FOR EACH ROW EXECUTE PROCEDURE log.dc_participant_mapping_log_function();

-- fill with data
INSERT INTO debconf.dc_participant_category (participant_category) VALUES ('Independent');
INSERT INTO debconf.dc_participant_category (participant_category) VALUES ('Professional (250 USD per week)');
INSERT INTO debconf.dc_participant_category (participant_category) VALUES ('Corporate (1000 USD per week)');

INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Independent'), 'Volunteer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Independent'), 'Debian Developer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Independent'), 'Non-DD maintainer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Independent'), 'Non-maintainer but interested');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Independent'), 'Organizer');

INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 'Debian Developer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 'Non-DD maintainer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category 
	WHERE participant_category = 'Professional (250 USD per week)'), 'Non-maintainer but interested');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 'Accompanying');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 'Organizer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 'Press');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 'Sponsor');


INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 'Debian Developer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 'Non-DD maintainer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category 
	WHERE participant_category = 'Corporate (1000 USD per week)'), 'Non-maintainer but interested');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 'Accompanying');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 'Organizer');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 'Press');
INSERT INTO debconf.dc_participant_mapping (participant_category_id, description) 
	VALUES ( (SELECT participant_category_id from debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 'Sponsor');

COMMIT;

---

BEGIN TRANSACTION;

DROP TABLE base.dc_participant_mapping CASCADE;

CREATE TABLE base.dc_participant_mapping (
	participant_mapping_id SERIAL NOT NULL,
	participant_category_id integer NOT NULL,
	person_type_id integer NOT NULL
);

CREATE TABLE log.dc_participant_mapping (
) INHERITS (base.logging, base.dc_participant_mapping);

CREATE TABLE debconf.dc_participant_mapping (
) INHERITS (base.dc_participant_mapping);

ALTER TABLE ONLY debconf.dc_participant_mapping
    ADD CONSTRAINT dc_participant_mapping__id_pkey PRIMARY KEY (participant_mapping_id);


ALTER TABLE ONLY debconf.dc_participant_mapping ADD CONSTRAINT dc_participant_mapping_person_type_id
	FOREIGN KEY (person_type_id)
	REFERENCES debconf.dc_person_type(person_type_id);

ALTER TABLE ONLY debconf.dc_participant_mapping ADD CONSTRAINT dc_participant_mapping_participant_catgeory_id
	FOREIGN KEY (participant_category_id)
	REFERENCES debconf.dc_participant_category(participant_category_id);

SELECT * FROM log.activate_logging();

CREATE TRIGGER debconf_dc_participant_mapping_trigger AFTER INSERT OR DELETE OR UPDATE ON debconf.dc_participant_mapping 
	FOR EACH ROW EXECUTE PROCEDURE log.dc_participant_mapping_log_function();

INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Volunteer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Debian Developer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-DD maintainer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-maintainer but interested'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Independent'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Organizer'));

INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Debian Developer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-DD maintainer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-maintainer but interested'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Accompanying'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Organizer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Press'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Professional (250 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Sponsor'));


INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Debian Developer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-DD maintainer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Non-maintainer but interested'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Accompanying'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Organizer'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Press'));
INSERT INTO debconf.dc_participant_mapping (participant_category_id, person_type_id)
	VALUES( (SELECT participant_category_id FROM debconf.dc_participant_category WHERE participant_category = 'Corporate (1000 USD per week)'), 
	   (SELECT person_type_id FROM debconf.dc_person_type WHERE description = 'Sponsor'));

COMMIT;

BEGIN TRANSACTION;

CREATE VIEW debconf.dc_view_participant AS
	SELECT * FROM debconf.dc_participant_mapping INNER JOIN debconf.dc_participant_category USING(participant_category_id)
	ORDER BY person_type_id,participant_category_id;

COMMIT;

      xml << select_row( @dc_conference_person, :person_type_id, DebConf::Dc_person_type.select.map{|e| [e.person_type_id,e.description]}, {:master=>:dc_participant_category_id})
      xml << select_row( @dc_conference_person, :dc_participant_category_id, DebConf::Dc_participant_mapping.select.uniq.map{|e| [e.participant_mapping_id,e.participant_category_id,e.description]},{:slave=>true,:with_empty=>false})

#      xml << select_row( @dc_conference_person, :dc_participant_category_id, DebConf::Dc_participant_category.select.map{|e| [e.participant_category_id,e.participant_category]},{:slave=>true,:with_empty=>false})

#      xml << select_row( @dc_conference_person, :person_type_id, DebConf::Dc_person_type.select.map{|e| [e.person_type_id,e.description]},{:master=>:person_type_id} )
#      xml << select_row( @dc_conference_person, :dc_participant_category_id, DebConf::Dc_participant_category.select.map{|e| [e.participant_category_id,e.person_type_id,e.participant_category]}, {:slave=>true,:with_empty=>false})
