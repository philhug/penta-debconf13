BEGIN;


ALTER TABLE base.dc_conference_person RENAME COLUMN paid to paid_amount;
ALTER TABLE base.dc_conference_person RENAME COLUMN paid_number to dc7_paid_for_days;

ALTER TABLE base.dc_conference_person ADD COLUMN has_paid BOOLEAN DEFAULT FALSE NOT NULL;
ALTER TABLE base.dc_conference_person ADD COLUMN has_to_pay BOOLEAN DEFAULT FALSE NOT NULL;
ALTER TABLE base.dc_conference_person ADD COLUMN amount_to_pay TEXT;

SELECT * FROM log.activate_logging();

COMMIT;

