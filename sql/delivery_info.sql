select
       co.id as courier_id,
       co.name as courier_name,
       co.phone_number as courier_phone_number,
       t.id as truck_id,

       cu.id as customer_id,
       cu.name as customer_name,
       cu.address as customer_address,
       cu.phone_number as customer_phone_number,

       order_id,
       count(cl.id) as clothing_count,
       delivery_comment

from (
    select id,
           name,
           phone_number
    from dryclean.couriers
    where is_active
    ) as co

join (
    select id,
           courier_id
    from dryclean.trucks
    where is_in_working_condition and
          courier_id is not null
    ) as t
    on co.id = t.courier_id

join (
    select id,
           truck_id
    from dryclean.shipments
    where truck_id is not null
    ) as s
    on t.id = s.truck_id

join (
    select id,
           order_id,
           shipment_id
    from dryclean.clothing
    ) as cl
    on s.id = cl.shipment_id

join (
    select id,
           customer_id,
           delivery_comment
    from dryclean.orders
    where actual_finish_date is null and
          to_be_delievered
    ) as o
    on cl.order_id = o.id

join (
    select id,
           name,
           address,
           phone_number
    from dryclean.customers
    ) as cu
    on o.customer_id = cu.id

group by co.id,
         co.name,
         co.phone_number,
         t.id,
         o.id,
         delivery_comment,
         cl.order_id,
         cu.id,
         cu.name,
         cu.address,
         cu.phone_number

order by co.id,
         cu.id,
         o.id;

