create temp table if not exists dryclean.not_banned_customers as
    select id
    from dryclean.customers
    where not is_banned;

select id
from dryclean.orders
join dryclean.not_banned_customers as c on c.id == customer_id
where actual_finish_date is not null
group by c.id;
