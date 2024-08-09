СЛОВНИКИ:
**********************************************************

'profession' 
------------------------------------------------------------------
id - c53c21d9-76ed-45c8-a393-09000186446e
kwd_name - 'POSITION'

'diagnosis'
--------------------------------------------------------------------
id - 'cc31990d-4ce3-4d93-9443-e96b97ba65b0'
kwd_name - 'eHealth/ICD10_AM/condition_codes'






************************************************************
Пошук id словника (приклад):

SELECT dictionary_id
  FROM core.dim_rpt_dictionary_values
 WHERE is_current = 'Y'
 GROUP BY dictionary_id
HAVING 'P130' = ANY(ARRAY_AGG(code))
      AND 'P203' = ANY(ARRAY_AGG(code))