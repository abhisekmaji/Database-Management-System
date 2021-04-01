select funded_object_id
from investments
where investor_object_id = 'x'
order by funded_object_id desc;

select unique funded_object_id
from investments
where investor_object_id = 'x'
order by funded_object_id desc;