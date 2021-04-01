-- \i /home/abhisek/Documents/project/query1.sql

select distinct acquired_object_id 
from acquisitions
where acquiring_object_id = 'x'
order by acquired_object_id desc;

select distinct investor_object_id
from investments
where funded_object_id = 'x'
order by investor_object_id desc;

select distinct person_object_id
from relationships
where relationship_object_id = 'x'
order by person_object_id desc;

select f.milestone_at, f.description
from milestones as f
where f.object_id = 'x'
order by f.milestone_at asc;

select acquiring_object_id, acquired_object_id, price_amount, price_currency_code, acquired_at
from acquisitions
where acquired_object_id = 'x'
order by acquiring_object_id desc;