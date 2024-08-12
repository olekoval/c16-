WITH dict_diagnosis AS -- словник діагнозів
(SELECT code,
        description
   FROM core.dim_rpt_dictionary_values
  WHERE is_current = 'Y'
    AND dictionary_id = 'cc31990d-4ce3-4d93-9443-e96b97ba65b0'), -- основний_діагноз
dict_service AS -- словник service
(SELECT packet_number, service_number, name
   FROM analytics.ref_pmg_coefficients_services 
  where is_current = 'Y' and year = '2024'
    and packet_number IN ('3','47','57')
  group by 1,2,3),
e AS 
(SELECT edrpou,
	event_id,
        patient_id,
	report_month,
	packet_number,
	adrg,
	service_number,
	proc_id,
        principal_diagnosis,
	array_to_string(e.actions, ',','') AS actions,
	is_payment	  	  
   FROM analytics.rds_pmg_events_2024 AS e
        JOIN analytics.rds_pmg_events_checks_2024 AS ec USING(id)
  WHERE is_correct
    AND adrg LIKE 'C16%'), -- операції на кришталику
note AS ( -- додавання нотатків до разгорнутих кодів proc_id з подальшім об'єднанням їх через ";" 
	      -- за допомогою групування по полю pr.event_id
SELECT pr.event_id,
       array_to_string(array_agg(note) FILTER (WHERE note IS NOT NULL),'; ') AS procedures
  FROM (SELECT event_id, unnest(proc_id) as proc_id FROM e) AS pr
       LEFT JOIN core.dim_med_procedures AS p ON pr.proc_id = p.id
 WHERE p.is_current = 'Y'      
 GROUP BY pr.event_id) 
   
 SELECT 
        ev.registration_area,
	e.edrpou,
	ev.public_name,
	e.patient_id,
	e.event_id,
	e.report_month,
	e.packet_number,
	e.adrg,
	CONCAT(e.service_number, ' - ', ds.name) AS service,
	n.procedures AS notes_procedures,
        CONCAT(principal_diagnosis, ' - ', description) AS principal_diagnosis,
	e.actions,		
	e.is_payment
   FROM e
        LEFT JOIN note AS n USING(event_id)
	LEFT JOIN dict_diagnosis AS dd ON e.principal_diagnosis = dd.code
	LEFT JOIN dict_service AS ds USING(service_number)
	LEFT JOIN analytics.dwh_legal_entities_edrpou_view AS ev ON ev.edrpou = e.edrpou
  ORDER BY registration_area, edrpou, report_month		
   
