
CREATE OR REPLACE VIEW view_event_state_statistic AS
  SELECT
    conference_id,
    event_state,
    count(event_state) AS count
  FROM
    event_state
    INNER JOIN event USING( event_state )
  GROUP BY conference_id, event_state;

