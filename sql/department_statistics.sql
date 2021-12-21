select
       o.department_id,
       count(o.id) as order_count,
       count(distinct manager_id) as manager_count,
       count(distinct customer_id) as customer_count,
       count(distinct c.id) as clothing_count

from (
     select id,
            department_id,
            customer_id,
            manager_id
     from dryclean.orders
     ) as o

left join (
    select id,
           order_id
    from dryclean.clothing
    ) as c
    on o.id = c.order_id

group by o.department_id

order by o.department_id;