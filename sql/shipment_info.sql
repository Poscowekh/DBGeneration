select
       s.id as shipment_id,
       t.id as truck_id,

       co.id as courier_id,
       co.name as courier_name,
       co.phone_number as courier_phone_number,

       o.status as overall_order_status,
       o.id as order_id,
       count(cl.id) as clothing_count,
       o.due_date - o.creation_date as days_left

from
    (
    select id, truck_id
    from dryclean.shipments
    ) as s

    join (
        select id, courier_id
        from dryclean.trucks
        ) as t
        on s.truck_id = t.id

    join (
        select id, name, phone_number
        from dryclean.couriers
        ) as co
        on t.courier_id = co.id

    join (
        select id, order_id, shipment_id
        from dryclean.clothing
        ) as cl
        on s.id = cl.shipment_id

    join (
        select id, creation_date, due_date, status
        from dryclean.orders
        where actual_finish_date is null
        ) as o
        on cl.order_id = o.id

group by s.id, t.id,
         co.id, co.name, co.phone_number,
         o.status, o.id, o.due_date - o.creation_date

order by s.id, days_left desc, clothing_count desc;