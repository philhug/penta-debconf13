
CREATE TABLE master.conference_track(
  conference_id INTEGER NOT NULL,
  conference_track TEXT NOT NULL
) WITHOUT OIDS;

CREATE TABLE conference_track(
  PRIMARY KEY( conference_id, conference_track ),
  FOREIGN KEY(conference_id) REFERENCES conference(conference_id)
) INHERITS(master.conference_track);

CREATE TABLE logging.conference_track() INHERITS(master.conference_track);

