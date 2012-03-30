BEGIN;
DROP VIEW debconf.dc_view_find_person_entrance;
CREATE OR REPLACE VIEW debconf.dc_view_find_person_entrance AS
        SELECT view_person.person_id,
               view_person.name,
               view_person.first_name,
               view_person.last_name,
               view_person.nickname,
               view_person.public_name,
               view_person.email,
               view_person.gender,
               conference_person.conference_id,
               conference_person.conference_person_id,
               debconf.dc_conference_person.badge,
               debconf.dc_conference_person.foodtickets,
               debconf.dc_conference_person.has_to_pay,
               debconf.dc_conference_person.has_paid,
               debconf.dc_conference_person.amount_to_pay,
               debconf.dc_conference_person.shirt,
               debconf.dc_conference_person.bag,
               debconf.dc_conference_person.proceedings,
               debconf.dc_conference_person.proceeded,
               conference_person.arrived,
               conference_person.reconfirmed
        FROM view_person
                LEFT OUTER JOIN conference_person USING (person_id)
                LEFT OUTER JOIN debconf.dc_conference_person USING (person_id,conference_id);
COMMIT;

