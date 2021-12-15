create schema if not exists dryclean;

create table if not exists dryclean._facilities (
    id bigserial primary key,

    address char(100) not null unique,
    phone_number char(15) not null unique,
    requires_shipment boolean not null default false
);

create table if not exists dryclean._people (
    id bigserial primary key,

    name char(50) not null,
    phone_number char(15) not null unique
);

create table if not exists dryclean.departments (
    like dryclean._facilities
        including constraints
        including indexes
);

create table if not exists dryclean.sorting_facilities (
    like dryclean._facilities
        including constraints
        including indexes
);

create table if not exists dryclean.cleaning_facilities (
    like dryclean._facilities
        including constraints
        including indexes,

    acceptable_clothing_types char(400) not null,
    acceptable_defect_types char(400) not null
);

create table if not exists dryclean.managers (
    like dryclean._people
        including constraints
        including indexes,

    department_id bigint not null references dryclean.departments(id),

    position char(50) not null,
    email char(50) not null unique
);

create table if not exists dryclean.customers (
    like dryclean._people
        including constraints
        including indexes,

    address char(100) unique,
    email char(50) not null unique,
    is_banned boolean not null default false
);

create table if not exists dryclean.couriers (
    like dryclean._people
        including constraints
        including indexes,

    is_active boolean not null default false
);

create table if not exists dryclean.trucks (
    id bigserial primary key,

    courier_id bigint references dryclean.couriers(id),

    label char(20),
    is_in_working_condition boolean not null default true
);

create table if not exists dryclean.shipments (
    id bigserial primary key,

    department_id bigint references dryclean.departments(id),
    sorting_facility_id bigint references dryclean.sorting_facilities(id),
    cleaning_facility_id bigint references dryclean.cleaning_facilities(id),
    truck_id bigint references dryclean.trucks(id),

    origin char(200) not null,
    destination char(200) not null check ( destination != origin ),
    is_on_route boolean not null default false,

    check (
        (
            department_id is not null and
            sorting_facility_id is not null and
            cleaning_facility_id is null
        )
        or
        (
            department_id is not null and
            sorting_facility_id is null and
            cleaning_facility_id is not null
        )
        or
        (
            department_id is null and
            sorting_facility_id is not null and
            cleaning_facility_id is not null
        )
    ),

    check ( not ( is_on_route and truck_id is null) )
);

create table if not exists dryclean.orders (
    id bigserial primary key,

    customer_id bigint not null references dryclean.customers(id),
    department_id bigint not null references dryclean.departments(id),

    creation_date date not null,
    due_date date not null check ( due_date > creation_date ),
    actual_finish_date date check ( actual_finish_date > creation_date ),

    is_prepayed boolean not null default false,
    is_express boolean not null default false,
    to_be_delievered boolean not null default false,

    customer_comment char(200),
    delivery_comment char(200),

    check ( not (delivery_comment is not null and not to_be_delievered) )
);

create table if not exists dryclean.comments (
    id bigserial primary key,

    order_id bigint not null references dryclean.orders(id),
    customer_id bigint not null references dryclean.customers(id),
    manager_id bigint references dryclean.managers(id),
    courier_id bigint references dryclean.couriers(id),
    previous_comment_id bigint references dryclean.comments(id) check ( previous_comment_id < id),

    order_score int check ( 1 <= order_score <= 10 ),
    customer_text char(500) not null,
    manager_text char(500),
    date timestamp not null,
    reply_date timestamp check ( reply_date > date ),
    upvotes int not null default 0,
    is_anonymous boolean not null default false,

    check (
        (
            manager_id is null and
            manager_text is null and
            reply_date is null
        )
        or
        (
            manager_id is not null and
            manager_text is not null and
            reply_date is not null
        )
    ),

    unique (order_id, courier_id)
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