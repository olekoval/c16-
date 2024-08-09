drop table if exists pre_;
create temp table pre_ as
select id, unnest(proc_id) as proc_id from analytics.rds_pmg_events_checks_2024_dev ec
join analytics.rds_pmg_events_2024 e using(id)
where adrg in ('C01A','C02A','C16A') and is_target;
 
drop table if exists proc_note;
create temp table proc_note as
select pre_.id, string_agg(p.note,', ')
from pre_
left join core.dim_med_procedures p on proc_id = p.id and p.is_current = 'Y'
group by 1;