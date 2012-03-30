SELECT DISTINCT person_id, t.log_timestamp
	FROM debconf.dc_conference_person dccp
	JOIN log.dc_conference_person cp USING(person_id)
	JOIN log.log_transaction t USING (log_transaction_id, person_id)
 WHERE cp.dc_participant_category_id IN ( 1, 2, 3, 4, 5 )
	AND cp.conference_id = 3
    AND ( ( cp.log_operation = 'U' OR cp.log_operation = 'I' )
and
		  t.log_timestamp < '2009-05-01' );






SELECT person_id,
		log_operation,
		conference_id,
		dc_participant_category_id,
		log_timestamp
	FROM log.dc_conference_person
	left join log.log_transaction USING (log_transaction_id, person_id)
 WHERE person_id in ( 231, 1327, 67, 954, 574, 1233, 249, 122, 342, 35, 374, 56, 1282) ;
