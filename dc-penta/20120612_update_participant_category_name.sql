-- The advanced interface for find_person does searches only by
-- substring matching. Make sure no participant categories are exact
-- substrings of any others! :-P
--
-- I'm doing this only for the currently active conference.
BEGIN;
UPDATE debconf.dc_participant_category
   SET participant_category='Basic; want both sponsored food and accommodation'
   WHERE participant_category_id=22;
COMMIT;
