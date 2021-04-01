select relationship_object_id as company_name, title as role , is_past as current_job_status
from relationships
where person_object_id = "x" and relationship_object_id like 'c%'
order by relationship_object_id desc, title desc;

select first_name, last_name, birthplace, affliation_name 
from people
where object_id = 'x';