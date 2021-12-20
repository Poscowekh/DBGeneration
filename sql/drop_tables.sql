drop table if exists
    dryclean.clothing,
    dryclean.orders,
    dryclean.shipments,
    dryclean.trucks,
    dryclean.people,
    dryclean.buildings
cascade;

drop sequence if exists dryclean.buildings_id_seq cascade;

drop sequence if exists dryclean.people_id_seq cascade;
