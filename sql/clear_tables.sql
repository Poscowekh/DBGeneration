truncate table
    dryclean.clothing,
    dryclean.orders,
    dryclean.shipments,
    dryclean.trucks,
    dryclean.people,
    dryclean.buildings
restart identity
cascade;

alter sequence dryclean.buildings_id_seq restart;
alter sequence dryclean.person_id_seq restart;
