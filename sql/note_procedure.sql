WITH pr AS 
(SELECT event_id,
        --id,
        unnest(proc_id) as proc_id
   FROM analytics.rds_pmg_events_2024 AS e
        JOIN analytics.rds_pmg_events_checks_2024 AS ec USING(id)
  WHERE is_correct
    AND adrg LIKE 'C16%')

SELECT pr.event_id,
       --pr.id,
       array_to_string(array_agg(note) FILTER (WHERE note IS NOT NULL),'; ') AS procedures
  FROM pr
       LEFT JOIN core.dim_med_procedures AS p ON pr.proc_id = p.id
 WHERE p.is_current = 'Y'      
 GROUP BY pr.event_id 
          --pr.id
