-- This does two things:
-- - change conference_id to 6 in two places
-- - add cp.arrived to the query (request since last year)
--
-- The view definition this is based off of was found from \d debconf.dc_view_numbers

BEGIN TRANSACTION; 

-- debconf.dc_view_numbers is the only view to be modified here, but
-- as we are changing the number of columns, we cannot REPLACE it
-- in-place: We must drop+(re)create everything it depends on.
DROP VIEW debconf.dc_view_participant_changes;
DROP VIEW debconf.dc_view_numbers;

CREATE VIEW debconf.dc_view_numbers AS
  SELECT p.person_id AS id, COALESCE(p.public_name, ((COALESCE(p.first_name || ' '::text, ''::text) || p.last_name)::character varying)::text, p.nickname) AS name,
        p.nickname AS nick,
        p.city,
        p.email,
        ( SELECT country_localized.name
           FROM country_localized
          WHERE p.country = country_localized.country AND country_localized.translated = 'en'::text) AS country,
        dcpt.description AS status,
	ddr.description AS role_in_debian,
	ddcr.description AS role_in_debconf,
        dca.accom,
        dca.accom_id,
        dccp.attend,
        dcvpm.participant_category,
        dcd.debcamp_option AS debcamp,
        dccp.debcamp_reason,
        dcfp.food,
        dcfp.food_id,
        dctss.t_shirt_size,
        cpt.arrival_from,
        dccp.travel_to_venue,
        dccp.travel_from_venue,
        cpt.arrival_date,
        cpt.departure_date,
        cpt.arrival_time,
        cpt.departure_time,
        cpt.travel_cost AS total_cost,
        cpt.travel_currency AS total_cost_currency,
        cpt.fee AS cantfund,
        cpt.fee_currency AS cantfund_currency,
        date_part('days'::text, age(cpt.arrival_date::timestamp with time zone, cpt.departure_date::timestamp with time zone)) AS days,
        cp.reconfirmed
   FROM person p
   JOIN conference_person cp USING (person_id)
   JOIN debconf.dc_conference_person dccp USING (person_id)
   LEFT JOIN debconf.dc_person_type dcpt USING (person_type_id) -- Will be empty, but we don't want to break existing code
   JOIN debconf.dc_debian_role ddr USING (debian_role_id)
   JOIN debconf.dc_debconf_role ddcr USING (debconf_role_id)
   JOIN debconf.dc_accomodation dca USING (accom_id)
   JOIN conference_person_travel cpt USING (conference_person_id)
   LEFT JOIN debconf.dc_view_participant_map dcvpm ON dccp.dc_participant_category_id = dcvpm.participant_mapping_id
   JOIN debconf.dc_debcamp dcd USING (debcamp_id)
   JOIN debconf.dc_food_preferences dcfp USING (food_id)
   JOIN debconf.dc_t_shirt_sizes dctss USING (t_shirt_sizes_id)
  WHERE cp.conference_id = 6 AND dccp.conference_id = 6;

CREATE VIEW debconf.dc_view_participant_changes AS
  SELECT llt.log_transaction_id, llt.log_timestamp, ldccp.attend, 
    llt.person_id AS actor_id, 
    ( SELECT dcvn.name FROM debconf.dc_view_numbers dcvn WHERE dcvn.id = llt.person_id) 
      AS actor_name,
    lcp.person_id, dcvn.name, dcvpm.participant_category, dcfp.food, dca.accom,
    lcpt.need_travel_cost, lcpt.travel_cost, lcpt.travel_currency, lcpt.fee, 
    lcpt.fee_currency, lcp.reconfirmed, ldccp.room_preference, lcp.arrived
   FROM log.log_transaction llt
     JOIN log.conference_person lcp ON lcp.log_transaction_id = llt.log_transaction_id
     LEFT JOIN debconf.dc_view_numbers dcvn ON lcp.person_id = dcvn.id
     FULL JOIN log.dc_conference_person ldccp ON ldccp.log_transaction_id = llt.log_transaction_id
     FULL JOIN debconf.dc_view_participant_map dcvpm ON ldccp.dc_participant_category_id = dcvpm.participant_mapping_id
     FULL JOIN debconf.dc_food_preferences dcfp ON ldccp.food_id = dcfp.food_id AND ldccp.conference_id = dcfp.conference_id
     FULL JOIN debconf.dc_accomodation dca ON ldccp.accom_id = dca.accom_id AND ldccp.conference_id = dca.conference_id
     FULL JOIN log.conference_person_travel lcpt ON lcpt.log_transaction_id = llt.log_transaction_id
  WHERE llt.log_timestamp >= '2010-02-03 18:08:38'::timestamp without time zone
  ORDER BY llt.log_timestamp;
GRANT SELECT ON debconf.dc_view_participant_changes TO readonly;
GRANT SELECT ON debconf.dc_view_numbers TO readonly;

COMMIT TRANSACTION;
