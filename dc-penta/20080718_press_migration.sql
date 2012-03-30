-- from view_dc_press.sql
BEGIN;

BEGIN;
ALTER TABLE debconf.dc_press ADD COLUMN id_check text;
UPDATE debconf.dc_press set id_check = MD5(RANDOM());
ALTER TABLE debconf.dc_conference_press DROP CONSTRAINT dc_press_id_fkey;
ALTER TABLE debconf.dc_conference_press ADD FOREIGN KEY (press_id) REFERENCES debconf.dc_press(press_id) ON DELETE CASCADE;
INSERT INTO auth."domain" values ('dc_press');
UPDATE auth.object_domain set "domain" = 'dc_press' where object = 'dc_press';
INSERT INTO auth.permission (permission) values ('delete_dc_press');
-- INSERT INTO auth.object_domain values ('dc_press', 'dc_press');
INSERT INTO auth.role_permission values ('press_admin', 'delete_dc_press');
COMMIT;

-- returns all press contacts of all conferences
CREATE OR REPLACE VIEW debconf.dc_view_press AS
	SELECT
		debconf.dc_press.press_id,
		debconf.dc_press.association,
		debconf.dc_press.name,
		debconf.dc_press.email,
		debconf.dc_press.phone,
		debconf.dc_press.street,
		debconf.dc_press.zip,
		debconf.dc_press.city,
		debconf.dc_press.country,
		debconf.dc_press.fax,
		debconf.dc_press.description,
		debconf.dc_press.notes,
		debconf.dc_press.url,
		debconf.dc_press.id_check,
		debconf.dc_conference_press.conference_id,
		debconf.dc_conference_press.local,
		debconf.dc_conference_press.person_id
  FROM debconf.dc_press
	INNER JOIN debconf.dc_conference_press USING (press_id);
COMMIT;
