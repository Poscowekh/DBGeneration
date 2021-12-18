create schema if not exists dryclean;


create table if not exists dryclean.buildings (
    id bigserial primary key,

    address char(100) not null unique,
    phone_number char(15) not null unique,
    requires_shipment boolean not null default false
);

create table if not exists dryclean.departments (
    id bigserial primary key
)
    inherits ( dryclean.buildings );

create table if not exists dryclean.sorting_departments (
    id bigserial primary key
) inherits ( dryclean.buildings );

create table if not exists dryclean.cleaning_departments (
    id bigserial primary key,

    acceptable_clothing_types char(400) not null,
    acceptable_defect_types char(400) not null
) inherits ( dryclean.buildings );


create table if not exists dryclean.people (
    id bigserial primary key,

    name char(50) not null,
    phone_number char(15) not null unique,
    email char(50) unique
);

create table if not exists dryclean.managers (
    id bigserial primary key,

    department_id bigint not null references dryclean.departments(id)
        on delete set null,

    position char(50),
    is_active boolean not null default false,

    constraint "manager must have an email" CHECK ( email is not null ),
    constraint "manager must have a position if is active" check ( is_active and position is not null)
) inherits ( dryclean.people );

create table if not exists dryclean.customers (
    id bigserial primary key,

    address char(100) unique,
    is_banned boolean not null default false,

    constraint "customer must have an email or an address" check ( address is not null or email is not null )
) inherits ( dryclean.people );

create table if not exists dryclean.couriers (
    id bigserial primary key,

    is_active boolean not null default false
) inherits ( dryclean.people );


create table if not exists dryclean.trucks (
    id bigserial primary key,

    courier_id bigint unique references dryclean.couriers(id)
        on delete set null
        on update set null,

    label char(20),
    is_in_working_condition boolean not null default true,

    constraint "trucks that are not in working condition can not be driven"
        check ( courier_id is not null and not is_in_working_condition )
);

create table if not exists dryclean.shipments (
    id bigserial primary key,

    department_id bigint references dryclean.departments(id),
    sorting_department_id bigint references dryclean.sorting_departments(id),
    cleaning_department_id bigint references dryclean.cleaning_departments(id),
    truck_id bigint unique references dryclean.trucks(id),

    type char(200) not null,
    is_on_route boolean not null default false,

    constraint "there must be two and only two building ids specified"
        check (
            department_id is not null and sorting_department_id is not null and cleaning_department_id is null
            or
            department_id is not null and sorting_department_id is null and cleaning_department_id is not null
            or
            department_id is null and  sorting_department_id is not null and  cleaning_department_id is not null
        ),

    constraint "can not be on route without a truck specified" check ( not ( is_on_route and truck_id is null) )
);

create table if not exists dryclean.orders (
    id bigserial primary key,

    customer_id bigint not null references dryclean.customers(id),
    department_id bigint not null references dryclean.departments(id),

    creation_date date not null,
    due_date date not null,
    actual_finish_date date,

    is_prepayed boolean not null default false,
    is_express boolean not null default false,
    to_be_delievered boolean not null default false,

    customer_comment char(200),
    delivery_comment char(200),

    constraint "can not have delivery comment while not specified as a delivery"
        check ( delivery_comment is not null and not to_be_delievered ),

    constraint "can not be due to be finished before creation date" check ( creation_date > due_date ),
    constraint "can not be finished before creation date" check ( creation_date > creation_date )
);

create table if not exists dryclean.clothing (
    id bigserial primary key,

    order_id bigint not null references dryclean.orders(id),
    shipment_id bigint references dryclean.shipments(id),

    type char(200),
    defect_type char(200),
    name char(50),
    comment char(200)
);
