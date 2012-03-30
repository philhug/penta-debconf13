CREATE TABLE debconf.person (
  person_id          integer  NOT NULL PRIMARY KEY REFERENCES person(person_id) ON UPDATE CASCADE ON DELETE CASCADE,
  person_type_id     integer  REFERENCES person_type(person_type_id),
  emergency_name     text,
  emergency_contact  text,
  t_shirt_sizes_id   integer  REFERENCES debconf.t_shirt_sizes(t_shirt_sizes_id),
  food_id            integer  REFERENCES debconf.food_preferences(food_id),
  f_proceedings      boolean
);

CREATE TABLE debconf.conference_person (
  person_id          integer  NOT NULL REFERENCES person(person_id) ON UPDATE CASCADE ON DELETE CASCADE,
  conference_id      integer  NOT NULL REFERENCES conference(conference_id) ON UPDATE CASCADE ON DELETE CASCADE,
  accom_id           integer  REFERENCES debconf.accomodation(accom_id),
  daytrip_id         integer  REFERENCES debconf.daytrip(daytrip_id),
  computer_id        integer  REFERENCES debconf.computer(computer_id),
  f_game             boolean  not null default false,
  f_public_data      boolean  not null default false,
  f_wireless         boolean  default false,
  f_badge            boolean  not null default false,
  f_foodtickets      boolean  not null default false,
  f_nsh              boolean  not null default false,
  paid               text,
  paid_number        integer,
  cancelled          boolean  not null default false,
  f_bag              boolean  not null default false,
  f_shirt            boolean  not null default false,  
  hostel             text,
  f_proceeded        boolean,
  f_paiddaytrip      boolean  not null default false,
  f_googled          boolean  not null default false,
  f_drunken          boolean  not null default false,
  f_gotdaytrip       boolean  not null default false,
  PRIMARY KEY(person_id, conference_id)
);


