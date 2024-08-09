WITH pr AS 
(SELECT id,
       unnest(proc_id) as proc_id
  FROM analytics.rds_pmg_events_2024 AS e
       JOIN analytics.rds_pmg_events_checks_2024 AS ec USING(id)
 WHERE is_correct
   AND adrg LIKE 'C16%'	),
   
note AS
(SELECT id, 
        string_agg(note,', ') AS nt
   FROM core.dim_med_procedures 
  WHERE is_current = 'Y'
  GROUP BY 1)	   
  
SELECT id,
       array_agg(nt)
  FROM pr 
       LEFT JOIN note USING(id)
GROUP BY id	   
