select
       s.building_id,
       b.requires_shipment,
       count(distinct c.id) as clothing_count,
       count(distinct o.id) as order_count,
       count(distinct s.id) as shipments_waiting_count

from
     (
     select id, order_id, shipment_id
     from dryclean.clothing
     ) as c

join (
    select id,
           department_id as building_id
    from dryclean.shipments
    where not is_on_route and
          type = 'department_to_sorting_department'

    union
    select id,
           sorting_department_id as building_id
    from dryclean.shipments
    where not is_on_route and
          type = 'sorting_department_to_cleaning_department' or
          type = 'sorting_department_to_department' or
          type = 'sorting_department_to_customer'


    union
    select id,
           cleaning_department_id as building_id
    from dryclean.shipments
    where not is_on_route and
          type = 'cleaning_department_to_sorting_department'
    ) as s
    on c.shipment_id = s.id

join (
    select id
    from dryclean.orders
    where actual_finish_date is null
    ) as o
    on c.order_id = o.id

join (
    select id,
           requires_shipment
    from dryclean.buildings
    ) as b
    on s.building_id = b.id

group by s.building_id,
         b.requires_shipment

order by clothing_count desc,
         shipments_waiting_count desc,
         order_count desc,
         building_id;



