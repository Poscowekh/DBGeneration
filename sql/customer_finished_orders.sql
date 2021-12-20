select
       c.id,
       count(o.id) as finfished_order_count,
       current_date::date - min(o.creation_date) as membership_days,
       count(o.id)::float / (current_date::date - min(o.creation_date))::float * 30 as orders_per_month
from (
    select id, creation_date, customer_id
    from dryclean.orders
    where actual_finish_date is not null
    ) as o
    join (
        select id
        from dryclean.customers
        where not is_banned
        ) as c
        on c.id = o.customer_id
group by c.id
order by finfished_order_count desc, membership_days desc, c.id;
