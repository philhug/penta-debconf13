BEGIN;

CREATE OR REPLACE VIEW debconf.dc_view_person_rating AS
SELECT person.person_id,
       conference_person.conference_id ,
       COALESCE(rating.speaker_quality, 0::bigint) AS quality,
       COALESCE(rating.speaker_quality_count, 0::bigint) AS quality_count,
       COALESCE(rating.competence, 0::bigint) AS competence,
       COALESCE(rating.competence_count, 0::bigint) AS competence_count,
       (COALESCE(rating.speaker_quality, 0::bigint) + COALESCE(rating.competence, 0::bigint)) / 2 AS rating
    FROM person
    JOIN conference_person USING (person_id)
    LEFT JOIN (
         SELECT person_rating.person_id,
            COALESCE(sum((person_rating.speaker_quality - 3) * 50) / count(person_rating.speaker_quality), 0::bigint) AS speaker_quality,
            count(person_rating.speaker_quality) AS speaker_quality_count,
            COALESCE(sum((person_rating.competence - 3) * 50) / count(person_rating.competence), 0::bigint) AS competence,
            count(person_rating.competence) AS competence_count,
            count(COALESCE(person_rating.speaker_quality::text, person_rating.competence::text, person_rating.remark)) AS raters
           FROM person_rating GROUP BY person_rating.person_id) rating USING (person_id)
    ORDER BY COALESCE(rating.speaker_quality, 0::bigint) DESC,
             COALESCE(rating.competence, 0::bigint) DESC;


COMMIT;

BEGIN;
CREATE OR REPLACE VIEW debconf.dc_view_report_expenses AS
 SELECT DISTINCT conference_person.person_id,
		view_person.name,
		conference_person.conference_id,
		conference_person_travel.travel_cost,
		conference_person_travel.travel_currency,
		conference_person_travel.accommodation_cost,
		conference_person_travel.accommodation_currency,
		conference_person_travel.fee,
		conference_person_travel.fee_currency,
		debconf.dc_view_person_rating.quality,
		debconf.dc_view_person_rating.quality_count,
		debconf.dc_view_person_rating.competence,
		debconf.dc_view_person_rating.competence_count,
		debconf.dc_view_person_rating.rating
   FROM conference_person_travel
   JOIN conference_person USING (conference_person_id)
   JOIN view_person USING (person_id)
   JOIN debconf.dc_view_person_rating USING (person_id)
  WHERE conference_person_travel.need_travel_cost = true
	AND conference_person_travel.travel_cost IS NOT NULL
	OR conference_person_travel.need_accommodation_cost = true
	AND conference_person_travel.accommodation_cost IS NOT NULL
	OR conference_person_travel.fee IS NOT NULL
ORDER BY person_id, conference_id;
COMMIT;



--- New one that should limit on people that ticked the "need_travel_cost" before may 1st:
BEGIN;
CREATE OR REPLACE VIEW debconf.dc_view_report_expenses AS
 SELECT DISTINCT conference_person.person_id,
		view_person.name,
		conference_person.conference_id,
		conference_person_travel.travel_cost,
		conference_person_travel.travel_currency,
		conference_person_travel.accommodation_cost,
		conference_person_travel.accommodation_currency,
		conference_person_travel.fee,
		conference_person_travel.fee_currency,
		debconf.dc_view_person_rating.quality,
		debconf.dc_view_person_rating.quality_count,
		debconf.dc_view_person_rating.competence,
		debconf.dc_view_person_rating.competence_count,
		debconf.dc_view_person_rating.rating
   FROM conference_person_travel
   JOIN conference_person USING (conference_person_id)
   JOIN view_person USING (person_id)
   JOIN debconf.dc_view_person_rating USING (person_id)
   LEFT JOIN log.conference_person_travel as c using (conference_person_id)
   LEFT JOIN log.log_transaction as t using (log_transaction_id, person_id)
  WHERE conference_person_travel.need_travel_cost = true
	AND conference_person_travel.travel_cost IS NOT NULL
	OR conference_person_travel.need_accommodation_cost = true
	AND conference_person_travel.accommodation_cost IS NOT NULL
	OR conference_person_travel.fee IS NOT NULL
    AND ( c.log_operation = 'U' and
		  t.log_timestamp < '2009-05-01' and
		  c.need_travel_cost = 't' )
 ORDER BY person_id, conference_id
;
COMMIT;

--- and another new one

BEGIN;
CREATE OR REPLACE VIEW debconf.dc_view_report_expenses AS
 SELECT DISTINCT conference_person.person_id,
		view_person.name,
		conference_person.conference_id,
		conference_person_travel.travel_cost,
		conference_person_travel.travel_currency,
		conference_person_travel.accommodation_cost,
		conference_person_travel.accommodation_currency,
		conference_person_travel.fee,
		conference_person_travel.fee_currency,
		debconf.dc_view_person_rating.quality,
		debconf.dc_view_person_rating.quality_count,
		debconf.dc_view_person_rating.competence,
		debconf.dc_view_person_rating.competence_count,
		debconf.dc_view_person_rating.rating
   FROM conference_person_travel
   JOIN conference_person USING (conference_person_id)
   JOIN view_person USING (person_id)
   JOIN debconf.dc_view_person_rating USING (person_id)
   LEFT JOIN log.conference_person_travel as c using (conference_person_id)
   LEFT JOIN log.log_transaction as t using (log_transaction_id, person_id)
  WHERE ( (conference_person_travel.need_travel_cost = true
	AND conference_person_travel.travel_cost IS NOT NULL)
	OR (conference_person_travel.need_accommodation_cost = true
	AND conference_person_travel.accommodation_cost IS NOT NULL)
	OR conference_person_travel.fee IS NOT NULL)
    AND ( c.log_operation = 'U' and
		  t.log_timestamp < '2009-05-01' and
		  c.need_travel_cost = 't' )
 ORDER BY person_id, conference_id
;


select t.log_timestamp,
COALESCE(p.public_name, ((COALESCE(p.first_name || ''::text, ''::text) || p.last_name)::character varying)::text, p.nickname) AS name,
c.need_travel_cost
from log.conference_person as cp
join log.log_transaction as t using (log_transaction_id, person_id)
join log.conference_person_travel as c using (conference_person_id)
join person as p using (person_id)
join debconf.dc_conference_person as dc using (person_id, conference_id)
where conference_id = 3 and
c.log_operation = 'U' and
t.log_timestamp < '2009-04-15' and
c.need_travel_cost = 't';
