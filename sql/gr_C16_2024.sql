WITH dict_pdiagnosis AS
(SELECT code,
       description
  FROM core.dim_rpt_dictionary_values
 WHERE is_current = 'Y'
   AND dictionary_id = 'cc31990d-4ce3-4d93-9443-e96b97ba65b0'), -- основний_діагноз
dict_service AS   
(SELECT packet_number, service_number, name
	FROM analytics.ref_pmg_coefficients_services
   where is_current = 'Y' and year = '2024'
     and packet_number IN ('3','47','57')
group by 1,2,3)   

SELECT ec.packet_number,
       registration_area,
	   e.edrpou,
	   public_name,
	   adrg,
	   CONCAT(service_number, ' - ', name) AS service,
	   CONCAT(principal_diagnosis, ' - ', description) AS основний_діагноз,
       COUNT (DISTINCT patient_id) AS кількість_унікальних_пацієнтів
	   --event_id,
	   --report_month,
	   --is_payment	  
  FROM analytics.rds_pmg_events_2024 AS e
       JOIN analytics.rds_pmg_events_checks_2024 AS ec USING(id)
	   LEFT JOIN dict_pdiagnosis AS dp ON e.principal_diagnosis = dp.code
	   LEFT JOIN dict_service AS ds USING(service_number)
	   LEFT JOIN analytics.dwh_legal_entities_edrpou_view AS ev ON ev.edrpou = e.edrpou
 WHERE is_correct
   AND adrg LIKE 'C16%'	  
 GROUP BY  1,2,3,4,5,6,7