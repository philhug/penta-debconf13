CREATE TABLE debconf.accomodation AS SELECT * FROM public.accomodation;

ALTER TABLE debconf.accomodation ADD CONSTRAINT accomodation_accom_id_pkey PRIMARY KEY(accom_id);

DROP VIEW public.view_accomodation;

CREATE VIEW debconf.view_accomodation AS
  SELECT debconf.accomodation.accom_id, debconf.accomodation.accom
   FROM debconf.accomodation;

DROP TABLE public.accomodation;




CREATE TABLE debconf.t_shirt_sizes AS SELECT * FROM public.t_shirt_sizes;

ALTER TABLE debconf.t_shirt_sizes ADD CONSTRAINT t_shirt_sizes_t_shirt_sizes_id_pkey PRIMARY KEY(t_shirt_sizes_id);

DROP VIEW public.view_t_shirt_sizes;

CREATE VIEW debconf.view_t_shirt_sizes AS
 SELECT debconf.t_shirt_sizes.t_shirt_sizes_id, debconf.t_shirt_sizes.t_shirt_size
    FROM debconf.t_shirt_sizes;

DROP TABLE public.t_shirt_sizes;




CREATE TABLE debconf.computer AS SELECT * FROM public.computer;

ALTER TABLE debconf.computer ADD CONSTRAINT computer_computer_id_pkey PRIMARY KEY(computer_id);

DROP VIEW public.view_computer;

CREATE VIEW debconf.view_computer AS
 SELECT debconf.computer.computer_id, debconf.computer.computer
    FROM debconf.computer;

DROP TABLE public.computer;




CREATE TABLE debconf.food_preferences AS SELECT * FROM public.food_preferences;

ALTER TABLE debconf.food_preferences ADD CONSTRAINT food_preferences_food_id_pkey PRIMARY KEY(food_id);

DROP VIEW public.view_food_preferences;

CREATE VIEW debconf.view_food_preferences AS
 SELECT debconf.food_preferences.food_id, debconf.food_preferences.food
    FROM debconf.food_preferences;

DROP TABLE public.food_preferences;




CREATE TABLE debconf.daytrip AS SELECT * FROM public.daytrip;

ALTER TABLE debconf.daytrip ADD CONSTRAINT daytrip_daytrip_id_key PRIMARY KEY(daytrip_id);

DROP VIEW public.view_daytrip;

CREATE VIEW debconf.view_daytrip AS
 SELECT debconf.daytrip.daytrip_id, debconf.daytrip.daytrip_option
    FROM debconf.daytrip;

DROP TABLE public.daytrip;

