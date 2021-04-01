select funding_round_id , funded_object_id, investor_object_id
from investments
where funded_object_id = 'x' and investor_object_id = 'y'
order by funding_round_id;