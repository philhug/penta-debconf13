BEGIN;

CREATE TABLE debconf.dc_person_data_lalala AS
SELECT 	p.person_id AS id,
		COALESCE(p.public_name, ((COALESCE(((p.first_name)::text || ''::text), ''::text) || (p.last_name)::text))::character varying, p.nickname) AS name,
		p.nickname AS nick,
		p.city AS city,
		p.email AS email,
		(SELECT country_localized.name FROM country_localized WHERE ((p.country = country_localized.country) AND (country_localized.translated = 'en'))) AS country,
		dcpt.description AS status,
		dca.accom AS accom,
		dccp.attend AS attend,
		dcvpm.participant_category AS participant_category,
		dcd.debcamp_option AS debcamp,
		dccp.debcamp_reason AS debcamp_reason,
		dcfp.food AS food,
		dctss.t_shirt_size AS t_shirt_size
FROM
	person p
	JOIN debconf.dc_conference_person dccp USING(person_id)
	JOIN debconf.dc_person_type dcpt USING(person_type_id)
	JOIN debconf.dc_accomodation dca USING(accom_id)
	LEFT OUTER JOIN debconf.dc_view_participant_map dcvpm ON(dccp.dc_participant_category_id = participant_mapping_id)
	JOIN debconf.dc_debcamp dcd USING(debcamp_id)
	JOIN debconf.dc_food_preferences dcfp USING(food_id)
	JOIN debconf.dc_t_shirt_sizes dctss USING(t_shirt_sizes_id)
WHERE dccp.conference_id = 2
;


--- From old:
CREATE VIEW view_numbers AS
			pt.arrival_date AS a_date,
			pt.arrival_from AS a_from,
			pt.arrival_to AS arrival_via,
			pt.departure_date AS d_date,
			pt.departure_from AS d_from,
			pt.travel_cost, cc2.iso_4217_code AS total_currency,
			pt.fee AS cant_fund,
			cc.iso_4217_code AS cantfund_currency,

			date_part('days'::text, age((pt.arrival_date)::timestamp with time zone, (pt.departure_date)::timestamp with time zone)) AS days,

	FROM ((((((((
			person p 
		JOIN person_type ptype USING (person_type_id))
		JOIN person_travel pt ON (((p.person_id = pt.person_id) AND (pt.conference_id = 1))))
		JOIN accomodation ac USING (accom_id))
		JOIN food_preferences f USING (food_id))
		JOIN currency cc ON ((pt.fee_currency_id = cc.currency_id)))
		JOIN currency cc2 ON ((pt.travel_currency_id = cc2.currency_id)))
		JOIN conference_person cp ON ((p.person_id = cp.person_id)))
		JOIN t_shirt_sizes ts ON ((p.t_shirt_sizes_id = ts.t_shirt_sizes_id))
);
--- End From old

COMMIT;
