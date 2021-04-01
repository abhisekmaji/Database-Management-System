select acquiring_object_id, acquired_object_id, term_code, price_amount, price_currency_code, acquired_at
from acquisitions
where (acquiring_object_id = 'x' and acquired_object_id = 'y') 
    or (acquiring_object_id = 'y' and acquired_object_id = 'x')
order by acquired_at asc;