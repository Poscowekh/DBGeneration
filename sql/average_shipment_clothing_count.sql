drop table if exists clothing_and_shipment_ids;

create temp table clothing_and_shipment_ids as
    select id, shipment_id
    from clothing
    join shipments s
        on shipment_id == s.id
    where shipment_id is not null
    group by shipment_id;

