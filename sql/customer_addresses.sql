select
       s.shipment_id,
       s.truck_id,
       cl.order_id,
       t.courier_id,

from (
        select id, truck_id
        from dryclean.shipments
        where truck_id is not null and
              type == 'sorting_department_to_customer'
    ) as s

join (
        select id, courier_id
        from dryclean.trucks
        where courier_id is not null and
              is_in_working_condition
    ) as t
    on t.id = s.truck_id
join (
        select id, name, phone_number
        from dryclean.couriers
        where is_active
    ) as co
    on co.id = t.courier_id

join dryclean.clothing
    as cl ( id, shipment_id, order_id )
    on s.id = cl.shipment_id
join dryclean.orders
    as o ( id, customer_id, delivery_comment )
    on cl.order_id = o.id
join dryclean.customers
    as cu ( id, name, address, phone_number )
    on o.customer_id = cu.id

where


group by truck_id, customer_id, order_id
order by truck_id, customer_id, order_id;
