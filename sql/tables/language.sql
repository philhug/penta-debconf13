
-- the language column is the iso 639-1 code of the language
CREATE TABLE base.language (
  language TEXT NOT NULL,
  localized BOOL NOT NULL DEFAULT FALSE
);

CREATE TABLE language (
  PRIMARY KEY (language)
) INHERITS( base.language );

CREATE TABLE log.language (
) INHERITS( base.logging, base.language );

