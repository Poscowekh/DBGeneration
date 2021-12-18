truncate table
    dryclean.buildings,
    dryclean.people,
    dryclean.orders,
    dryclean.shipments,
    dryclean.clothing,
    dryclean.trucks
restart identity
cascade;
