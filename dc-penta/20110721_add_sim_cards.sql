ALTER TABLE base.dc_conference_person ADD COLUMN has_sim_card boolean NOT NULL DEFAULT FALSE;
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_conference_person::has_sim_card', 'en', 'Has received a SIM card?');
INSERT INTO ui_message_localized (ui_message, translated, name) VALUES ('table::dc_view_find_person_entrance::has_sim_card', 'en', 'Has received a SIM card?');
DROP VIEW debconf.dc_view_find_person_entrance;
CREATE VIEW debconf.dc_view_find_person_entrance AS
       SELECT view_person.person_id, view_person.name,
             view_person.first_name, view_person.last_name,
      view_person.nickname, view_person.public_name,
      view_person.email, view_person.gender,
      conference_person.conference_id,
      conference_person.conference_person_id,
      dc_conference_person.badge, dc_conference_person.foodtickets,
      dc_conference_person.has_to_pay, dc_conference_person.has_paid,
      dc_conference_person.amount_to_pay, dc_conference_person.shirt,
      dc_conference_person.bag, dc_conference_person.proceedings,
      dc_conference_person.proceeded, conference_person.arrived,
      conference_person.reconfirmed, dc_conference_person.paiddaytrip,
      dc_conference_person.has_sim_card
   FROM view_person
   LEFT JOIN conference_person USING (person_id)
   LEFT JOIN debconf.dc_conference_person USING (person_id, conference_id);
