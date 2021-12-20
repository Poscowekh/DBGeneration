create schema if not exists dryclean;

create sequence if not exists dryclean.buildings_id_seq;

create table if not exists dryclean.buildings (
    id bigint default nextval('dryclean.buildings_id_seq') primary key,

    address char(100) not null,
    phone_number char(20) not null,
    requires_shipment boolean not null default false,

    constraint "insertion into base table is not allowed"
        check ( false ) no inherit,

    constraint "address and phone number pair must be unique"
        unique ( address, phone_number )
);

create table if not exists dryclean.departments (
    id bigint default nextval('dryclean.buildings_id_seq') primary key
) inherits ( dryclean.buildings );

create table if not exists dryclean.sorting_departments (
    id bigint default nextval('dryclean.buildings_id_seq') primary key
) inherits ( dryclean.buildings );

create table if not exists dryclean.cleaning_departments (
    id bigint default nextval('dryclean.buildings_id_seq') primary key,

    acceptable_clothing_types char(400) not null,
    acceptable_defect_types char(400) not null
) inherits ( dryclean.buildings );


create sequence if not exists dryclean.person_id_seq;

create table if not exists dryclean.people (
    id bigint default nextval('dryclean.person_id_seq') primary key,

    name char(40) not null,
    phone_number char(20) not null unique,
    email char(40) unique,

    constraint "insertion into base table is not allowed" check ( false ) no inherit
);

create table if not exists dryclean.managers (
    id bigint default nextval('dryclean.person_id_seq') primary key,

    department_id bigint not null
        references dryclean.departments(id)
            on delete restrict,

    position char(30),
    is_active boolean not null default false,

    constraint "manager must have an email"
        check ( email is not null ),

    constraint "manager must have a position if is active"
        check ( not( is_active and position is null ) ),

    constraint "manager phone number must be unique"
        unique ( phone_number ),

    constraint "manager email must be unique"
        unique ( email )
) inherits ( dryclean.people );

create table if not exists dryclean.customers (
    id bigint default nextval('dryclean.person_id_seq') primary key,

    address char(100) unique,
    is_banned boolean not null default false,

    constraint "customer must have an email or an address"
        check ( address is not null or email is not null ),

    constraint "customer phone number must be unique"
        unique ( phone_number ),

    constraint "customer email nmust be unique"
        unique ( email )
) inherits ( dryclean.people );

create table if not exists dryclean.couriers (
    id bigint default nextval('dryclean.person_id_seq') primary key,

    is_active boolean not null default false,

    constraint "courier phone number must be unique"
        unique ( phone_number ),

    constraint "customer email must be unique"
        unique ( email )
) inherits ( dryclean.people );


create table if not exists dryclean.trucks (
    id bigserial primary key,

    courier_id bigint unique
        references dryclean.couriers(id)
            on delete set null,

    label char(20),
    is_in_working_condition boolean not null default true,

    constraint "trucks that are not in working condition can not be driven"
        check ( not( not is_in_working_condition and courier_id is not null ) )
);

create table if not exists dryclean.orders (
    id bigserial primary key,

    customer_id bigint not null
        references dryclean.customers(id)
            on delete cascade,
    department_id bigint not null
        references dryclean.departments(id)
            on delete set null,
    manager_id bigint not null
        references dryclean.managers(id)
            on delete set null,

    creation_date date not null,
    due_date date not null,
    actual_finish_date date,

    status char(30) not null,

    is_prepayed boolean not null default false,
    is_express boolean not null default false,
    to_be_delievered boolean not null default false,

    customer_comment char(200),
    delivery_comment char(200),

    constraint "can not have delivery comment while not specified as a delivery"
        check ( not( not to_be_delievered and delivery_comment is not null ) ),

    constraint "can not be due to be finished before or at creation date"
        check ( creation_date < due_date ),

    constraint "can not be finished before or at creation date"
        check ( creation_date < actual_finish_date )
);

create table if not exists dryclean.shipments (
    id bigserial primary key,

    department_id bigint
        references dryclean.departments(id)
            on delete restrict,
    sorting_department_id bigint not null
        references dryclean.sorting_departments(id)
            on delete restrict,
    cleaning_department_id bigint
        references dryclean.cleaning_departments(id)
            on delete restrict,
    truck_id bigint unique
        references dryclean.trucks(id)
            on delete restrict,

    type char(100) not null,
    is_on_route boolean not null default false,

    constraint "cleaning dpt and dpt must not be specified together"
        check ( not( cleaning_department_id is not null and department_id is not null ) ),

    constraint "can not be on route without a truck specified"
        check ( not( is_on_route and truck_id is null ) )
);

create table if not exists dryclean.clothing (
    id bigserial primary key,

    order_id bigint not null
        references dryclean.orders(id)
            on delete cascade,
    shipment_id bigint
        references dryclean.shipments(id)
            on update set null,

    status char(30) NOT NULL,

    type char(200),
    defect_type char(200),
    name char(50),
    comment char(200)
);
