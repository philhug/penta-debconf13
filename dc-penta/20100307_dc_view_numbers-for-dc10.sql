BEGIN;
DROP VIEW debconf.dc_view_numbers;
CREATE OR REPLACE VIEW debconf.dc_view_numbers AS
 SELECT p.person_id AS id, COALESCE(p.public_name,
 ((COALESCE(p.first_name || ' '::text, ''::text) ||
 p.last_name)::character varying)::text, p.nickname) AS name,
 p.nickname AS nick, p.city, p.email, ( SELECT country_localized.name
           FROM country_localized
          WHERE p.country = country_localized.country AND
	  country_localized.translated = 'en'::text) AS country,
	  dcpt.description AS status, dca.accom, dca.accom_id,
	  dccp.attend, dcvpm.participant_category, dcd.debcamp_option
	  AS debcamp, dccp.debcamp_reason, dcfp.food, dcfp.food_id,
	  dctss.t_shirt_size, cpt.arrival_from, dccp.travel_to_venue,
	  dccp.travel_from_venue, cpt.arrival_date,
	  cpt.departure_date, 
	  cpt.arrival_time, cpt.departure_time,
	  cpt.travel_cost AS total_cost,
	  cpt.travel_currency AS total_cost_currency, cpt.fee AS
	  cantfund, cpt.fee_currency AS cantfund_currency,
	  date_part('days'::text, age(cpt.arrival_date::timestamp with
	  time zone, cpt.departure_date::timestamp with time zone)) AS
	  days, cp.reconfirmed
   FROM person p
   JOIN conference_person cp USING (person_id)
   JOIN debconf.dc_conference_person dccp USING (person_id)
   JOIN debconf.dc_person_type dcpt USING (person_type_id)
   JOIN debconf.dc_accomodation dca USING (accom_id)
   JOIN conference_person_travel cpt USING (conference_person_id)
   LEFT JOIN debconf.dc_view_participant_map dcvpm ON
   dccp.dc_participant_category_id = dcvpm.participant_mapping_id
   JOIN debconf.dc_debcamp dcd USING (debcamp_id)
   JOIN debconf.dc_food_preferences dcfp USING (food_id)
   JOIN debconf.dc_t_shirt_sizes dctss USING (t_shirt_sizes_id)
  WHERE cp.conference_id = 4 AND dccp.conference_id = 4;
COMMIT;
