CREATE OR REPLACE VIEW debconf.dc_view_person_not_arrived AS (
SELECT COALESCE(p.public_name, ((COALESCE(((p.first_name)::text || ''::text), ''::text) || (p.last_name)::text))::character varying, p.nickname) AS name, 
        p.person_id, 
        conference_person_travel.arrival_date 
FROM person p 
JOIN conference_person USING (person_id) 
JOIN conference_person_travel USING (conference_person_id) 
WHERE conference_id = 2 
        AND conference_person.arrived = false 
        AND conference_person_travel.arrival_date <= now() 
        AND conference_person.reconfirmed = TRUE);
