BEGIN;

DROP VIEW debconf.view_dc_assassination_victims;
DROP VIEW debconf.view_dc_assassination_killers;
DROP TABLE debconf.dc_assassins;
DROP TABLE debconf.dc_assassins_kills;
DROP TABLE debconf.dc_conference;
DROP TABLE log.dc_conference;
DROP TABLE log.dc_assassins;
DROP TABLE log.dc_assassins_kills;
DROP TABLE base.dc_conference;
DROP TABLE base.dc_assassins;
DROP TABLE base.dc_assassins_kills;

CREATE TABLE base.dc_assassins (
  assassins_id SERIAL NOT NULL,
  conference_id INT NOT NULL REFERENCES conference(conference_id) ON UPDATE CASCADE ON DELETE CASCADE,
  person_id INT NOT NULL REFERENCES person(person_id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_id INT REFERENCES person(person_id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE debconf.dc_assassins (
  PRIMARY KEY (assassins_id)
) INHERITS (base.dc_assassins);

CREATE TABLE base.dc_assassins_kills (
  assassins_kill_id SERIAL NOT NULL,
  person_id INT NOT NULL REFERENCES person(person_id) ON UPDATE CASCADE ON DELETE CASCADE,
  killed_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  killed_by INT REFERENCES person(person_id) ON UPDATE CASCADE ON DELETE CASCADE,
  conference_id INT NOT NULL REFERENCES conference(conference_id) ON UPDATE CASCADE ON DELETE CASCADE,
  acked_kill BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE debconf.dc_assassins_kills (
  PRIMARY KEY (assassins_kill_id)
) INHERITS (base.dc_assassins_kills);

CREATE TABLE log.dc_assassins (
) INHERITS( base.logging, base.dc_assassins);

CREATE TABLE log.dc_assassins_kills (
) INHERITS( base.logging, base.dc_assassins_kills);

CREATE TABLE base.dc_conference (
  conference_id      integer  NOT NULL REFERENCES conference(conference_id) ON UPDATE CASCADE ON DELETE CASCADE,
  assassins_started  boolean  not null default false,
  assassins_ended  boolean  not null default false,
  display_winner  boolean  not null default false,
  PRIMARY KEY(conference_id)
);

CREATE TABLE debconf.dc_conference (
  PRIMARY KEY (conference_id)
) INHERITS (base.dc_conference);

CREATE TABLE log.dc_conference (
) INHERITS( base.logging, base.dc_conference);

DELETE FROM auth.object_domain WHERE domain = 'public' AND object IN ('dc_assassins', 'dc_conference', 'dc_assassins_kills');
INSERT INTO auth.object_domain (object, domain) VALUES ('dc_assassins', 'public');
INSERT INTO auth.object_domain (object, domain) VALUES ('dc_conference', 'public');
INSERT INTO auth.object_domain (object, domain) VALUES ('dc_assassins_kills', 'public');

-- Update logging routines
SELECT * FROM log.activate_logging();

CREATE OR REPLACE VIEW debconf.view_dc_assassins AS (
  SELECT COALESCE(p.public_name, ((COALESCE(((p.first_name)::text || ''::text), ''::text) || (p.last_name)::text))::character varying, p.nickname) AS name,
  conference_id,
  nickname as nick,
  person_id
  FROM debconf.dc_conference_person 
  JOIN person AS p USING (person_id) 
  JOIN conference_person USING (person_id, conference_id)
  WHERE assassins = 't'
  AND conference_person.arrived = 't'
);

CREATE OR REPLACE VIEW debconf.view_dc_assassination_victims AS (
  SELECT COALESCE(p.public_name, ((COALESCE(p.first_name || ''::text, ''::text) || p.last_name)::character varying)::text, p.nickname) AS name,
         dc_conference_person.conference_id, 
         debconf.dc_assassins_kills.killed_at,
         debconf.dc_assassins_kills.killed_by,
         (SELECT COALESCE(pe.public_name, ((COALESCE(pe.first_name || ''::text, ''::text) || pe.last_name)::character varying)::text, pe.nickname) ) AS killed_by_name,
  debconf.dc_assassins_kills.acked_kill,
  p.person_id
  FROM debconf.dc_conference_person 
  JOIN person p USING (person_id) 
  JOIN debconf.dc_assassins_kills USING (person_id, conference_id)
  JOIN person pe ON pe.person_id = debconf.dc_assassins_kills.killed_by
);

CREATE OR REPLACE VIEW debconf.view_dc_assassination_killers AS (
  SELECT DISTINCT COALESCE(p.public_name, ((COALESCE(p.first_name || ''::text, ''::text) || p.last_name)::character varying)::text, p.nickname) AS name, 
         dc_conference_person.conference_id, 
         p.person_id, 
         (SELECT COUNT(d.killed_by) FROM debconf.dc_assassins_kills AS d WHERE d.killed_by = p.person_id) AS kills 
  FROM debconf.dc_conference_person  
  JOIN debconf.dc_assassins_kills USING (person_id, conference_id) 
  JOIN person p ON p.person_id = debconf.dc_assassins_kills.killed_by 
  ORDER BY kills
);

CREATE OR REPLACE VIEW debconf.view_dc_assassin_pairs AS (
SELECT COALESCE(p.public_name, ((COALESCE(p.first_name || ''::text, ''::text) || p.last_name)::character varying)::text, p.nickname) AS hunter,
       debconf.dc_assassins.conference_id, 
       debconf.dc_assassins.person_id, 
       debconf.dc_assassins.target_id, (
SELECT COALESCE(pe.public_name, ((COALESCE(pe.first_name || ''::text, ''::text) || pe.last_name)::character varying)::text, pe.nickname) AS "coalesce") AS hunted 
       FROM debconf.dc_assassins 
       JOIN person p USING (person_id) 
       JOIN person pe ON pe.person_id = dc_assassins.target_id
);
COMMIT;
