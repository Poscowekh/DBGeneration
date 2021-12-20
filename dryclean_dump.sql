--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dryclean; Type: SCHEMA; Schema: -; Owner: any_user
--

CREATE SCHEMA dryclean;


ALTER SCHEMA dryclean OWNER TO any_user;

--
-- Name: buildings_id_seq; Type: SEQUENCE; Schema: dryclean; Owner: any_user
--

CREATE SEQUENCE dryclean.buildings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dryclean.buildings_id_seq OWNER TO any_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: buildings; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.buildings (
    id bigint DEFAULT nextval('dryclean.buildings_id_seq'::regclass) NOT NULL,
    address character(100) NOT NULL,
    phone_number character(20) NOT NULL,
    requires_shipment boolean DEFAULT false NOT NULL,
    CONSTRAINT "insertion into base table is not allowed" CHECK (false) NO INHERIT
);


ALTER TABLE dryclean.buildings OWNER TO any_user;

--
-- Name: cleaning_departments; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.cleaning_departments (
    id bigint DEFAULT nextval('dryclean.buildings_id_seq'::regclass),
    acceptable_clothing_types character(400) NOT NULL,
    acceptable_defect_types character(400) NOT NULL
)
INHERITS (dryclean.buildings);


ALTER TABLE dryclean.cleaning_departments OWNER TO any_user;

--
-- Name: clothing; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.clothing (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    shipment_id bigint,
    status character(30) NOT NULL,
    type character(200),
    defect_type character(200),
    name character(50),
    comment character(200)
);


ALTER TABLE dryclean.clothing OWNER TO any_user;

--
-- Name: clothing_id_seq; Type: SEQUENCE; Schema: dryclean; Owner: any_user
--

CREATE SEQUENCE dryclean.clothing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dryclean.clothing_id_seq OWNER TO any_user;

--
-- Name: clothing_id_seq; Type: SEQUENCE OWNED BY; Schema: dryclean; Owner: any_user
--

ALTER SEQUENCE dryclean.clothing_id_seq OWNED BY dryclean.clothing.id;


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: dryclean; Owner: any_user
--

CREATE SEQUENCE dryclean.person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dryclean.person_id_seq OWNER TO any_user;

--
-- Name: people; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.people (
    id bigint DEFAULT nextval('dryclean.person_id_seq'::regclass) NOT NULL,
    name character(40) NOT NULL,
    phone_number character(20) NOT NULL,
    email character(40),
    CONSTRAINT "insertion into base table is not allowed" CHECK (false) NO INHERIT
);


ALTER TABLE dryclean.people OWNER TO any_user;

--
-- Name: couriers; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.couriers (
    id bigint DEFAULT nextval('dryclean.person_id_seq'::regclass),
    is_active boolean DEFAULT false NOT NULL
)
INHERITS (dryclean.people);


ALTER TABLE dryclean.couriers OWNER TO any_user;

--
-- Name: customers; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.customers (
    id bigint DEFAULT nextval('dryclean.person_id_seq'::regclass),
    address character(100),
    is_banned boolean DEFAULT false NOT NULL,
    CONSTRAINT "customer must have an email or an address" CHECK (((address IS NOT NULL) OR (email IS NOT NULL)))
)
INHERITS (dryclean.people);


ALTER TABLE dryclean.customers OWNER TO any_user;

--
-- Name: departments; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.departments (
    id bigint DEFAULT nextval('dryclean.buildings_id_seq'::regclass)
)
INHERITS (dryclean.buildings);


ALTER TABLE dryclean.departments OWNER TO any_user;

--
-- Name: managers; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.managers (
    id bigint DEFAULT nextval('dryclean.person_id_seq'::regclass),
    department_id bigint NOT NULL,
    "position" character(30),
    is_active boolean DEFAULT false NOT NULL,
    CONSTRAINT "manager must have a position if is active" CHECK ((NOT (is_active AND ("position" IS NULL)))),
    CONSTRAINT "manager must have an email" CHECK ((email IS NOT NULL))
)
INHERITS (dryclean.people);


ALTER TABLE dryclean.managers OWNER TO any_user;

--
-- Name: orders; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.orders (
    id bigint NOT NULL,
    customer_id bigint NOT NULL,
    department_id bigint NOT NULL,
    manager_id bigint NOT NULL,
    creation_date date NOT NULL,
    due_date date NOT NULL,
    actual_finish_date date,
    status character(30) NOT NULL,
    is_prepayed boolean DEFAULT false NOT NULL,
    is_express boolean DEFAULT false NOT NULL,
    to_be_delievered boolean DEFAULT false NOT NULL,
    customer_comment character(200),
    delivery_comment character(200),
    CONSTRAINT "can not be due to be finished before or at creation date" CHECK ((creation_date < due_date)),
    CONSTRAINT "can not be finished before or at creation date" CHECK ((creation_date < actual_finish_date)),
    CONSTRAINT "can not have delivery comment while not specified as a delivery" CHECK ((NOT ((NOT to_be_delievered) AND (delivery_comment IS NOT NULL))))
);


ALTER TABLE dryclean.orders OWNER TO any_user;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: dryclean; Owner: any_user
--

CREATE SEQUENCE dryclean.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dryclean.orders_id_seq OWNER TO any_user;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: dryclean; Owner: any_user
--

ALTER SEQUENCE dryclean.orders_id_seq OWNED BY dryclean.orders.id;


--
-- Name: shipments; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.shipments (
    id bigint NOT NULL,
    department_id bigint,
    sorting_department_id bigint NOT NULL,
    cleaning_department_id bigint,
    truck_id bigint,
    type character(100) NOT NULL,
    is_on_route boolean DEFAULT false NOT NULL,
    CONSTRAINT "can not be on route without a truck specified" CHECK ((NOT (is_on_route AND (truck_id IS NULL)))),
    CONSTRAINT "cleaning dpt and dpt must not be specified together" CHECK ((NOT ((cleaning_department_id IS NOT NULL) AND (department_id IS NOT NULL))))
);


ALTER TABLE dryclean.shipments OWNER TO any_user;

--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: dryclean; Owner: any_user
--

CREATE SEQUENCE dryclean.shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dryclean.shipments_id_seq OWNER TO any_user;

--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: dryclean; Owner: any_user
--

ALTER SEQUENCE dryclean.shipments_id_seq OWNED BY dryclean.shipments.id;


--
-- Name: sorting_departments; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.sorting_departments (
    id bigint DEFAULT nextval('dryclean.buildings_id_seq'::regclass)
)
INHERITS (dryclean.buildings);


ALTER TABLE dryclean.sorting_departments OWNER TO any_user;

--
-- Name: trucks; Type: TABLE; Schema: dryclean; Owner: any_user
--

CREATE TABLE dryclean.trucks (
    id bigint NOT NULL,
    courier_id bigint,
    label character(20),
    is_in_working_condition boolean DEFAULT true NOT NULL,
    CONSTRAINT "trucks that are not in working condition can not be driven" CHECK ((NOT ((NOT is_in_working_condition) AND (courier_id IS NOT NULL))))
);


ALTER TABLE dryclean.trucks OWNER TO any_user;

--
-- Name: trucks_id_seq; Type: SEQUENCE; Schema: dryclean; Owner: any_user
--

CREATE SEQUENCE dryclean.trucks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dryclean.trucks_id_seq OWNER TO any_user;

--
-- Name: trucks_id_seq; Type: SEQUENCE OWNED BY; Schema: dryclean; Owner: any_user
--

ALTER SEQUENCE dryclean.trucks_id_seq OWNED BY dryclean.trucks.id;


--
-- Name: cleaning_departments requires_shipment; Type: DEFAULT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.cleaning_departments ALTER COLUMN requires_shipment SET DEFAULT false;


--
-- Name: clothing id; Type: DEFAULT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.clothing ALTER COLUMN id SET DEFAULT nextval('dryclean.clothing_id_seq'::regclass);


--
-- Name: departments requires_shipment; Type: DEFAULT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.departments ALTER COLUMN requires_shipment SET DEFAULT false;


--
-- Name: orders id; Type: DEFAULT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.orders ALTER COLUMN id SET DEFAULT nextval('dryclean.orders_id_seq'::regclass);


--
-- Name: shipments id; Type: DEFAULT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.shipments ALTER COLUMN id SET DEFAULT nextval('dryclean.shipments_id_seq'::regclass);


--
-- Name: sorting_departments requires_shipment; Type: DEFAULT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.sorting_departments ALTER COLUMN requires_shipment SET DEFAULT false;


--
-- Name: trucks id; Type: DEFAULT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.trucks ALTER COLUMN id SET DEFAULT nextval('dryclean.trucks_id_seq'::regclass);


--
-- Data for Name: buildings; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.buildings (id, address, phone_number, requires_shipment) FROM stdin;
\.


--
-- Data for Name: cleaning_departments; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.cleaning_departments (id, address, phone_number, requires_shipment, acceptable_clothing_types, acceptable_defect_types) FROM stdin;
31	г. Москва, алл. Детская, стр. 8/1, 965799                                                           	8 (379) 021-18-19   	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                                                                                                       	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                                                               
32	г. Москва, пер. Амурский, стр. 51, 448648                                                           	+7 965 822 20 72    	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                            	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                                                                                      
33	г. Москва, алл. Мичурина, стр. 606, 139400                                                          	+7 (096) 767-46-40  	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                   	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                                        
34	г. Москва, пер. Проезжий, стр. 58, 481150                                                           	8 (031) 780-61-87   	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                                                                                                       	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                                                                                      
35	г. Москва, ул. Машиностроителей, стр. 9, 409602                                                     	+7 434 630 51 40    	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                                                     	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                                                                                                             
36	г. Москва, ул. Большая, стр. 46, 079413                                                             	+7 (963) 448-81-89  	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                            	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                                                                                                             
37	г. Москва, алл. Тенистая, стр. 758, 589142                                                          	+7 (005) 475-5725   	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                   	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                 
38	г. Москва, ш. 50 лет Октября, стр. 9/5, 925759                                                      	87377222384         	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                            	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                                                                                      
39	г. Москва, наб. Мичурина, стр. 9/1, 498013                                                          	8 106 700 42 16     	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                            	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                 
40	г. Москва, ул. Котовского, стр. 197, 769219                                                         	8 244 828 18 55     	f	PlaceholderClothingType, PlaceholderClothingType, PlaceholderClothingType                                                                                                                                                                                                                                                                                                                                       	PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType, PlaceholderDefectType                                                                                                                                                                                                                                                 
\.


--
-- Data for Name: clothing; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.clothing (id, order_id, shipment_id, status, type, defect_type, name, comment) FROM stdin;
1	65	\N	being cleaned                 	\N	\N	\N	\N
2	323	\N	being sorted for cleaning     	\N	\N	\N	\N
3	334	5	being shipped for sorting     	\N	\N	\N	\N
4	87	\N	being sorted for delivery back	\N	\N	\N	\N
5	191	\N	being sorted for delivery back	\N	\N	\N	\N
6	284	17	being shipped for sorting     	\N	\N	\N	\N
7	156	\N	being sorted for cleaning     	\N	\N	\N	\N
8	247	24	being shipped for sorting     	\N	\N	\N	\N
9	157	\N	given_in                      	\N	\N	\N	\N
10	177	\N	given_in                      	\N	\N	\N	\N
11	207	32	being shipped for sorting     	\N	\N	\N	\N
12	50	\N	being cleaned                 	\N	\N	\N	\N
13	315	15	being shipped for sorting     	\N	\N	\N	\N
14	25	\N	being sorted for delivery back	\N	\N	\N	\N
15	16	\N	given_in                      	\N	\N	\N	\N
16	301	\N	given_in                      	\N	\N	\N	\N
17	265	\N	given_in                      	\N	\N	\N	\N
18	375	6	being shipped for sorting     	\N	\N	\N	\N
19	374	44	being shipped for sorting     	\N	\N	\N	\N
20	149	\N	being sorted for cleaning     	\N	\N	\N	\N
21	241	\N	given_in                      	\N	\N	\N	\N
22	180	\N	being sorted for delivery back	\N	\N	\N	\N
23	196	16	being shipped for sorting     	\N	\N	\N	\N
24	241	\N	being sorted for cleaning     	\N	\N	\N	\N
25	73	\N	being cleaned                 	\N	\N	\N	\N
26	249	10	being shipped for sorting     	\N	\N	\N	\N
27	285	\N	being sorted for cleaning     	\N	\N	\N	\N
28	324	33	being shipped for sorting     	\N	\N	\N	\N
29	22	\N	given_in                      	\N	\N	\N	\N
30	294	50	being shipped for sorting     	\N	\N	\N	\N
31	276	\N	being sorted for cleaning     	\N	\N	\N	\N
32	375	\N	being cleaned                 	\N	\N	\N	\N
33	344	\N	given_in                      	\N	\N	\N	\N
34	117	9	being shipped for sorting     	\N	\N	\N	\N
35	296	\N	being cleaned                 	\N	\N	\N	\N
36	78	\N	given_in                      	\N	\N	\N	\N
37	278	\N	being sorted for cleaning     	\N	\N	\N	\N
38	203	21	being shipped for sorting     	\N	\N	\N	\N
39	259	\N	being sorted for delivery back	\N	\N	\N	\N
40	386	30	being shipped for sorting     	\N	\N	\N	\N
41	57	35	being shipped for sorting     	\N	\N	\N	\N
42	2	\N	given_in                      	\N	\N	\N	\N
43	152	\N	given_in                      	\N	\N	\N	\N
44	322	16	being shipped for sorting     	\N	\N	\N	\N
45	173	\N	being cleaned                 	\N	\N	\N	\N
46	241	\N	being cleaned                 	\N	\N	\N	\N
47	201	12	being shipped for sorting     	\N	\N	\N	\N
48	26	\N	being sorted for cleaning     	\N	\N	\N	\N
49	331	26	being shipped for sorting     	\N	\N	\N	\N
50	283	\N	being cleaned                 	\N	\N	\N	\N
51	151	\N	given_in                      	\N	\N	\N	\N
52	148	27	being shipped for sorting     	\N	\N	\N	\N
53	240	\N	being cleaned                 	\N	\N	\N	\N
54	72	20	being shipped for sorting     	\N	\N	\N	\N
55	222	\N	being cleaned                 	\N	\N	\N	\N
56	343	37	being shipped for sorting     	\N	\N	\N	\N
57	147	\N	being sorted for delivery back	\N	\N	\N	\N
58	79	26	being shipped for sorting     	\N	\N	\N	\N
59	153	\N	being cleaned                 	\N	\N	\N	\N
60	113	\N	being sorted for delivery back	\N	\N	\N	\N
61	393	32	being shipped for sorting     	\N	\N	\N	\N
62	98	\N	being cleaned                 	\N	\N	\N	\N
63	8	\N	being sorted for delivery back	\N	\N	\N	\N
64	5	\N	being sorted for delivery back	\N	\N	\N	\N
65	370	\N	being sorted for delivery back	\N	\N	\N	\N
66	88	20	being shipped for sorting     	\N	\N	\N	\N
67	158	\N	being sorted for cleaning     	\N	\N	\N	\N
68	313	\N	being cleaned                 	\N	\N	\N	\N
69	119	\N	being sorted for cleaning     	\N	\N	\N	\N
70	124	39	being shipped for sorting     	\N	\N	\N	\N
71	232	\N	being sorted for delivery back	\N	\N	\N	\N
72	26	\N	being cleaned                 	\N	\N	\N	\N
73	26	\N	being sorted for delivery back	\N	\N	\N	\N
74	161	18	being shipped for sorting     	\N	\N	\N	\N
75	344	20	being shipped for sorting     	\N	\N	\N	\N
76	344	\N	being sorted for cleaning     	\N	\N	\N	\N
77	12	\N	being cleaned                 	\N	\N	\N	\N
78	34	\N	being sorted for cleaning     	\N	\N	\N	\N
79	120	\N	being cleaned                 	\N	\N	\N	\N
80	38	\N	being sorted for cleaning     	\N	\N	\N	\N
81	354	48	being shipped for sorting     	\N	\N	\N	\N
82	23	30	being shipped for sorting     	\N	\N	\N	\N
83	262	22	being shipped for sorting     	\N	\N	\N	\N
84	161	\N	being sorted for cleaning     	\N	\N	\N	\N
85	163	\N	being sorted for delivery back	\N	\N	\N	\N
86	198	6	being shipped for sorting     	\N	\N	\N	\N
87	206	\N	given_in                      	\N	\N	\N	\N
88	76	\N	being sorted for cleaning     	\N	\N	\N	\N
89	8	\N	being sorted for cleaning     	\N	\N	\N	\N
90	272	\N	given_in                      	\N	\N	\N	\N
91	130	\N	being sorted for cleaning     	\N	\N	\N	\N
92	126	\N	being sorted for delivery back	\N	\N	\N	\N
93	39	\N	being sorted for cleaning     	\N	\N	\N	\N
94	175	\N	being cleaned                 	\N	\N	\N	\N
95	226	\N	given_in                      	\N	\N	\N	\N
96	106	\N	being sorted for cleaning     	\N	\N	\N	\N
97	37	\N	given_in                      	\N	\N	\N	\N
98	336	6	being shipped for sorting     	\N	\N	\N	\N
99	400	\N	given_in                      	\N	\N	\N	\N
100	267	\N	being sorted for delivery back	\N	\N	\N	\N
101	165	\N	being cleaned                 	\N	\N	\N	\N
102	316	\N	given_in                      	\N	\N	\N	\N
103	393	\N	being sorted for delivery back	\N	\N	\N	\N
104	254	35	being shipped for sorting     	\N	\N	\N	\N
105	213	\N	given_in                      	\N	\N	\N	\N
106	136	3	being shipped for sorting     	\N	\N	\N	\N
107	88	\N	being sorted for delivery back	\N	\N	\N	\N
108	147	48	being shipped for sorting     	\N	\N	\N	\N
109	331	10	being shipped for sorting     	\N	\N	\N	\N
110	44	\N	given_in                      	\N	\N	\N	\N
111	248	\N	given_in                      	\N	\N	\N	\N
112	271	23	being shipped for sorting     	\N	\N	\N	\N
113	293	28	being shipped for sorting     	\N	\N	\N	\N
114	222	\N	given_in                      	\N	\N	\N	\N
115	364	\N	given_in                      	\N	\N	\N	\N
116	16	\N	being cleaned                 	\N	\N	\N	\N
117	311	\N	being sorted for delivery back	\N	\N	\N	\N
118	81	22	being shipped for sorting     	\N	\N	\N	\N
119	45	\N	being sorted for cleaning     	\N	\N	\N	\N
120	2	\N	being sorted for cleaning     	\N	\N	\N	\N
121	321	\N	being sorted for delivery back	\N	\N	\N	\N
122	371	21	being shipped for sorting     	\N	\N	\N	\N
123	315	5	being shipped for sorting     	\N	\N	\N	\N
124	154	29	being shipped for sorting     	\N	\N	\N	\N
125	53	\N	given_in                      	\N	\N	\N	\N
126	387	30	being shipped for sorting     	\N	\N	\N	\N
127	297	\N	being cleaned                 	\N	\N	\N	\N
128	278	\N	being cleaned                 	\N	\N	\N	\N
129	119	49	being shipped for sorting     	\N	\N	\N	\N
130	139	\N	being sorted for cleaning     	\N	\N	\N	\N
131	338	8	being shipped for sorting     	\N	\N	\N	\N
132	300	\N	being sorted for cleaning     	\N	\N	\N	\N
133	296	5	being shipped for sorting     	\N	\N	\N	\N
134	373	\N	being sorted for delivery back	\N	\N	\N	\N
135	100	\N	being sorted for delivery back	\N	\N	\N	\N
136	252	\N	being sorted for cleaning     	\N	\N	\N	\N
137	170	\N	being sorted for delivery back	\N	\N	\N	\N
138	239	\N	being sorted for delivery back	\N	\N	\N	\N
139	50	\N	being sorted for cleaning     	\N	\N	\N	\N
140	180	\N	being cleaned                 	\N	\N	\N	\N
141	184	10	being shipped for sorting     	\N	\N	\N	\N
142	184	41	being shipped for sorting     	\N	\N	\N	\N
143	370	\N	being cleaned                 	\N	\N	\N	\N
144	220	\N	given_in                      	\N	\N	\N	\N
145	108	\N	being sorted for delivery back	\N	\N	\N	\N
146	247	\N	being sorted for cleaning     	\N	\N	\N	\N
147	385	\N	being sorted for delivery back	\N	\N	\N	\N
148	302	\N	being sorted for cleaning     	\N	\N	\N	\N
149	154	\N	being sorted for delivery back	\N	\N	\N	\N
150	349	\N	being cleaned                 	\N	\N	\N	\N
151	393	\N	given_in                      	\N	\N	\N	\N
152	238	\N	being sorted for cleaning     	\N	\N	\N	\N
153	126	45	being shipped for sorting     	\N	\N	\N	\N
154	32	2	being shipped for sorting     	\N	\N	\N	\N
155	145	15	being shipped for sorting     	\N	\N	\N	\N
156	118	\N	being cleaned                 	\N	\N	\N	\N
157	146	41	being shipped for sorting     	\N	\N	\N	\N
158	105	\N	being sorted for delivery back	\N	\N	\N	\N
159	138	26	being shipped for sorting     	\N	\N	\N	\N
160	258	\N	given_in                      	\N	\N	\N	\N
161	197	\N	given_in                      	\N	\N	\N	\N
162	312	38	being shipped for sorting     	\N	\N	\N	\N
163	162	\N	being sorted for delivery back	\N	\N	\N	\N
164	202	50	being shipped for sorting     	\N	\N	\N	\N
165	17	\N	given_in                      	\N	\N	\N	\N
166	30	\N	being sorted for delivery back	\N	\N	\N	\N
167	53	12	being shipped for sorting     	\N	\N	\N	\N
168	381	\N	being sorted for cleaning     	\N	\N	\N	\N
169	298	\N	given_in                      	\N	\N	\N	\N
170	12	17	being shipped for sorting     	\N	\N	\N	\N
171	266	27	being shipped for sorting     	\N	\N	\N	\N
172	234	\N	being sorted for cleaning     	\N	\N	\N	\N
173	1	\N	being cleaned                 	\N	\N	\N	\N
174	62	3	being shipped for sorting     	\N	\N	\N	\N
175	263	\N	being sorted for cleaning     	\N	\N	\N	\N
176	399	10	being shipped for sorting     	\N	\N	\N	\N
177	331	\N	being cleaned                 	\N	\N	\N	\N
178	263	\N	given_in                      	\N	\N	\N	\N
179	128	\N	being sorted for cleaning     	\N	\N	\N	\N
180	64	\N	given_in                      	\N	\N	\N	\N
181	367	\N	being sorted for delivery back	\N	\N	\N	\N
182	268	30	being shipped for sorting     	\N	\N	\N	\N
183	112	4	being shipped for sorting     	\N	\N	\N	\N
184	273	18	being shipped for sorting     	\N	\N	\N	\N
185	46	\N	being sorted for cleaning     	\N	\N	\N	\N
186	305	46	being shipped for sorting     	\N	\N	\N	\N
187	324	46	being shipped for sorting     	\N	\N	\N	\N
188	68	\N	given_in                      	\N	\N	\N	\N
189	188	\N	being cleaned                 	\N	\N	\N	\N
190	393	8	being shipped for sorting     	\N	\N	\N	\N
191	168	\N	being sorted for delivery back	\N	\N	\N	\N
192	13	32	being shipped for sorting     	\N	\N	\N	\N
193	369	38	being shipped for sorting     	\N	\N	\N	\N
194	212	\N	being cleaned                 	\N	\N	\N	\N
195	56	\N	being sorted for delivery back	\N	\N	\N	\N
196	54	42	being shipped for sorting     	\N	\N	\N	\N
197	339	18	being shipped for sorting     	\N	\N	\N	\N
198	375	\N	given_in                      	\N	\N	\N	\N
199	300	\N	given_in                      	\N	\N	\N	\N
200	164	\N	being sorted for delivery back	\N	\N	\N	\N
201	58	\N	being sorted for delivery back	\N	\N	\N	\N
202	364	\N	being sorted for delivery back	\N	\N	\N	\N
203	325	\N	being sorted for cleaning     	\N	\N	\N	\N
204	124	\N	being sorted for delivery back	\N	\N	\N	\N
205	79	\N	being sorted for delivery back	\N	\N	\N	\N
206	325	9	being shipped for sorting     	\N	\N	\N	\N
207	101	\N	being sorted for cleaning     	\N	\N	\N	\N
208	119	19	being shipped for sorting     	\N	\N	\N	\N
209	376	\N	being sorted for cleaning     	\N	\N	\N	\N
210	314	\N	being sorted for delivery back	\N	\N	\N	\N
211	333	\N	being sorted for delivery back	\N	\N	\N	\N
212	287	\N	given_in                      	\N	\N	\N	\N
213	58	\N	being cleaned                 	\N	\N	\N	\N
214	63	\N	being sorted for delivery back	\N	\N	\N	\N
215	97	6	being shipped for sorting     	\N	\N	\N	\N
216	293	\N	being cleaned                 	\N	\N	\N	\N
217	395	\N	being sorted for cleaning     	\N	\N	\N	\N
218	383	\N	given_in                      	\N	\N	\N	\N
219	257	46	being shipped for sorting     	\N	\N	\N	\N
220	148	\N	given_in                      	\N	\N	\N	\N
221	93	\N	being sorted for delivery back	\N	\N	\N	\N
222	51	42	being shipped for sorting     	\N	\N	\N	\N
223	9	38	being shipped for sorting     	\N	\N	\N	\N
224	339	\N	given_in                      	\N	\N	\N	\N
225	51	\N	being sorted for delivery back	\N	\N	\N	\N
226	18	\N	being sorted for cleaning     	\N	\N	\N	\N
227	140	\N	being cleaned                 	\N	\N	\N	\N
228	53	3	being shipped for sorting     	\N	\N	\N	\N
229	82	\N	given_in                      	\N	\N	\N	\N
230	261	\N	being sorted for delivery back	\N	\N	\N	\N
231	190	\N	being sorted for delivery back	\N	\N	\N	\N
232	79	\N	being sorted for cleaning     	\N	\N	\N	\N
233	169	\N	being cleaned                 	\N	\N	\N	\N
234	213	\N	being sorted for cleaning     	\N	\N	\N	\N
235	268	\N	given_in                      	\N	\N	\N	\N
236	275	\N	being sorted for cleaning     	\N	\N	\N	\N
237	227	32	being shipped for sorting     	\N	\N	\N	\N
238	93	3	being shipped for sorting     	\N	\N	\N	\N
239	24	\N	being sorted for cleaning     	\N	\N	\N	\N
240	399	38	being shipped for sorting     	\N	\N	\N	\N
241	201	\N	given_in                      	\N	\N	\N	\N
242	320	\N	given_in                      	\N	\N	\N	\N
243	208	29	being shipped for sorting     	\N	\N	\N	\N
244	182	6	being shipped for sorting     	\N	\N	\N	\N
245	343	12	being shipped for sorting     	\N	\N	\N	\N
246	235	21	being shipped for sorting     	\N	\N	\N	\N
247	286	\N	given_in                      	\N	\N	\N	\N
248	89	\N	being cleaned                 	\N	\N	\N	\N
249	266	\N	being cleaned                 	\N	\N	\N	\N
250	62	29	being shipped for sorting     	\N	\N	\N	\N
251	326	40	being shipped for sorting     	\N	\N	\N	\N
252	131	27	being shipped for sorting     	\N	\N	\N	\N
253	312	41	being shipped for sorting     	\N	\N	\N	\N
254	182	2	being shipped for sorting     	\N	\N	\N	\N
255	68	\N	being sorted for cleaning     	\N	\N	\N	\N
256	53	29	being shipped for sorting     	\N	\N	\N	\N
257	366	22	being shipped for sorting     	\N	\N	\N	\N
258	35	\N	given_in                      	\N	\N	\N	\N
259	192	\N	being cleaned                 	\N	\N	\N	\N
260	56	\N	being cleaned                 	\N	\N	\N	\N
261	172	\N	given_in                      	\N	\N	\N	\N
262	380	\N	being sorted for delivery back	\N	\N	\N	\N
263	320	\N	being sorted for delivery back	\N	\N	\N	\N
264	383	17	being shipped for sorting     	\N	\N	\N	\N
265	129	46	being shipped for sorting     	\N	\N	\N	\N
266	152	\N	being sorted for delivery back	\N	\N	\N	\N
267	387	\N	being sorted for cleaning     	\N	\N	\N	\N
268	20	\N	being sorted for delivery back	\N	\N	\N	\N
269	25	\N	being cleaned                 	\N	\N	\N	\N
270	132	\N	being cleaned                 	\N	\N	\N	\N
271	201	\N	being sorted for cleaning     	\N	\N	\N	\N
272	132	\N	being sorted for cleaning     	\N	\N	\N	\N
273	360	33	being shipped for sorting     	\N	\N	\N	\N
274	250	\N	being sorted for delivery back	\N	\N	\N	\N
275	103	41	being shipped for sorting     	\N	\N	\N	\N
276	316	\N	being sorted for cleaning     	\N	\N	\N	\N
277	236	\N	given_in                      	\N	\N	\N	\N
278	58	\N	given_in                      	\N	\N	\N	\N
279	391	28	being shipped for sorting     	\N	\N	\N	\N
280	348	23	being shipped for sorting     	\N	\N	\N	\N
281	324	17	being shipped for sorting     	\N	\N	\N	\N
282	264	\N	being cleaned                 	\N	\N	\N	\N
283	162	\N	given_in                      	\N	\N	\N	\N
284	85	1	being shipped for sorting     	\N	\N	\N	\N
285	115	\N	being cleaned                 	\N	\N	\N	\N
286	37	\N	being sorted for delivery back	\N	\N	\N	\N
287	288	\N	given_in                      	\N	\N	\N	\N
288	384	\N	being sorted for cleaning     	\N	\N	\N	\N
289	230	\N	being cleaned                 	\N	\N	\N	\N
290	58	\N	being sorted for cleaning     	\N	\N	\N	\N
291	189	\N	being sorted for delivery back	\N	\N	\N	\N
292	328	46	being shipped for sorting     	\N	\N	\N	\N
293	105	\N	being cleaned                 	\N	\N	\N	\N
294	372	6	being shipped for sorting     	\N	\N	\N	\N
295	93	24	being shipped for sorting     	\N	\N	\N	\N
296	111	\N	being sorted for delivery back	\N	\N	\N	\N
297	312	15	being shipped for sorting     	\N	\N	\N	\N
298	177	\N	being sorted for cleaning     	\N	\N	\N	\N
299	261	\N	being cleaned                 	\N	\N	\N	\N
300	227	17	being shipped for sorting     	\N	\N	\N	\N
301	199	\N	given_in                      	\N	\N	\N	\N
302	186	11	being shipped for sorting     	\N	\N	\N	\N
303	322	5	being shipped for sorting     	\N	\N	\N	\N
304	135	\N	being sorted for cleaning     	\N	\N	\N	\N
305	228	\N	being cleaned                 	\N	\N	\N	\N
306	277	39	being shipped for sorting     	\N	\N	\N	\N
307	268	2	being shipped for sorting     	\N	\N	\N	\N
308	208	38	being shipped for sorting     	\N	\N	\N	\N
309	343	18	being shipped for sorting     	\N	\N	\N	\N
310	374	19	being shipped for sorting     	\N	\N	\N	\N
311	397	\N	given_in                      	\N	\N	\N	\N
312	204	16	being shipped for sorting     	\N	\N	\N	\N
313	161	41	being shipped for sorting     	\N	\N	\N	\N
314	130	\N	given_in                      	\N	\N	\N	\N
315	131	\N	being sorted for delivery back	\N	\N	\N	\N
316	230	\N	being sorted for cleaning     	\N	\N	\N	\N
317	289	\N	being sorted for delivery back	\N	\N	\N	\N
318	243	23	being shipped for sorting     	\N	\N	\N	\N
319	19	\N	given_in                      	\N	\N	\N	\N
320	309	\N	being sorted for delivery back	\N	\N	\N	\N
321	273	29	being shipped for sorting     	\N	\N	\N	\N
322	268	\N	being sorted for cleaning     	\N	\N	\N	\N
323	398	1	being shipped for sorting     	\N	\N	\N	\N
324	391	\N	being cleaned                 	\N	\N	\N	\N
325	131	\N	being cleaned                 	\N	\N	\N	\N
326	99	\N	being sorted for delivery back	\N	\N	\N	\N
327	225	\N	being sorted for cleaning     	\N	\N	\N	\N
328	17	\N	being cleaned                 	\N	\N	\N	\N
329	40	28	being shipped for sorting     	\N	\N	\N	\N
330	239	\N	being sorted for cleaning     	\N	\N	\N	\N
331	330	23	being shipped for sorting     	\N	\N	\N	\N
332	145	38	being shipped for sorting     	\N	\N	\N	\N
333	342	35	being shipped for sorting     	\N	\N	\N	\N
334	86	\N	being sorted for delivery back	\N	\N	\N	\N
335	67	\N	being cleaned                 	\N	\N	\N	\N
336	23	\N	being sorted for delivery back	\N	\N	\N	\N
337	74	\N	being sorted for cleaning     	\N	\N	\N	\N
338	95	\N	being sorted for delivery back	\N	\N	\N	\N
339	389	14	being shipped for sorting     	\N	\N	\N	\N
340	91	\N	being sorted for cleaning     	\N	\N	\N	\N
341	256	\N	being cleaned                 	\N	\N	\N	\N
342	314	\N	being sorted for cleaning     	\N	\N	\N	\N
343	210	\N	being cleaned                 	\N	\N	\N	\N
344	48	\N	given_in                      	\N	\N	\N	\N
345	361	20	being shipped for sorting     	\N	\N	\N	\N
346	315	\N	being sorted for cleaning     	\N	\N	\N	\N
347	288	10	being shipped for sorting     	\N	\N	\N	\N
348	269	\N	being sorted for delivery back	\N	\N	\N	\N
349	235	\N	given_in                      	\N	\N	\N	\N
350	135	\N	being sorted for delivery back	\N	\N	\N	\N
351	340	12	being shipped for sorting     	\N	\N	\N	\N
352	84	1	being shipped for sorting     	\N	\N	\N	\N
353	170	\N	being cleaned                 	\N	\N	\N	\N
354	330	11	being shipped for sorting     	\N	\N	\N	\N
355	58	18	being shipped for sorting     	\N	\N	\N	\N
356	231	25	being shipped for sorting     	\N	\N	\N	\N
357	255	30	being shipped for sorting     	\N	\N	\N	\N
358	388	38	being shipped for sorting     	\N	\N	\N	\N
359	303	\N	being cleaned                 	\N	\N	\N	\N
360	174	\N	being sorted for cleaning     	\N	\N	\N	\N
361	377	4	being shipped for sorting     	\N	\N	\N	\N
362	248	\N	being cleaned                 	\N	\N	\N	\N
363	375	\N	being sorted for delivery back	\N	\N	\N	\N
364	240	\N	given_in                      	\N	\N	\N	\N
365	94	44	being shipped for sorting     	\N	\N	\N	\N
366	96	\N	being sorted for cleaning     	\N	\N	\N	\N
367	206	19	being shipped for sorting     	\N	\N	\N	\N
368	167	15	being shipped for sorting     	\N	\N	\N	\N
369	160	\N	being cleaned                 	\N	\N	\N	\N
370	183	25	being shipped for sorting     	\N	\N	\N	\N
371	350	\N	given_in                      	\N	\N	\N	\N
372	339	25	being shipped for sorting     	\N	\N	\N	\N
373	216	\N	given_in                      	\N	\N	\N	\N
374	249	\N	being sorted for cleaning     	\N	\N	\N	\N
375	182	\N	being cleaned                 	\N	\N	\N	\N
376	313	\N	being sorted for delivery back	\N	\N	\N	\N
377	206	\N	being sorted for cleaning     	\N	\N	\N	\N
378	372	\N	being sorted for delivery back	\N	\N	\N	\N
379	234	\N	being cleaned                 	\N	\N	\N	\N
380	21	\N	being cleaned                 	\N	\N	\N	\N
381	390	3	being shipped for sorting     	\N	\N	\N	\N
382	254	24	being shipped for sorting     	\N	\N	\N	\N
383	175	43	being shipped for sorting     	\N	\N	\N	\N
384	267	\N	being cleaned                 	\N	\N	\N	\N
385	353	\N	being cleaned                 	\N	\N	\N	\N
386	400	\N	being cleaned                 	\N	\N	\N	\N
387	225	17	being shipped for sorting     	\N	\N	\N	\N
388	175	30	being shipped for sorting     	\N	\N	\N	\N
389	30	11	being shipped for sorting     	\N	\N	\N	\N
390	107	\N	being sorted for delivery back	\N	\N	\N	\N
391	10	19	being shipped for sorting     	\N	\N	\N	\N
392	320	\N	being cleaned                 	\N	\N	\N	\N
393	379	37	being shipped for sorting     	\N	\N	\N	\N
394	204	2	being shipped for sorting     	\N	\N	\N	\N
395	224	\N	given_in                      	\N	\N	\N	\N
396	278	\N	given_in                      	\N	\N	\N	\N
397	362	\N	being sorted for delivery back	\N	\N	\N	\N
398	335	\N	being cleaned                 	\N	\N	\N	\N
399	345	\N	being sorted for cleaning     	\N	\N	\N	\N
400	378	\N	being cleaned                 	\N	\N	\N	\N
401	297	24	being shipped for sorting     	\N	\N	\N	\N
402	285	\N	being cleaned                 	\N	\N	\N	\N
403	287	\N	being sorted for delivery back	\N	\N	\N	\N
404	370	27	being shipped for sorting     	\N	\N	\N	\N
405	358	\N	being cleaned                 	\N	\N	\N	\N
406	7	46	being shipped for sorting     	\N	\N	\N	\N
407	279	12	being shipped for sorting     	\N	\N	\N	\N
408	235	\N	being sorted for delivery back	\N	\N	\N	\N
409	104	19	being shipped for sorting     	\N	\N	\N	\N
410	237	\N	being cleaned                 	\N	\N	\N	\N
411	327	33	being shipped for sorting     	\N	\N	\N	\N
412	166	18	being shipped for sorting     	\N	\N	\N	\N
413	43	11	being shipped for sorting     	\N	\N	\N	\N
414	327	50	being shipped for sorting     	\N	\N	\N	\N
415	60	45	being shipped for sorting     	\N	\N	\N	\N
416	357	17	being shipped for sorting     	\N	\N	\N	\N
417	306	22	being shipped for sorting     	\N	\N	\N	\N
418	252	\N	given_in                      	\N	\N	\N	\N
419	293	48	being shipped for sorting     	\N	\N	\N	\N
420	211	21	being shipped for sorting     	\N	\N	\N	\N
421	64	\N	being sorted for delivery back	\N	\N	\N	\N
422	179	\N	being sorted for cleaning     	\N	\N	\N	\N
423	259	\N	being sorted for cleaning     	\N	\N	\N	\N
424	63	3	being shipped for sorting     	\N	\N	\N	\N
425	226	\N	being sorted for delivery back	\N	\N	\N	\N
426	307	29	being shipped for sorting     	\N	\N	\N	\N
427	145	\N	given_in                      	\N	\N	\N	\N
428	158	\N	given_in                      	\N	\N	\N	\N
429	395	\N	being cleaned                 	\N	\N	\N	\N
430	292	\N	being sorted for delivery back	\N	\N	\N	\N
431	333	25	being shipped for sorting     	\N	\N	\N	\N
432	343	\N	given_in                      	\N	\N	\N	\N
433	121	\N	being sorted for cleaning     	\N	\N	\N	\N
434	145	20	being shipped for sorting     	\N	\N	\N	\N
435	393	\N	being sorted for cleaning     	\N	\N	\N	\N
436	302	16	being shipped for sorting     	\N	\N	\N	\N
437	174	22	being shipped for sorting     	\N	\N	\N	\N
438	163	\N	given_in                      	\N	\N	\N	\N
439	122	\N	given_in                      	\N	\N	\N	\N
440	3	\N	being sorted for cleaning     	\N	\N	\N	\N
441	316	5	being shipped for sorting     	\N	\N	\N	\N
442	252	\N	being cleaned                 	\N	\N	\N	\N
443	244	\N	being cleaned                 	\N	\N	\N	\N
444	146	\N	given_in                      	\N	\N	\N	\N
445	183	35	being shipped for sorting     	\N	\N	\N	\N
446	97	37	being shipped for sorting     	\N	\N	\N	\N
447	83	\N	being sorted for delivery back	\N	\N	\N	\N
448	181	22	being shipped for sorting     	\N	\N	\N	\N
449	103	35	being shipped for sorting     	\N	\N	\N	\N
450	260	\N	being sorted for cleaning     	\N	\N	\N	\N
451	391	\N	being sorted for delivery back	\N	\N	\N	\N
452	304	\N	being sorted for delivery back	\N	\N	\N	\N
453	379	\N	being sorted for cleaning     	\N	\N	\N	\N
454	65	41	being shipped for sorting     	\N	\N	\N	\N
455	331	23	being shipped for sorting     	\N	\N	\N	\N
456	354	\N	being cleaned                 	\N	\N	\N	\N
457	242	\N	being sorted for delivery back	\N	\N	\N	\N
458	106	40	being shipped for sorting     	\N	\N	\N	\N
459	116	3	being shipped for sorting     	\N	\N	\N	\N
460	239	\N	being cleaned                 	\N	\N	\N	\N
461	376	44	being shipped for sorting     	\N	\N	\N	\N
462	167	\N	being sorted for cleaning     	\N	\N	\N	\N
463	136	48	being shipped for sorting     	\N	\N	\N	\N
464	342	\N	being sorted for delivery back	\N	\N	\N	\N
465	318	\N	given_in                      	\N	\N	\N	\N
466	360	\N	given_in                      	\N	\N	\N	\N
467	166	\N	being cleaned                 	\N	\N	\N	\N
468	218	9	being shipped for sorting     	\N	\N	\N	\N
469	127	43	being shipped for sorting     	\N	\N	\N	\N
470	266	\N	given_in                      	\N	\N	\N	\N
471	118	\N	given_in                      	\N	\N	\N	\N
472	288	\N	being sorted for cleaning     	\N	\N	\N	\N
473	33	9	being shipped for sorting     	\N	\N	\N	\N
474	103	\N	being sorted for delivery back	\N	\N	\N	\N
475	322	\N	given_in                      	\N	\N	\N	\N
476	192	\N	being sorted for cleaning     	\N	\N	\N	\N
477	232	\N	given_in                      	\N	\N	\N	\N
478	85	\N	being sorted for delivery back	\N	\N	\N	\N
479	301	\N	being sorted for delivery back	\N	\N	\N	\N
480	38	\N	being cleaned                 	\N	\N	\N	\N
481	253	\N	being cleaned                 	\N	\N	\N	\N
482	125	\N	being sorted for delivery back	\N	\N	\N	\N
483	138	\N	given_in                      	\N	\N	\N	\N
484	278	\N	being sorted for delivery back	\N	\N	\N	\N
485	323	\N	given_in                      	\N	\N	\N	\N
486	35	\N	being sorted for cleaning     	\N	\N	\N	\N
487	153	2	being shipped for sorting     	\N	\N	\N	\N
488	377	\N	being sorted for delivery back	\N	\N	\N	\N
489	55	\N	being cleaned                 	\N	\N	\N	\N
490	14	\N	being cleaned                 	\N	\N	\N	\N
491	218	\N	being cleaned                 	\N	\N	\N	\N
492	372	\N	being sorted for cleaning     	\N	\N	\N	\N
493	159	\N	being sorted for cleaning     	\N	\N	\N	\N
494	33	\N	being sorted for cleaning     	\N	\N	\N	\N
495	388	\N	being cleaned                 	\N	\N	\N	\N
496	284	39	being shipped for sorting     	\N	\N	\N	\N
497	304	\N	given_in                      	\N	\N	\N	\N
498	309	\N	being cleaned                 	\N	\N	\N	\N
499	207	\N	being sorted for delivery back	\N	\N	\N	\N
500	312	\N	given_in                      	\N	\N	\N	\N
501	383	\N	being sorted for delivery back	\N	\N	\N	\N
502	59	37	being shipped for sorting     	\N	\N	\N	\N
503	158	\N	being cleaned                 	\N	\N	\N	\N
504	363	31	being shipped for sorting     	\N	\N	\N	\N
505	397	44	being shipped for sorting     	\N	\N	\N	\N
506	256	18	being shipped for sorting     	\N	\N	\N	\N
507	32	\N	given_in                      	\N	\N	\N	\N
508	350	\N	being sorted for delivery back	\N	\N	\N	\N
509	39	15	being shipped for sorting     	\N	\N	\N	\N
510	377	\N	being cleaned                 	\N	\N	\N	\N
511	363	\N	being cleaned                 	\N	\N	\N	\N
512	164	18	being shipped for sorting     	\N	\N	\N	\N
513	142	\N	being sorted for delivery back	\N	\N	\N	\N
514	96	40	being shipped for sorting     	\N	\N	\N	\N
515	316	45	being shipped for sorting     	\N	\N	\N	\N
516	126	8	being shipped for sorting     	\N	\N	\N	\N
517	339	\N	being sorted for delivery back	\N	\N	\N	\N
518	238	\N	given_in                      	\N	\N	\N	\N
519	159	\N	given_in                      	\N	\N	\N	\N
520	341	\N	given_in                      	\N	\N	\N	\N
521	337	\N	being cleaned                 	\N	\N	\N	\N
522	257	15	being shipped for sorting     	\N	\N	\N	\N
523	150	1	being shipped for sorting     	\N	\N	\N	\N
524	22	\N	being sorted for delivery back	\N	\N	\N	\N
525	44	\N	being sorted for cleaning     	\N	\N	\N	\N
526	360	\N	being sorted for cleaning     	\N	\N	\N	\N
527	11	\N	being sorted for cleaning     	\N	\N	\N	\N
528	372	\N	given_in                      	\N	\N	\N	\N
529	234	14	being shipped for sorting     	\N	\N	\N	\N
530	69	\N	given_in                      	\N	\N	\N	\N
531	277	28	being shipped for sorting     	\N	\N	\N	\N
532	154	5	being shipped for sorting     	\N	\N	\N	\N
533	127	\N	being sorted for cleaning     	\N	\N	\N	\N
534	3	\N	being sorted for delivery back	\N	\N	\N	\N
535	126	\N	given_in                      	\N	\N	\N	\N
536	55	\N	being sorted for delivery back	\N	\N	\N	\N
537	103	\N	being cleaned                 	\N	\N	\N	\N
538	209	\N	being sorted for cleaning     	\N	\N	\N	\N
539	357	\N	being sorted for delivery back	\N	\N	\N	\N
540	107	\N	being cleaned                 	\N	\N	\N	\N
541	300	15	being shipped for sorting     	\N	\N	\N	\N
542	46	41	being shipped for sorting     	\N	\N	\N	\N
543	36	\N	being sorted for delivery back	\N	\N	\N	\N
544	387	\N	being sorted for delivery back	\N	\N	\N	\N
545	310	21	being shipped for sorting     	\N	\N	\N	\N
546	284	\N	given_in                      	\N	\N	\N	\N
547	385	28	being shipped for sorting     	\N	\N	\N	\N
548	48	\N	being sorted for delivery back	\N	\N	\N	\N
549	310	9	being shipped for sorting     	\N	\N	\N	\N
550	399	\N	being cleaned                 	\N	\N	\N	\N
551	122	\N	being cleaned                 	\N	\N	\N	\N
552	358	\N	being sorted for cleaning     	\N	\N	\N	\N
553	274	\N	being sorted for delivery back	\N	\N	\N	\N
554	118	\N	being sorted for delivery back	\N	\N	\N	\N
555	349	\N	being sorted for cleaning     	\N	\N	\N	\N
556	319	\N	being sorted for delivery back	\N	\N	\N	\N
557	334	\N	being cleaned                 	\N	\N	\N	\N
558	373	\N	given_in                      	\N	\N	\N	\N
559	31	43	being shipped for sorting     	\N	\N	\N	\N
560	172	49	being shipped for sorting     	\N	\N	\N	\N
561	314	10	being shipped for sorting     	\N	\N	\N	\N
562	348	\N	being sorted for delivery back	\N	\N	\N	\N
563	66	\N	being sorted for cleaning     	\N	\N	\N	\N
564	387	\N	given_in                      	\N	\N	\N	\N
565	102	40	being shipped for sorting     	\N	\N	\N	\N
566	305	\N	being cleaned                 	\N	\N	\N	\N
567	231	\N	being cleaned                 	\N	\N	\N	\N
568	359	\N	being sorted for cleaning     	\N	\N	\N	\N
569	302	\N	being sorted for delivery back	\N	\N	\N	\N
570	274	\N	given_in                      	\N	\N	\N	\N
571	184	\N	given_in                      	\N	\N	\N	\N
572	293	6	being shipped for sorting     	\N	\N	\N	\N
573	325	50	being shipped for sorting     	\N	\N	\N	\N
574	15	41	being shipped for sorting     	\N	\N	\N	\N
575	91	\N	given_in                      	\N	\N	\N	\N
576	149	12	being shipped for sorting     	\N	\N	\N	\N
577	65	33	being shipped for sorting     	\N	\N	\N	\N
578	98	\N	being sorted for delivery back	\N	\N	\N	\N
579	393	31	being shipped for sorting     	\N	\N	\N	\N
580	187	\N	being sorted for cleaning     	\N	\N	\N	\N
581	7	22	being shipped for sorting     	\N	\N	\N	\N
582	6	\N	given_in                      	\N	\N	\N	\N
583	374	\N	being sorted for delivery back	\N	\N	\N	\N
584	344	\N	being cleaned                 	\N	\N	\N	\N
585	244	26	being shipped for sorting     	\N	\N	\N	\N
586	261	32	being shipped for sorting     	\N	\N	\N	\N
587	265	11	being shipped for sorting     	\N	\N	\N	\N
588	185	11	being shipped for sorting     	\N	\N	\N	\N
589	108	\N	being cleaned                 	\N	\N	\N	\N
590	165	\N	given_in                      	\N	\N	\N	\N
591	49	\N	being sorted for delivery back	\N	\N	\N	\N
592	264	10	being shipped for sorting     	\N	\N	\N	\N
593	335	\N	given_in                      	\N	\N	\N	\N
594	116	\N	being cleaned                 	\N	\N	\N	\N
595	378	\N	given_in                      	\N	\N	\N	\N
596	165	\N	being sorted for cleaning     	\N	\N	\N	\N
597	44	3	being shipped for sorting     	\N	\N	\N	\N
598	145	\N	being sorted for delivery back	\N	\N	\N	\N
599	46	\N	being cleaned                 	\N	\N	\N	\N
600	107	\N	given_in                      	\N	\N	\N	\N
601	20	\N	given_in                      	\N	\N	\N	\N
602	190	\N	being cleaned                 	\N	\N	\N	\N
603	206	43	being shipped for sorting     	\N	\N	\N	\N
604	23	\N	given_in                      	\N	\N	\N	\N
605	347	\N	being sorted for delivery back	\N	\N	\N	\N
606	175	\N	given_in                      	\N	\N	\N	\N
607	179	\N	being cleaned                 	\N	\N	\N	\N
608	354	\N	being sorted for delivery back	\N	\N	\N	\N
609	61	20	being shipped for sorting     	\N	\N	\N	\N
610	272	46	being shipped for sorting     	\N	\N	\N	\N
611	152	11	being shipped for sorting     	\N	\N	\N	\N
612	375	39	being shipped for sorting     	\N	\N	\N	\N
613	326	36	being shipped for sorting     	\N	\N	\N	\N
614	78	\N	being sorted for delivery back	\N	\N	\N	\N
615	59	\N	given_in                      	\N	\N	\N	\N
616	280	\N	being sorted for delivery back	\N	\N	\N	\N
617	329	\N	given_in                      	\N	\N	\N	\N
618	57	17	being shipped for sorting     	\N	\N	\N	\N
619	116	\N	given_in                      	\N	\N	\N	\N
620	219	\N	being sorted for cleaning     	\N	\N	\N	\N
621	328	\N	being cleaned                 	\N	\N	\N	\N
622	15	\N	being sorted for delivery back	\N	\N	\N	\N
623	312	\N	being sorted for cleaning     	\N	\N	\N	\N
624	187	11	being shipped for sorting     	\N	\N	\N	\N
625	63	2	being shipped for sorting     	\N	\N	\N	\N
626	77	27	being shipped for sorting     	\N	\N	\N	\N
627	143	\N	being sorted for delivery back	\N	\N	\N	\N
628	275	\N	being cleaned                 	\N	\N	\N	\N
629	54	\N	given_in                      	\N	\N	\N	\N
630	243	\N	being sorted for delivery back	\N	\N	\N	\N
631	164	21	being shipped for sorting     	\N	\N	\N	\N
632	89	13	being shipped for sorting     	\N	\N	\N	\N
633	32	25	being shipped for sorting     	\N	\N	\N	\N
634	386	\N	being sorted for cleaning     	\N	\N	\N	\N
635	362	\N	given_in                      	\N	\N	\N	\N
636	71	\N	being sorted for delivery back	\N	\N	\N	\N
637	274	\N	being cleaned                 	\N	\N	\N	\N
638	320	\N	being sorted for cleaning     	\N	\N	\N	\N
639	112	\N	being cleaned                 	\N	\N	\N	\N
640	173	\N	being sorted for delivery back	\N	\N	\N	\N
641	17	34	being shipped for sorting     	\N	\N	\N	\N
642	47	\N	being sorted for cleaning     	\N	\N	\N	\N
643	125	11	being shipped for sorting     	\N	\N	\N	\N
644	122	\N	being sorted for delivery back	\N	\N	\N	\N
645	126	49	being shipped for sorting     	\N	\N	\N	\N
646	108	\N	given_in                      	\N	\N	\N	\N
647	78	9	being shipped for sorting     	\N	\N	\N	\N
648	195	49	being shipped for sorting     	\N	\N	\N	\N
649	340	\N	being cleaned                 	\N	\N	\N	\N
650	355	9	being shipped for sorting     	\N	\N	\N	\N
651	382	3	being shipped for sorting     	\N	\N	\N	\N
652	293	\N	being sorted for delivery back	\N	\N	\N	\N
653	297	\N	being sorted for delivery back	\N	\N	\N	\N
654	290	\N	being sorted for delivery back	\N	\N	\N	\N
655	103	27	being shipped for sorting     	\N	\N	\N	\N
656	69	8	being shipped for sorting     	\N	\N	\N	\N
657	198	\N	being cleaned                 	\N	\N	\N	\N
658	145	\N	being sorted for cleaning     	\N	\N	\N	\N
659	52	8	being shipped for sorting     	\N	\N	\N	\N
660	250	\N	being sorted for cleaning     	\N	\N	\N	\N
661	281	29	being shipped for sorting     	\N	\N	\N	\N
662	62	36	being shipped for sorting     	\N	\N	\N	\N
663	152	32	being shipped for sorting     	\N	\N	\N	\N
664	136	\N	being sorted for cleaning     	\N	\N	\N	\N
665	167	33	being shipped for sorting     	\N	\N	\N	\N
666	133	\N	being sorted for delivery back	\N	\N	\N	\N
667	7	38	being shipped for sorting     	\N	\N	\N	\N
668	45	37	being shipped for sorting     	\N	\N	\N	\N
669	61	\N	being cleaned                 	\N	\N	\N	\N
670	284	\N	being sorted for delivery back	\N	\N	\N	\N
671	242	\N	given_in                      	\N	\N	\N	\N
672	329	\N	being sorted for cleaning     	\N	\N	\N	\N
673	197	50	being shipped for sorting     	\N	\N	\N	\N
674	167	\N	being sorted for delivery back	\N	\N	\N	\N
675	291	\N	being sorted for cleaning     	\N	\N	\N	\N
676	52	19	being shipped for sorting     	\N	\N	\N	\N
677	115	\N	being sorted for delivery back	\N	\N	\N	\N
678	136	\N	being cleaned                 	\N	\N	\N	\N
679	146	\N	being sorted for delivery back	\N	\N	\N	\N
680	297	\N	being sorted for cleaning     	\N	\N	\N	\N
681	368	\N	being sorted for cleaning     	\N	\N	\N	\N
682	35	2	being shipped for sorting     	\N	\N	\N	\N
683	60	\N	given_in                      	\N	\N	\N	\N
684	83	15	being shipped for sorting     	\N	\N	\N	\N
685	81	\N	given_in                      	\N	\N	\N	\N
686	191	\N	given_in                      	\N	\N	\N	\N
687	52	\N	being cleaned                 	\N	\N	\N	\N
688	245	\N	being sorted for cleaning     	\N	\N	\N	\N
689	394	\N	given_in                      	\N	\N	\N	\N
690	324	\N	being cleaned                 	\N	\N	\N	\N
691	279	\N	being sorted for delivery back	\N	\N	\N	\N
692	52	\N	being sorted for cleaning     	\N	\N	\N	\N
693	310	\N	being sorted for delivery back	\N	\N	\N	\N
694	322	39	being shipped for sorting     	\N	\N	\N	\N
695	192	\N	being sorted for delivery back	\N	\N	\N	\N
696	21	7	being shipped for sorting     	\N	\N	\N	\N
697	74	4	being shipped for sorting     	\N	\N	\N	\N
698	311	\N	given_in                      	\N	\N	\N	\N
699	43	\N	being sorted for delivery back	\N	\N	\N	\N
700	273	\N	being sorted for delivery back	\N	\N	\N	\N
\.


--
-- Data for Name: couriers; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.couriers (id, name, phone_number, email, is_active) FROM stdin;
1	Карпов Никита Харлампьевич              	+7 (617) 692-9101   	\N	t
2	тов. Никитина Наина Александровна       	8 (956) 087-2654    	\N	t
3	Роман Иосифович Родионов                	88752183274         	\N	f
4	Маргарита Никифоровна Евсеева           	+7 (933) 634-70-54  	jandenisov@mail.ru                      	t
5	Киселева Жанна Владимировна             	8 (164) 830-11-27   	simon66@hotmail.com                     	t
6	Ольга Олеговна Овчинникова              	88926423709         	rusakovamilitsa@yahoo.com               	t
7	Иванна Афанасьевна Гордеева             	8 251 263 0874      	alekse_1993@gmail.com                   	t
8	Онуфрий Богданович Щербаков             	8 (184) 263-88-39   	\N	f
9	Селиверстова Надежда Константиновна     	86361196119         	\N	f
10	Таисия Кузьминична Жукова               	+7 (900) 570-75-29  	moiseevevstafi@gmail.com                	f
11	Лазарева Элеонора Геннадиевна           	+71749258956        	mefodi63@mail.ru                        	t
12	Калашников Севастьян Германович         	+7 (787) 620-8074   	nikiforovajulija@mail.ru                	t
13	Лыткина Таисия Даниловна                	+7 (139) 147-27-01  	foma1973@gmail.com                      	t
14	Шилова Надежда Петровна                 	8 (266) 299-27-67   	filippnaumov@mail.ru                    	f
15	Гордеева Евпраксия Кузьминична          	+7 837 770 02 94    	taras_49@yandex.ru                      	t
16	Варвара Александровна Воробьева         	+7 342 395 9916     	\N	f
17	Беспалов Нифонт Давыдович               	8 (906) 642-79-20   	blohinatatjana@mail.ru                  	t
18	Олимпиада Юрьевна Константинова         	+7 (161) 160-4802   	larisa_69@hotmail.com                   	t
19	Ирина Филипповна Дорофеева              	8 550 453 5704      	gerasim_18@hotmail.com                  	t
20	Соболева Таисия Рудольфовна             	8 (605) 076-0895    	solovevvitali@hotmail.com               	t
21	Трифон Гавриилович Журавлев             	8 488 162 7675      	\N	t
22	Макарова Татьяна Евгеньевна             	80361942394         	naum16@yandex.ru                        	f
23	Майя Аркадьевна Белозерова              	8 063 787 27 51     	german00@rambler.ru                     	f
24	Аполлон Авдеевич Калинин                	+7 275 531 0125     	\N	t
25	Измаил Харлампьевич Кудрявцев           	8 (141) 368-2319    	innokenti1972@yandex.ru                 	f
26	Русакова Маргарита Робертовна           	+7 (610) 389-9919   	ruslan_1978@rambler.ru                  	t
27	Князева Дарья Вадимовна                 	+7 462 790 9584     	\N	f
28	г-н Лихачев Аггей Ерофеевич             	8 (782) 209-99-94   	\N	f
29	Маслова Валерия Захаровна               	+7 835 043 9286     	\N	t
30	Цветков Дементий Димитриевич            	8 040 487 4695      	\N	t
31	Август Ефимьевич Воронцов               	+7 903 445 40 78    	gostomisl_80@mail.ru                    	t
32	Харитонова Алевтина Владимировна        	+71668196508        	svjatoslav_23@rambler.ru                	t
33	Бурова Анжела Константиновна            	+71086339107        	\N	f
34	Белова Юлия Борисовна                   	82839963676         	zinovevfirs@gmail.com                   	f
35	Носкова Агата Анатольевна               	8 (175) 187-71-03   	ititova@yahoo.com                       	t
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.customers (id, name, phone_number, email, address, is_banned) FROM stdin;
86	Клавдий Гордеевич Родионов              	8 (118) 081-78-79   	\N	г. Москва, наб. Широкая, стр. 14, 973136                                                            	t
87	Ковалев Измаил Ерофеевич                	8 (432) 858-10-20   	efremovporfiri@gmail.com                	г. Москва, пр. Луначарского, стр. 5/9, 856813                                                       	f
88	София Антоновна Соловьева               	+7 (753) 881-38-69  	kuzminarseni@hotmail.com                	г. Москва, ул. Почтовая, стр. 814, 285029                                                           	f
89	Кирилл Юльевич Уваров                   	88830343323         	ija19@mail.ru                           	г. Москва, бул. Космонавтов, стр. 80, 302987                                                        	f
90	Титов Ипполит Бенедиктович              	+7 (285) 297-46-78  	\N	г. Москва, пр. Тракторный, стр. 4/3, 291335                                                         	t
91	Михайлов Сила Владиславович             	+7 (571) 382-90-53  	\N	г. Москва, пер. Дачный, стр. 10, 025955                                                             	f
92	Велимир Демидович Самсонов              	+7 252 550 49 54    	uljana1993@hotmail.com                  	\N	f
93	Терентьев Дорофей Матвеевич             	+72247391875        	filatovnarkis@yahoo.com                 	г. Москва, пр. Плеханова, стр. 7, 679877                                                            	f
94	Третьякова Алина Даниловна              	+75077571495        	erofe98@gmail.com                       	г. Москва, пер. Коммунистический, стр. 35, 813794                                                   	f
95	Лонгин Ильич Копылов                    	+7 367 903 7317     	\N	г. Москва, бул. Невского, стр. 23, 736877                                                           	f
96	Беляев Георгий Федосеевич               	+7 (377) 901-51-53  	\N	г. Москва, ул. Колхозная, стр. 882, 294389                                                          	f
97	Олег Ефимьевич Князев                   	8 016 583 5205      	emeljanovaljudmila@rambler.ru           	\N	f
98	Шарапов Семен Арсеньевич                	+7 (285) 347-80-56  	\N	г. Москва, наб. Ульяновская, стр. 2, 306869                                                         	f
99	Варвара Святославовна Быкова            	+7 195 468 4425     	efrem_22@yandex.ru                      	г. Москва, пер. Стахановский, стр. 473, 028466                                                      	f
100	Лидия Ивановна Гордеева                 	+7 (955) 275-0777   	\N	г. Москва, наб. Зои Космодемьянской, стр. 46, 086491                                                	f
101	Амос Геннадиевич Жуков                  	+7 235 153 1614     	evseevorest@hotmail.com                 	г. Москва, алл. Городская, стр. 11, 868234                                                          	f
102	Эмиль Феоктистович Кудряшов             	+7 (573) 866-4271   	\N	г. Москва, алл. Окружная, стр. 4/7, 307039                                                          	t
103	Анисим Григорьевич Громов               	88052886100         	zhdanovairaida@hotmail.com              	г. Москва, ш. Ульяновское, стр. 9, 498943                                                           	f
104	Ефремов Кир Устинович                   	8 (963) 431-90-23   	dementi2013@rambler.ru                  	\N	f
105	Галкин Иван Гавриилович                 	+7 (612) 242-90-50  	antonovluka@mail.ru                     	\N	f
106	Давыд Елизарович Белов                  	+7 (696) 369-29-98  	\N	г. Москва, алл. Российская, стр. 515, 049033                                                        	f
107	Дарья Даниловна Никитина                	+7 (466) 417-9946   	nazarovvadim@hotmail.com                	г. Москва, алл. 8 Марта, стр. 804, 989375                                                           	f
108	Доронин Венедикт Евстигнеевич           	+7 922 823 4932     	\N	г. Москва, пер. Морозова, стр. 219, 036047                                                          	f
109	Раиса Тимуровна Лебедева                	8 156 512 21 95     	fokabikov@gmail.com                     	г. Москва, алл. Тополиная, стр. 1/3, 786136                                                         	f
110	Борис Александрович Архипов             	8 (388) 282-8128    	kallistrat_68@gmail.com                 	г. Москва, пр. Космонавтов, стр. 778, 699290                                                        	f
111	Суворова Ксения Павловна                	8 139 364 06 30     	innokenti2007@yahoo.com                 	\N	f
112	Вероника Степановна Морозова            	+7 449 706 5514     	\N	г. Москва, ул. Смоленская, стр. 166, 086247                                                         	f
113	Мина Харлампьевич Анисимов              	8 659 807 3929      	\N	г. Москва, бул. Поперечный, стр. 3/5, 664072                                                        	f
114	Ирина Викторовна Щербакова              	+7 502 729 3947     	faksenova@yandex.ru                     	\N	f
115	Аполлон Германович Голубев              	+7 (549) 988-8217   	bknjazeva@yahoo.com                     	\N	f
116	Устинов Гремислав Егорович              	+73070548182        	gedeonkozlov@hotmail.com                	г. Москва, бул. 8-е Марта, стр. 7, 514909                                                           	f
117	Петухов Фирс Арсенович                  	+7 (894) 418-07-23  	\N	г. Москва, ш. Горное, стр. 3, 491825                                                                	f
118	Волкова Марфа Антоновна                 	8 623 470 00 45     	belozerovandron@yahoo.com               	г. Москва, ш. Максима Горького, стр. 231, 814891                                                    	f
119	Шашков Кондратий Витальевич             	8 628 858 62 26     	\N	г. Москва, бул. Ударный, стр. 7, 223199                                                             	f
120	Екатерина Семеновна Русакова            	8 933 565 6582      	alina_1975@hotmail.com                  	\N	f
121	Аксенова Надежда Игоревна               	+7 (640) 112-3108   	xmironov@rambler.ru                     	\N	f
122	Спиридон Елисеевич Богданов             	8 230 646 6938      	\N	г. Москва, ул. Верхняя, стр. 26, 166639                                                             	f
123	Андроник Филимонович Субботин           	8 (193) 729-8694    	vladimir1970@mail.ru                    	г. Москва, ул. Гражданская, стр. 314, 449252                                                        	t
124	Марк Харлампович Силин                  	+77670467986        	\N	г. Москва, алл. Театральная, стр. 29, 821878                                                        	f
125	Бобылева Елена Феликсовна               	+7 (448) 202-32-76  	\N	г. Москва, пер. Комсомольский, стр. 45, 240199                                                      	f
126	Лучезар Фадеевич Колесников             	+7 (465) 348-8728   	jan16@gmail.com                         	г. Москва, ул. Черемуховая, стр. 5/8, 817398                                                        	f
127	Велимир Захарьевич Абрамов              	8 035 904 5100      	vatslav_2000@gmail.com                  	\N	t
128	Фомичев Анисим Федосьевич               	8 544 897 49 66     	parfen2008@yahoo.com                    	\N	f
129	Эмилия Федоровна Цветкова               	+7 (811) 111-5401   	milan_86@mail.ru                        	г. Москва, бул. Жукова, стр. 8, 952377                                                              	f
130	Колесников Сергей Марсович              	+7 (993) 972-8579   	\N	г. Москва, ш. Медицинское, стр. 163, 339063                                                         	f
131	Петров Ефим Елизарович                  	+7 (363) 111-90-87  	pahom_2012@hotmail.com                  	\N	f
132	Елизавета Олеговна Савина               	+7 (371) 424-1748   	\N	г. Москва, пер. Свободный, стр. 94, 480699                                                          	f
133	Соловьева Елизавета Руслановна          	8 942 192 56 59     	prohor35@hotmail.com                    	\N	f
134	Сидорова Юлия Феликсовна                	8 (026) 917-29-31   	dementevprov@yahoo.com                  	г. Москва, алл. Фабричная, стр. 6/4, 589248                                                         	f
135	Кудрявцева Наталья Кирилловна           	8 (470) 064-7343    	\N	г. Москва, пр. Спортивный, стр. 28, 212228                                                          	f
136	Куликов Владислав Бориславович          	+7 (161) 796-66-22  	\N	г. Москва, пер. Фрунзе, стр. 910, 423025                                                            	f
137	Никонова Алла Оскаровна                 	+7 742 751 02 50    	\N	г. Москва, алл. Новгородская, стр. 547, 256734                                                      	f
138	Полина Никифоровна Мясникова            	+7 115 989 3733     	\N	г. Москва, ш. Ударное, стр. 4/8, 658725                                                             	f
139	Григорий Ефстафьевич Антонов            	+7 873 305 46 58    	sofron_02@rambler.ru                    	г. Москва, наб. Советская, стр. 95, 122567                                                          	f
140	Прохорова Оксана Владиславовна          	+7 146 138 4381     	averki66@yahoo.com                      	г. Москва, пер. Камский, стр. 3, 770462                                                             	f
141	Маргарита Натановна Жданова             	8 (427) 723-2169    	panovantonin@mail.ru                    	г. Москва, наб. Жуковского, стр. 81, 738791                                                         	f
142	Зимина Эмилия Ивановна                  	+7 (054) 072-0480   	birjukovmili@hotmail.com                	г. Москва, пер. Казачий, стр. 1/3, 629540                                                           	t
143	Татьяна Александровна Блинова           	81793038857         	vadimegorov@yandex.ru                   	г. Москва, пер. Ломоносова, стр. 6, 448954                                                          	f
144	Валентина Федоровна Цветкова            	+7 (767) 690-2294   	mihalovanaina@rambler.ru                	г. Москва, ул. Водопроводная, стр. 80, 199857                                                       	f
145	Овчинникова Зинаида Альбертовна         	80015972038         	\N	г. Москва, алл. Первомайская, стр. 514, 197684                                                      	f
146	Денисова Дарья Юльевна                  	83871901272         	avdeevaolimpiada@yandex.ru              	г. Москва, ул. Красина, стр. 47, 814071                                                             	f
147	Аникей Харлампьевич Игнатов             	83715000762         	\N	г. Москва, алл. Красноармейская, стр. 9, 014043                                                     	f
148	Алевтина Мироновна Соловьева            	+7 075 167 5737     	stanislavdementev@mail.ru               	г. Москва, пер. Проезжий, стр. 618, 101602                                                          	t
149	Жанна Даниловна Чернова                 	+7 659 668 8293     	elise2019@gmail.com                     	\N	t
150	Ладислав Давидович Бобылев              	8 (898) 516-52-20   	julishirjaev@yahoo.com                  	г. Москва, пр. Бульварный, стр. 8/7, 430036                                                         	f
151	Гусева Жанна Валентиновна               	8 (827) 253-78-98   	luka_1992@gmail.com                     	\N	f
152	Анастасия Владиславовна Николаева       	8 264 533 7016      	\N	г. Москва, бул. Подгорный, стр. 4/9, 380607                                                         	f
153	Андреева Вера Мироновна                 	+7 758 613 29 53    	\N	г. Москва, ш. Московское, стр. 809, 214305                                                          	f
154	Русакова Евгения Дмитриевна             	+7 500 908 2504     	mitofan_47@gmail.com                    	\N	f
155	Фома Владленович Харитонов              	84194275480         	viktor_55@hotmail.com                   	\N	f
156	г-жа Сазонова Галина Антоновна          	89458907423         	naina_1995@rambler.ru                   	г. Москва, ул. 30 лет Победы, стр. 2, 937048                                                        	f
157	Эраст Устинович Орехов                  	+7 (967) 466-5120   	milen_41@gmail.com                      	г. Москва, пр. Ягодный, стр. 5/9, 479682                                                            	f
158	Егорова Анастасия Валентиновна          	8 (885) 074-48-21   	\N	г. Москва, бул. Запрудный, стр. 82, 313124                                                          	f
159	Шестаков Селиван Андреевич              	8 294 609 66 66     	lnazarov@rambler.ru                     	\N	f
160	Клавдия Васильевна Быкова               	8 (649) 670-63-38   	lsharapova@gmail.com                    	г. Москва, ш. Толбухина, стр. 3/4, 271118                                                           	f
161	Куприян Валерьевич Дорофеев             	+7 577 325 2908     	askold1999@yahoo.com                    	г. Москва, пер. Макарова, стр. 5, 665952                                                            	f
162	Елена Макаровна Антонова                	+7 (310) 142-7275   	zoja_1973@mail.ru                       	\N	t
163	Меркушев Аристарх Теймуразович          	+7 760 761 2421     	\N	г. Москва, алл. Блюхера, стр. 7, 523551                                                             	f
164	Исаков Емельян Димитриевич              	8 (071) 787-48-91   	kliment_1984@rambler.ru                 	г. Москва, наб. Фестивальная, стр. 5/1, 478058                                                      	f
165	Селиван Харлампович Авдеев              	+7 731 672 4758     	bobilevradim@mail.ru                    	г. Москва, пр. Энергетический, стр. 807, 617145                                                     	f
166	Мельников Стоян Юльевич                 	+78549068513        	silvestrmiheev@hotmail.com              	г. Москва, ш. Центральное, стр. 9/3, 728186                                                         	f
167	Одинцова Ангелина Тимофеевна            	87609445085         	borislav_70@gmail.com                   	г. Москва, наб. Верхняя, стр. 175, 451539                                                           	f
168	Софрон Харлампович Романов              	+7 761 337 67 45    	\N	г. Москва, пер. Коммунистический, стр. 63, 520176                                                   	f
169	Бобылева Антонина Феликсовна            	+7 892 840 95 06    	demjan2021@yahoo.com                    	\N	f
170	Нинель Максимовна Зиновьева             	8 130 234 4601      	zosima_1970@hotmail.com                 	г. Москва, пер. Ольховый, стр. 528, 091709                                                          	f
171	Юлий Игнатович Никитин                  	8 (160) 071-5895    	naum99@mail.ru                          	г. Москва, ул. Театральная, стр. 2, 826889                                                          	f
172	Кириллова Клавдия Борисовна             	+7 (349) 276-2929   	sofija_1977@hotmail.com                 	\N	f
173	Таисия Геннадиевна Михеева              	8 341 659 2927      	silvestr_2018@hotmail.com               	г. Москва, пр. Раздольный, стр. 6, 887004                                                           	f
174	Емельянова Агафья Вениаминовна          	+7 (587) 801-61-45  	pelageja_47@yahoo.com                   	\N	f
175	Гурий Игнатович Тихонов                 	+77867886489        	shubinafevronija@hotmail.com            	\N	f
176	Григорий Устинович Цветков              	+7 049 430 7089     	ykulagina@mail.ru                       	\N	f
177	Ираида Александровна Копылова           	+7 (911) 500-9390   	\N	г. Москва, бул. Грибоедова, стр. 30, 416031                                                         	f
178	Русаков Валерий Бенедиктович            	81569944985         	levseliverstov@rambler.ru               	г. Москва, наб. Кошевого, стр. 791, 580504                                                          	f
179	Валентина Ниловна Ситникова             	8 (021) 384-4602    	lidija1986@gmail.com                    	г. Москва, ш. Восьмого Марта, стр. 68, 432486                                                       	f
180	Казаков Родион Аксёнович                	+7 (028) 284-7991   	\N	г. Москва, ул. Омская, стр. 51, 219394                                                              	t
181	Хохлова Елизавета Романовна             	8 (798) 457-78-01   	frolovisidor@yandex.ru                  	\N	f
182	Анна Леонидовна Горбунова               	+7 136 873 3451     	artemi98@rambler.ru                     	г. Москва, пер. Гайдара, стр. 4, 553575                                                             	f
183	Николаева Светлана Робертовна           	8 819 669 4158      	viktorija2008@mail.ru                   	г. Москва, пер. Партизанский, стр. 187, 427162                                                      	f
184	Кириллова Оксана Аскольдовна            	+7 287 371 52 59    	timur_98@mail.ru                        	\N	f
185	Лыткин Тит Игнатович                    	+7 866 172 84 17    	fnesterov@yandex.ru                     	г. Москва, пр. Южный, стр. 73, 590734                                                               	f
186	Амос Власович Павлов                    	+76622709074        	mihe_1995@hotmail.com                   	г. Москва, пр. Крайний, стр. 384, 136490                                                            	t
187	Горбачев Юлиан Борисович                	8 (197) 823-6761    	\N	г. Москва, наб. Партизанская, стр. 3/8, 929029                                                      	f
188	Гуляев Емельян Фёдорович                	+7 948 523 15 39    	fedor1982@yahoo.com                     	\N	f
189	Самсонов Флорентин Юлианович            	+7 741 699 4773     	gushchingavrila@mail.ru                 	г. Москва, алл. Глинки, стр. 5/7, 813765                                                            	f
190	Светлана Антоновна Горбачева            	84149939027         	\N	г. Москва, пр. Севастопольский, стр. 2, 920397                                                      	f
191	Воробьев Самсон Ильич                   	+7 109 326 9297     	medvedevvladislav@yahoo.com             	г. Москва, наб. Светлая, стр. 821, 860028                                                           	f
192	Стрелков Парфен Викторович              	+7 (182) 973-5223   	\N	г. Москва, бул. Пугачева, стр. 609, 905567                                                          	f
193	Кузнецова Марфа Артемовна               	+7 537 493 9102     	viktorija67@yandex.ru                   	г. Москва, бул. Бригадный, стр. 4/2, 301506                                                         	f
194	Виктория Вениаминовна Афанасьева        	8 (001) 878-3920    	\N	г. Москва, наб. Папанина, стр. 66, 076206                                                           	f
195	Иванов Савелий Якубович                 	8 (034) 684-60-05   	sergeevalidija@yandex.ru                	г. Москва, ул. Осипенко, стр. 43, 403050                                                            	f
196	Степанова Любовь Романовна              	+7 (064) 842-91-75  	titovemeljan@rambler.ru                 	г. Москва, ш. Флотское, стр. 5/5, 743184                                                            	f
197	Григорьев Кузьма Еремеевич              	+7 (751) 250-01-58  	\N	г. Москва, ул. Пролетарская, стр. 672, 012838                                                       	f
198	Белякова Нина Аскольдовна               	+78212160121        	\N	г. Москва, пр. Лесхозный, стр. 183, 656980                                                          	f
199	Владислав Давидович Белов               	8 623 912 2914      	\N	г. Москва, алл. Парковая, стр. 88, 945554                                                           	t
200	Романов Гурий Антипович                 	8 178 300 5385      	\N	г. Москва, бул. Рыбацкий, стр. 8, 064452                                                            	f
201	Наина Тимуровна Колобова                	8 (946) 375-58-51   	kopilovostap@gmail.com                  	г. Москва, алл. Южная, стр. 2/1, 775641                                                             	f
202	Нонна Вадимовна Журавлева               	+7 (931) 086-4508   	vsemilkotov@yahoo.com                   	\N	f
203	Куликова Элеонора Григорьевна           	+7 554 135 8680     	foma96@mail.ru                          	\N	f
204	Лучезар Вячеславович Блинов             	8 398 025 52 84     	\N	г. Москва, ул. Камская, стр. 744, 307928                                                            	f
205	Никодим Денисович Никонов               	+7 (346) 041-32-97  	foti_1998@yahoo.com                     	\N	f
206	Воронова Феврония Григорьевна           	8 675 954 0195      	\N	г. Москва, ш. Подгорное, стр. 2/7, 968351                                                           	f
207	Белова Оксана Вадимовна                 	+7 (598) 548-6245   	jtsvetkov@mail.ru                       	\N	f
208	Павел Борисович Павлов                  	+7 611 153 22 79    	rrozhkova@yahoo.com                     	г. Москва, ш. 1 Мая, стр. 568, 863606                                                               	f
209	Давыд Владиленович Белоусов             	8 (845) 183-1485    	\N	г. Москва, пер. Театральный, стр. 4/4, 221711                                                       	f
210	Дроздов Варфоломей Германович           	8 (405) 349-3275    	\N	г. Москва, наб. Уральская, стр. 727, 302139                                                         	f
211	Смирнов Матвей Герасимович              	8 (858) 341-27-11   	boris_65@gmail.com                      	г. Москва, наб. Спартака, стр. 116, 296270                                                          	f
212	Зоя Викторовна Голубева                 	81975113004         	\N	г. Москва, бул. Дальневосточный, стр. 904, 199287                                                   	f
213	Кондратий Иосипович Ситников            	8 422 781 6987      	\N	г. Москва, пр. Короткий, стр. 7, 518845                                                             	f
214	Тихонов Мефодий Данилович               	8 249 259 10 29     	seleznevsigizmund@yandex.ru             	\N	f
215	Белозерова Ольга Петровна               	+7 306 493 2791     	\N	г. Москва, ш. Болотное, стр. 287, 311726                                                            	f
216	Селезнева Вера Викторовна               	8 754 744 0175      	\N	г. Москва, алл. Профсоюзная, стр. 3/1, 174124                                                       	f
217	Орехова Ираида Альбертовна              	+7 (318) 497-4460   	seleznevaverjan@yandex.ru               	г. Москва, алл. Курортная, стр. 9/5, 607483                                                         	f
218	Соколов Януарий Эдуардович              	8 677 726 39 97     	potapovlavr@mail.ru                     	г. Москва, алл. Бульварная, стр. 2/2, 406913                                                        	f
219	Богдан Александрович Яковлев            	87833769410         	mmuhina@yahoo.com                       	\N	f
220	Эмилия Павловна Рожкова                 	+77565750080        	ovchinnikovaanna@gmail.com              	\N	t
221	Елена Дмитриевна Богданова              	+77509633340        	emilija_1979@yandex.ru                  	г. Москва, ул. Нижняя, стр. 56, 488006                                                              	f
222	Дмитрий Витальевич Селезнев             	+76600982588        	kondratiblinov@yahoo.com                	\N	f
223	Кондрат Иосифович Суханов               	+72904754136        	\N	г. Москва, ш. Рабочее, стр. 8/7, 277332                                                             	f
224	Виноградов Остап Григорьевич            	8 (031) 364-51-62   	evdokija_27@yahoo.com                   	г. Москва, ш. Красноярское, стр. 34, 461785                                                         	f
225	Карл Исидорович Корнилов                	8 460 326 0005      	prokl2002@yahoo.com                     	\N	f
226	Крылова Варвара Кузьминична             	8 633 609 8002      	\N	г. Москва, ш. Королева, стр. 76, 508309                                                             	f
227	Капустин Милен Давыдович                	8 120 136 6810      	\N	г. Москва, ш. Стахановское, стр. 79, 669041                                                         	f
228	Нина Оскаровна Ширяева                  	+7 293 981 92 83    	emeljan_1986@hotmail.com                	г. Москва, пер. М.Горького, стр. 1/1, 353671                                                        	f
229	Вероника Натановна Стрелкова            	8 625 434 88 62     	\N	г. Москва, наб. Кирпичная, стр. 1/4, 284575                                                         	f
230	Раиса Валентиновна Назарова             	+7 101 892 27 03    	\N	г. Москва, ш. Ярославское, стр. 4/9, 812147                                                         	f
231	Князев Варлаам Эдуардович               	+7 521 352 0287     	teterinprohor@yandex.ru                 	г. Москва, ул. Буденного, стр. 111, 699154                                                          	t
232	Сазонова Валентина Эльдаровна           	8 (180) 999-24-14   	bbaranova@rambler.ru                    	г. Москва, наб. Герцена, стр. 4/5, 943598                                                           	f
233	Тимофеева Татьяна Вячеславовна          	+7 106 815 2845     	\N	г. Москва, ул. Правды, стр. 6/7, 504255                                                             	f
234	Медведева Евфросиния Оскаровна          	+7 146 532 0535     	adamzuev@hotmail.com                    	\N	f
235	Любовь Кузьминична Субботина            	8 (160) 455-2600    	evgeni37@hotmail.com                    	г. Москва, пер. Пушкина, стр. 47, 786432                                                            	f
236	Евдоким Ярославович Елисеев             	8 827 431 6181      	avtonom05@rambler.ru                    	г. Москва, ш. Камское, стр. 6, 782067                                                               	f
237	Сила Дмитриевич Герасимов               	8 191 467 50 40     	\N	г. Москва, наб. Поперечная, стр. 25, 727861                                                         	f
238	Марков Андрей Германович                	+7 (396) 856-4402   	osubbotin@yandex.ru                     	г. Москва, пр. Аэродромный, стр. 3, 566337                                                          	f
239	г-н Тарасов Филимон Гордеевич           	+7 (080) 359-90-88  	\N	г. Москва, ул. Орловская, стр. 591, 758718                                                          	f
240	Гусев Мартын Феодосьевич                	+7 (629) 175-2639   	januarikoshelev@yahoo.com               	\N	f
241	Всеслав Ермолаевич Щербаков             	+7 672 454 2293     	\N	г. Москва, пр. Большой, стр. 6/4, 431060                                                            	f
242	Андреев Юлиан Федосеевич                	8 (275) 891-7594    	\N	г. Москва, ул. Школьная, стр. 330, 414014                                                           	f
243	Коновалова Александра Сергеевна         	8 598 200 1751      	evpraksija82@gmail.com                  	г. Москва, ул. Солнечная, стр. 3, 050872                                                            	t
244	Селиверстов Велимир Эдгарович           	+7 037 021 81 29    	\N	г. Москва, бул. Высоковольтный, стр. 4/6, 588920                                                    	f
245	Фотий Филатович Савельев                	+7 (332) 905-9223   	simonovjulian@hotmail.com               	\N	f
246	Денисов Вацлав Ааронович                	+7 (688) 373-22-57  	timofeevandronik@yandex.ru              	г. Москва, бул. Морской, стр. 9/6, 675691                                                           	f
247	Степан Бориславович Хохлов              	8 (175) 589-23-54   	ignatovazinaida@yandex.ru               	\N	f
248	Майя Кузьминична Архипова               	8 (938) 085-6229    	varvara_1977@gmail.com                  	г. Москва, пр. Омский, стр. 54, 220975                                                              	t
249	Антонов Исай Трофимович                 	87425791095         	averki_1975@rambler.ru                  	г. Москва, пер. Кольцова, стр. 8, 099582                                                            	f
250	Симонова Тамара Михайловна              	+7 (883) 194-7763   	tretjakovpantelemon@gmail.com           	г. Москва, ул. Восточная, стр. 22, 545476                                                           	t
251	Фокин Филарет Валерианович              	8 (944) 060-8612    	\N	г. Москва, наб. Красноярская, стр. 5, 138582                                                        	f
252	Григорьева Синклитикия Викторовна       	+7 (678) 153-97-77  	\N	г. Москва, ул. Детская, стр. 661, 041150                                                            	f
253	Гришина Ирина Артемовна                 	85685606068         	saveli_2018@gmail.com                   	г. Москва, алл. Почтовая, стр. 590, 500438                                                          	f
254	Святослав Матвеевич Бобылев             	+7 107 428 91 03    	\N	г. Москва, бул. Плеханова, стр. 905, 991886                                                         	f
255	тов. Фролов Лазарь Викентьевич          	8 (984) 742-7750    	pkolobova@gmail.com                     	\N	f
256	Алла Михайловна Казакова                	+7 (443) 130-35-93  	kapustinnifont@gmail.com                	\N	f
257	Алина Тимофеевна Доронина               	+74910444162        	\N	г. Москва, ул. Лесная, стр. 4/8, 299460                                                             	f
258	Анисимов Олег Вилорович                 	8 144 124 15 24     	kudrjavtsevmechislav@rambler.ru         	г. Москва, пер. Энергетический, стр. 7, 223218                                                      	f
259	Алла Геннадиевна Харитонова             	8 (158) 788-54-07   	\N	г. Москва, бул. Производственный, стр. 5, 507922                                                    	f
260	Пров Брониславович Соболев              	+7 291 303 76 19    	\N	г. Москва, бул. Курчатова, стр. 8, 030722                                                           	f
261	Яковлев Дементий Глебович               	80347949521         	sjakusheva@yahoo.com                    	г. Москва, алл. Димитрова, стр. 9, 453741                                                           	f
262	Влас Фёдорович Меркушев                 	+7 (700) 899-99-06  	\N	г. Москва, пр. Шаумяна, стр. 82, 968469                                                             	f
263	Сазонова Октябрина Валентиновна         	+77742944097        	shchukinsamuil@rambler.ru               	\N	f
264	Бобылев Ефим Гертрудович                	8 (526) 963-3779    	\N	г. Москва, пер. Владимирский, стр. 598, 056066                                                      	f
265	Исидор Брониславович Моисеев            	8 (014) 903-7061    	januari28@yahoo.com                     	г. Москва, ул. Шмидта, стр. 793, 051541                                                             	f
266	Самойлова Ирина Геннадиевна             	+7 (468) 512-07-53  	savvatikudrjavtsev@rambler.ru           	г. Москва, пер. Вахитова, стр. 62, 324476                                                           	f
267	Валерьян Фадеевич Щербаков              	8 720 696 46 64     	gorshkovnaum@yahoo.com                  	\N	f
268	Лидия Ильинична Маркова                 	86054882064         	srogova@yandex.ru                       	\N	t
269	Прасковья Юрьевна Горбачева             	+7 968 831 0260     	\N	г. Москва, наб. Победы, стр. 753, 628199                                                            	f
270	Ильина Октябрина Захаровна              	8 758 492 74 05     	fominairina@gmail.com                   	г. Москва, бул. Лесхозный, стр. 9/3, 385518                                                         	f
271	Егоров Евсей Ермилович                  	+7 847 784 7253     	\N	г. Москва, ул. Пушкинская, стр. 84, 478559                                                          	f
272	Александров Сигизмунд Власович          	+7 (210) 616-94-88  	\N	г. Москва, наб. Надежды, стр. 9, 653530                                                             	f
273	Ситникова Вера Робертовна               	8 (800) 845-1109    	judinamarija@gmail.com                  	г. Москва, наб. Тенистая, стр. 8, 164030                                                            	f
274	Ким Елисеевич Харитонов                 	8 069 140 3217      	\N	г. Москва, бул. Кузнецкий, стр. 8, 337149                                                           	f
275	Богданова Клавдия Константиновна        	8 835 279 3828      	\N	г. Москва, ул. Пугачева, стр. 55, 657759                                                            	f
276	Эмилия Юрьевна Назарова                 	+7 (136) 611-40-94  	noskovtrifon@yahoo.com                  	\N	f
277	Ираида Ивановна Капустина               	8 (648) 410-9243    	tverdislav_22@gmail.com                 	г. Москва, пер. Халтурина, стр. 7, 417756                                                           	f
278	Наина Тимуровна Князева                 	+7 969 134 98 44    	\N	г. Москва, ул. Вахитова, стр. 8/8, 095362                                                           	f
279	Буров Аким Герасимович                  	+75701458478        	isidor_2006@hotmail.com                 	\N	f
280	Гурьева Антонина Владимировна           	+7 (519) 682-3906   	vladimirovvarfolome@mail.ru             	г. Москва, ш. Локомотивное, стр. 9, 637159                                                          	f
281	Евстигней Фокич Коновалов               	8 634 868 3035      	selivanabramov@yahoo.com                	\N	f
282	Кир Ярославович Кудряшов                	+7 240 408 00 97    	hohlovanani@rambler.ru                  	г. Москва, пр. Металлургов, стр. 31, 104238                                                         	f
283	Пестова Валерия Семеновна               	+7 360 692 20 55    	mromanova@gmail.com                     	г. Москва, пер. Донской, стр. 47, 663796                                                            	t
284	Горбачев Ермил Анатольевич              	+7 (043) 711-1819   	nikiforzhuravlev@mail.ru                	г. Москва, бул. Западный, стр. 13, 682622                                                           	f
285	Лаврентьев Никанор Федотович            	+7 510 454 2688     	sinklitikija72@yandex.ru                	\N	f
286	тов. Быкова Тамара Игоревна             	+7 052 299 63 77    	nikiforovboleslav@hotmail.com           	г. Москва, наб. Просвещения, стр. 439, 316601                                                       	f
287	Федорова Иванна Натановна               	+7 239 308 3904     	\N	г. Москва, пр. Донской, стр. 1, 227042                                                              	f
288	Лора Владиславовна Пахомова             	+75136932882        	sobolevdavid@rambler.ru                 	г. Москва, ш. Крайнее, стр. 9, 296092                                                               	f
289	Ангелина Натановна Лазарева             	8 (504) 946-4378    	rogovfade@mail.ru                       	\N	f
290	Кулакова Анжелика Матвеевна             	+7 699 044 13 82    	radim_1990@hotmail.com                  	\N	f
291	Флорентин Ануфриевич Некрасов           	+7 304 327 1806     	\N	г. Москва, алл. Калинина, стр. 2, 704846                                                            	f
292	Герасим Ильич Лаврентьев                	8 992 744 03 96     	vinogradovarkadi@yahoo.com              	г. Москва, ул. Энергетиков, стр. 17, 284697                                                         	f
293	Прасковья Николаевна Мишина             	+7 141 590 39 57    	morozovlongin@hotmail.com               	г. Москва, пр. Гаражный, стр. 693, 070077                                                           	f
294	Нинель Афанасьевна Дьячкова             	+7 197 799 70 18    	beljakovanonna@rambler.ru               	г. Москва, бул. Запрудный, стр. 268, 004274                                                         	f
295	Ирина Романовна Ермакова                	8 283 051 5497      	\N	г. Москва, пер. Войкова, стр. 1/8, 025755                                                           	t
296	Агафья Леонидовна Сазонова              	8 (539) 383-8537    	modest76@rambler.ru                     	г. Москва, пер. Абрикосовый, стр. 65, 398811                                                        	f
297	Крылова Таисия Ждановна                 	8 (936) 175-7735    	yvoronova@mail.ru                       	г. Москва, ш. Лунное, стр. 17, 617908                                                               	f
298	Лонгин Иларионович Родионов             	+71514209389        	vera_1990@yahoo.com                     	г. Москва, бул. Правды, стр. 601, 648933                                                            	t
299	Ипат Игнатьевич Гордеев                 	+7 056 460 5022     	\N	г. Москва, ул. Глинки, стр. 72, 821504                                                              	f
300	Анастасия Болеславовна Воробьева        	+7 509 309 37 25    	mjasnikovpolikarp@gmail.com             	г. Москва, наб. Революции, стр. 3, 778697                                                           	f
301	Орехов Юлий Владиленович                	8 011 967 3671      	azari1985@gmail.com                     	\N	f
302	Тамара Архиповна Алексеева              	+72570635867        	gedeon1976@gmail.com                    	г. Москва, бул. Февральский, стр. 6/3, 522758                                                       	f
303	Ершова Лукия Викторовна                 	8 233 238 4603      	zoja1988@mail.ru                        	г. Москва, бул. Строительный, стр. 12, 650650                                                       	f
304	Феофан Димитриевич Силин                	8 (307) 710-13-43   	julija_2003@yahoo.com                   	\N	f
305	Тарасова Валентина Сергеевна            	+7 168 552 9619     	ignatevemeljan@rambler.ru               	\N	f
306	Наталья Архиповна Лазарева              	8 933 949 9215      	\N	г. Москва, алл. Элеваторная, стр. 2/4, 075529                                                       	f
307	Родионов Дорофей Владиленович           	86637727185         	zaharovjan@yandex.ru                    	г. Москва, ш. Саратовское, стр. 496, 203004                                                         	f
308	Татьяна Владимировна Гордеева           	8 (573) 645-57-95   	xmiheev@gmail.com                       	\N	f
309	Лаврентьев Исидор Ефстафьевич           	+75020528658        	turovaljudmila@yahoo.com                	г. Москва, наб. Строительная, стр. 33, 902829                                                       	f
310	Родионова Раиса Николаевна              	+7 329 181 99 87    	ruslan_69@rambler.ru                    	г. Москва, алл. Восьмого Марта, стр. 314, 311303                                                    	f
311	Всемил Адрианович Новиков               	+7 776 533 22 50    	\N	г. Москва, бул. Заводской, стр. 3, 004181                                                           	f
312	Блохин Никита Георгиевич                	8 (394) 700-63-33   	\N	г. Москва, пер. Седова, стр. 82, 602252                                                             	f
313	Назар Арсеньевич Бирюков                	+79010547218        	vsazonov@mail.ru                        	г. Москва, бул. Нахимова, стр. 15, 743472                                                           	f
314	Белозерова Виктория Григорьевна         	+7 (151) 967-2952   	jegorova@mail.ru                        	г. Москва, пр. Высотный, стр. 91, 505264                                                            	f
315	Екатерина Матвеевна Гаврилова           	+77927648080        	natalja_41@mail.ru                      	г. Москва, ул. Монтажников, стр. 966, 259506                                                        	f
316	Ефрем Валерьянович Пономарев            	8 725 687 37 95     	gennadi_12@yandex.ru                    	г. Москва, бул. Бульварный, стр. 7/6, 247941                                                        	f
317	Евсеева Ольга Константиновна            	+7 949 005 3546     	kornilovsilanti@yandex.ru               	г. Москва, ш. Снежное, стр. 2, 681105                                                               	f
318	Меркушева Екатерина Эдуардовна          	8 909 818 64 98     	\N	г. Москва, наб. Харьковская, стр. 425, 008589                                                       	f
319	Александра Рубеновна Моисеева           	8 (301) 044-7643    	ipat1974@hotmail.com                    	\N	f
320	Давыдова Анна Валентиновна              	81377767362         	\N	г. Москва, пер. Каштановый, стр. 76, 195199                                                         	t
321	Казакова Анжелика Феликсовна            	+7 (644) 407-45-46  	\N	г. Москва, пр. Маркса, стр. 233, 520268                                                             	f
322	Алевтина Макаровна Красильникова        	8 070 129 83 92     	\N	г. Москва, ш. Краснознаменное, стр. 7, 721939                                                       	t
323	Абрамов Автоном Феоктистович            	83581688030         	\N	г. Москва, пер. Жуковского, стр. 485, 077278                                                        	f
324	Фаина Матвеевна Чернова                 	8 (699) 603-4184    	\N	г. Москва, наб. Азина, стр. 882, 286881                                                             	f
325	Назар Юлианович Григорьев               	+7 (880) 270-26-19  	pantelemonromanov@yahoo.com             	\N	f
326	Федорова Агафья Натановна               	+7 088 147 0277     	\N	г. Москва, пр. Карбышева, стр. 8/2, 725877                                                          	f
327	Никифорова Анжела Семеновна             	81311495980         	\N	г. Москва, наб. Гончарова, стр. 1/4, 466892                                                         	f
328	Антонина Тарасовна Белякова             	+7 555 416 24 82    	\N	г. Москва, пер. Морской, стр. 2/7, 245554                                                           	f
329	Конон Владиленович Буров                	8 034 316 2297      	aromanov@mail.ru                        	г. Москва, алл. Советская, стр. 17, 993815                                                          	f
330	Одинцова Ия Архиповна                   	+7 680 092 2230     	svetlana_56@gmail.com                   	г. Москва, бул. Боровой, стр. 87, 253908                                                            	t
331	Дьячкова Юлия Сергеевна                 	8 (605) 019-15-75   	potapovaljubov@gmail.com                	г. Москва, алл. Спартака, стр. 334, 184509                                                          	t
332	Пономарева Василиса Сергеевна           	8 917 073 91 55     	anike13@yandex.ru                       	г. Москва, ш. Рябиновое, стр. 9, 772132                                                             	f
333	Нинель Филипповна Миронова              	+7 (630) 947-0575   	\N	г. Москва, ш. Ягодное, стр. 8/8, 669833                                                             	f
334	Семен Эдгарович Осипов                  	+7 (901) 136-4433   	\N	г. Москва, ш. Ворошилова, стр. 9, 686374                                                            	t
335	Рябов Кондратий Андреевич               	8 748 670 9649      	gerasim45@yahoo.com                     	г. Москва, алл. Добролюбова, стр. 1/1, 699702                                                       	t
336	Вышеслав Виленович Соболев              	+7 (729) 279-7643   	ignati2004@yahoo.com                    	г. Москва, ул. Гастелло, стр. 46, 179428                                                            	f
337	Павлов Пимен Владиславович              	86887250712         	\N	г. Москва, ш. Береговое, стр. 453, 545176                                                           	f
338	Афанасий Герасимович Панфилов           	+7 855 045 5704     	belozerovaolga@rambler.ru               	г. Москва, бул. Окружной, стр. 2, 618718                                                            	f
339	Жанна Олеговна Одинцова                 	8 (866) 176-70-20   	\N	г. Москва, наб. З.Космодемьянской, стр. 9/6, 334697                                                 	t
340	Кабанов Куприян Игоревич                	+7 (204) 795-51-12  	\N	г. Москва, ш. Громова, стр. 6, 553776                                                               	f
341	Андрон Венедиктович Титов               	+7 (200) 341-0413   	\N	г. Москва, алл. Набережная, стр. 129, 566694                                                        	t
342	Максимова Фаина Анатольевна             	+73876698164        	fominsilvestr@rambler.ru                	г. Москва, алл. Добролюбова, стр. 1/2, 833503                                                       	f
343	Раиса Ниловна Кондратьева               	+70105503092        	angelina2006@yahoo.com                  	г. Москва, ш. Сиреневое, стр. 85, 863770                                                            	f
344	Дмитрий Викторович Владимиров           	80918498217         	timofeevkonon@yahoo.com                 	\N	t
345	тов. Гусева Анна Викторовна             	+7 (665) 793-7927   	fkolesnikova@yahoo.com                  	г. Москва, алл. Ленинградская, стр. 321, 603989                                                     	f
346	Логинова Василиса Филипповна            	+7 (565) 162-3703   	\N	г. Москва, ш. Кавказское, стр. 8/1, 319074                                                          	f
347	Спиридон Ефремович Капустин             	+7 (473) 496-08-83  	\N	г. Москва, пр. Гагарина, стр. 1, 940374                                                             	f
348	Никифоров Автоном Александрович         	+77119346015        	timofe06@yandex.ru                      	г. Москва, алл. Макарова, стр. 405, 977174                                                          	f
349	Васильева Анна Семеновна                	8 (239) 230-30-60   	\N	г. Москва, ул. Юности, стр. 2/9, 842989                                                             	f
350	Иванна Болеславовна Шарапова            	8 (357) 275-2387    	osip_25@hotmail.com                     	\N	f
351	Мокей Юльевич Кабанов                   	+7 472 398 7961     	\N	г. Москва, пер. Северный, стр. 79, 801953                                                           	f
352	Самойлов Серафим Эдуардович             	+7 (153) 927-40-46  	evdokimovapelageja@rambler.ru           	г. Москва, алл. Серафимовича, стр. 3, 487051                                                        	f
353	Анисимова Клавдия Матвеевна             	+7 304 249 5329     	zinaida1987@yandex.ru                   	г. Москва, ул. Юбилейная, стр. 5/5, 695691                                                          	f
354	Иванова Лидия Даниловна                 	+7 (222) 256-2699   	gosipova@gmail.com                      	г. Москва, пер. Индустриальный, стр. 153, 508686                                                    	f
355	Назар Артёмович Белов                   	8 (307) 286-93-78   	gremislav1983@hotmail.com               	г. Москва, бул. Пархоменко, стр. 904, 867213                                                        	f
356	Глафира Феликсовна Гурьева              	+74704749844        	guljaevamvrosi@gmail.com                	\N	f
357	Сергей Фокич Емельянов                  	+7 (264) 652-67-02  	zuevelizar@mail.ru                      	г. Москва, алл. Заовражная, стр. 824, 601590                                                        	f
358	Пономарева Таисия Макаровна             	8 419 467 03 16     	\N	г. Москва, алл. 50 лет ВЛКСМ, стр. 346, 272696                                                      	f
359	Архипов Анисим Анатольевич              	+7 060 879 24 61    	tihon1974@gmail.com                     	г. Москва, бул. Рыбацкий, стр. 800, 258876                                                          	f
360	Майя Максимовна Алексеева               	87695447248         	fedorovajulija@yandex.ru                	г. Москва, пр. Кирова, стр. 8, 989017                                                               	f
361	Юлия Ниловна Агафонова                  	+7 (917) 774-0697   	alekse_1992@yahoo.com                   	г. Москва, ул. 8-е Марта, стр. 5, 806660                                                            	f
362	Борислав Ааронович Уваров               	+79510337357        	\N	г. Москва, ул. Полевая, стр. 894, 481000                                                            	f
363	Воронцова Ксения Вадимовна              	+7 (965) 543-5528   	merkushevstanislav@yandex.ru            	г. Москва, алл. Мелиораторов, стр. 4/5, 559948                                                      	f
364	Серафим Германович Федосеев             	8 963 144 52 63     	\N	г. Москва, ул. Астраханская, стр. 116, 740153                                                       	f
365	Сазонов Фадей Гаврилович                	+7 611 381 0298     	\N	г. Москва, ш. Ушакова, стр. 23, 978824                                                              	f
366	Добромысл Афанасьевич Григорьев         	8 (552) 605-2583    	pimen_2021@yandex.ru                    	г. Москва, алл. Окружная, стр. 6, 962112                                                            	f
367	Кондратьева Раиса Святославовна         	+7 318 098 4428     	leonid_19@yahoo.com                     	г. Москва, пр. Республиканский, стр. 872, 687612                                                    	f
368	тов. Пономарев Максимильян Давыдович    	+75476754010        	\N	г. Москва, ш. Просвещения, стр. 7, 734989                                                           	f
369	Быкова Виктория Владимировна            	+7 700 022 3981     	\N	г. Москва, пер. Заовражный, стр. 200, 593402                                                        	f
370	Галактион Адрианович Лихачев            	8 (260) 122-6575    	nestor_29@rambler.ru                    	г. Москва, ш. Малиновое, стр. 947, 865742                                                           	f
371	Муравьева Нина Юльевна                  	8 (600) 270-3761    	galkinandronik@yahoo.com                	г. Москва, алл. Советская, стр. 189, 243444                                                         	f
372	Быкова Клавдия Викторовна               	+7 036 728 1923     	rostislavknjazev@yandex.ru              	г. Москва, ул. Подстанция, стр. 44, 021702                                                          	t
373	Крылова Антонина Натановна              	8 (876) 740-02-57   	apollon1981@mail.ru                     	г. Москва, алл. Тепличная, стр. 41, 969031                                                          	f
374	Мясникова Надежда Александровна         	8 (349) 084-9928    	torehov@yahoo.com                       	г. Москва, пер. Театральный, стр. 1, 977200                                                         	f
375	Тетерина Нина Ниловна                   	+71919452872        	\N	г. Москва, ш. Каштановое, стр. 96, 354519                                                           	f
376	Пономарева Алевтина Георгиевна          	+7 (065) 823-58-58  	lavrenti2015@mail.ru                    	\N	f
377	Уваров Петр Ефремович                   	+7 999 577 7621     	\N	г. Москва, ул. Тамбовская, стр. 6/3, 311460                                                         	f
378	Бобров Ростислав Евсеевич               	86609996843         	kirillovgerasim@mail.ru                 	г. Москва, алл. Трудовая, стр. 193, 819076                                                          	f
379	Богдан Захарьевич Савин                 	8 (213) 293-07-45   	nikolaevnatan@gmail.com                 	г. Москва, ул. Интернациональная, стр. 89, 765276                                                   	f
380	Стрелков Руслан Борисович               	8 540 136 2523      	vjacheslav_2003@hotmail.com             	г. Москва, ш. Папанина, стр. 9/4, 643083                                                            	f
381	Ананий Ефимович Казаков                 	8 258 746 6932      	\N	г. Москва, бул. Лунный, стр. 63, 107792                                                             	f
382	Евграф Виленович Третьяков              	8 972 077 9581      	ttrofimova@hotmail.com                  	\N	f
383	Гордеев Михей Ефимович                  	+78889718154        	\N	г. Москва, пр. Есенина, стр. 4/1, 027399                                                            	f
384	Мамонтов Спиридон Артурович             	8 135 517 1982      	\N	г. Москва, бул. Придорожный, стр. 4/7, 259213                                                       	f
385	Алексеева Ия Рудольфовна                	8 (658) 966-5887    	abobrova@yahoo.com                      	\N	f
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.departments (id, address, phone_number, requires_shipment) FROM stdin;
1	г. Москва, пер. Рязанский, стр. 29, 344270                                                          	8 (570) 519-1931    	f
2	г. Москва, пер. Магистральный, стр. 53, 667736                                                      	8 (460) 152-18-72   	f
3	г. Москва, пр. Нагорный, стр. 610, 009735                                                           	+7 646 955 82 75    	f
4	г. Москва, наб. Рязанская, стр. 5, 453212                                                           	+70377663252        	f
5	г. Москва, наб. Крымская, стр. 57, 563831                                                           	+7 (245) 196-7588   	f
6	г. Москва, наб. Краснопартизанская, стр. 6, 721110                                                  	+7 (273) 322-7079   	f
7	г. Москва, наб. Леонова, стр. 321, 485003                                                           	+7 (429) 170-07-45  	f
8	г. Москва, наб. Приозерная, стр. 78, 125154                                                         	+7 570 503 59 78    	f
9	г. Москва, пер. Олега Кошевого, стр. 44, 812687                                                     	8 016 673 31 95     	f
10	г. Москва, пер. 8-е Марта, стр. 90, 481973                                                          	8 363 975 7386      	f
11	г. Москва, пер. Калужский, стр. 8/6, 069456                                                         	8 753 892 89 14     	f
12	г. Москва, ш. Строителей, стр. 8, 693721                                                            	+7 509 938 30 61    	f
13	г. Москва, бул. Спартака, стр. 74, 327159                                                           	8 (973) 727-1735    	f
14	г. Москва, наб. Есенина, стр. 62, 086904                                                            	+7 801 139 7130     	f
15	г. Москва, пр. Калинина, стр. 98, 272034                                                            	83511563641         	f
16	г. Москва, наб. Песчаная, стр. 66, 231751                                                           	+7 133 274 43 55    	f
17	г. Москва, ш. Выгонное, стр. 54, 495754                                                             	8 (911) 496-4427    	f
18	г. Москва, пр. Водопроводный, стр. 1/5, 017750                                                      	+7 184 835 03 26    	f
19	г. Москва, пр. Звездный, стр. 63, 692924                                                            	8 (413) 287-21-90   	f
20	г. Москва, ул. Надежды, стр. 61, 710159                                                             	8 (580) 386-3683    	f
21	г. Москва, наб. Речная, стр. 2, 780973                                                              	+7 280 736 54 79    	f
22	г. Москва, пр. Литейный, стр. 450, 791254                                                           	+7 (018) 171-94-95  	f
23	г. Москва, ш. Иркутское, стр. 2, 966973                                                             	+7 (949) 446-8086   	f
24	г. Москва, бул. Правды, стр. 6/6, 888024                                                            	8 799 077 49 41     	f
25	г. Москва, бул. Сенной, стр. 25, 715779                                                             	8 (843) 080-9401    	f
\.


--
-- Data for Name: managers; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.managers (id, name, phone_number, email, department_id, "position", is_active) FROM stdin;
36	Фадеев Сила Терентьевич                 	+79604353806        	vorontsovairina@yandex.ru               	4	Manager                       	t
37	Варвара Кузьминична Власова             	85657118016         	nikitabragin@rambler.ru                 	20	Senior Manager                	f
38	Евгения Леоновна Давыдова               	8 (141) 280-3454    	novikovsilanti@rambler.ru               	22	Manager                       	t
39	Турова Элеонора Мироновна               	+7 (419) 659-01-14  	kondrati1986@yahoo.com                  	16	Manager                       	f
40	Поляков Никодим Гордеевич               	+7 724 170 5396     	krilovnestor@gmail.com                  	15	Manager                       	f
41	Эдуард Трофимович Журавлев              	+78315725158        	vikenti2008@rambler.ru                  	19	Senior Manager                	t
42	Зинаида Дмитриевна Мартынова            	89869055955         	glebjakovlev@yandex.ru                  	15	Senior Manager                	t
43	Оксана Станиславовна Калашникова        	8 (774) 088-3307    	romanovdobromisl@yandex.ru              	3	Senior Manager                	t
44	Демид Георгиевич Никифоров              	+7 (592) 247-8685   	florentin07@hotmail.com                 	20	Manager                       	t
45	Логинов Валентин Анатольевич            	8 656 340 3912      	jakushevermola@gmail.com                	1	General Manager               	f
46	Давыдова Валерия Оскаровна              	8 074 637 26 15     	aleksandra_23@hotmail.com               	7	Senior Manager                	t
47	Ипполит Валерьевич Степанов             	+75217463455        	volkovapollon@rambler.ru                	9	Manager                       	f
48	Вера Ефимовна Тетерина                  	84707878855         	nina_1972@hotmail.com                   	3	Manager                       	f
49	Ермакова Тамара Тимуровна               	8 (712) 433-42-47   	tvorimir_1984@yahoo.com                 	23	Manager                       	t
50	Нинель Робертовна Волкова               	80155150186         	belozerovbronislav@yahoo.com            	18	Manager                       	f
51	Мартынов Любим Викентьевич              	+7 856 370 19 40    	terentismirnov@hotmail.com              	14	Manager                       	t
52	Парамон Иосифович Воронцов              	82885577909         	pimenkotov@gmail.com                    	23	Manager                       	f
53	Василиса Мироновна Жданова              	+7 (946) 515-21-83  	mishinsavva@rambler.ru                  	25	Senior Manager                	f
54	Василиса Львовна Ильина                 	8 544 482 09 03     	zhukovazhanna@yahoo.com                 	17	Manager                       	t
55	Колобова Дарья Аркадьевна               	8 (550) 199-7811    	sokolovkim@mail.ru                      	10	Manager                       	t
56	Юлия Александровна Меркушева            	8 (551) 536-4749    	konstantin96@hotmail.com                	5	Senior Manager                	t
57	Юлия Артемовна Ситникова                	+72996409174        	seleznevnifont@gmail.com                	1	Senior Manager                	t
58	Коновалова Полина Александровна         	+71067062952        	anani82@rambler.ru                      	15	Manager                       	t
59	Кондратьева Вероника Степановна         	+7 (603) 539-31-61  	doroninaljudmila@yandex.ru              	16	Manager                       	t
60	Ларионов Ермил Вилорович                	+7 243 902 7100     	stepan75@hotmail.com                    	22	Manager                       	t
61	Беляев Роман Тимурович                  	+7 (557) 720-7242   	miheevaaleksandra@yahoo.com             	6	Manager                       	t
62	Колобов Изот Абрамович                  	+7 (917) 606-8125   	tverdislav83@yandex.ru                  	15	Manager                       	t
63	Олимпиада Эльдаровна Ларионова          	85874418684         	spartakaksenov@hotmail.com              	13	General Manager               	t
64	Каллистрат Борисович Захаров            	8 (914) 512-86-62   	miroslavmamontov@hotmail.com            	14	Senior Manager                	t
65	Сысоев Тит Гаврилович                   	+7 061 007 67 56    	fedot_2000@rambler.ru                   	16	Manager                       	f
66	Марфа Максимовна Васильева              	8 891 153 94 90     	miroslav_2000@rambler.ru                	6	General Manager               	t
67	Уварова Прасковья Архиповна             	80724233309         	ymuhina@hotmail.com                     	21	Manager                       	t
68	Ильин Карл Геннадиевич                  	+7 044 475 20 89    	avtonom14@rambler.ru                    	4	Manager                       	t
69	Сергеев Вениамин Богданович             	+7 (749) 058-0053   	chernovmaksim@hotmail.com               	25	Senior Manager                	t
70	Ия Никифоровна Кудрявцева               	8 254 816 19 65     	anisimovaelena@yandex.ru                	25	Manager                       	t
71	Гремислав Ефстафьевич Селезнев          	+7 172 426 1226     	baranovaklavdija@gmail.com              	17	Senior Manager                	t
72	Фокин Аскольд Чеславович                	82507362153         	morozovpanfil@yahoo.com                 	6	Manager                       	t
73	Власова Маргарита Захаровна             	+73225818325        	vasili_11@gmail.com                     	13	Manager                       	t
74	Лариса Михайловна Коновалова            	8 (922) 467-0142    	demidblinov@rambler.ru                  	13	Manager                       	f
75	Фомичева Светлана Никифоровна           	+7 (625) 158-6134   	semenovefim@hotmail.com                 	4	Manager                       	t
76	Кузьмина Надежда Антоновна              	84526780864         	pelageja1982@yahoo.com                  	16	Manager                       	t
77	Лидия Наумовна Лапина                   	+7 (685) 604-21-86  	lihachevamvrosi@mail.ru                 	2	Senior Manager                	f
78	Аксенова Лора Семеновна                 	8 067 777 12 47     	kkotov@yahoo.com                        	14	Manager                       	t
79	Дементьев Силантий Владиленович         	+7 (349) 527-8939   	novikovizmail@rambler.ru                	18	Manager                       	t
80	Мария Валериевна Павлова                	83187131152         	evstigne_2007@yandex.ru                 	19	Senior Manager                	t
81	Кошелева Юлия Оскаровна                 	+7 313 842 1762     	denisovaantonina@yandex.ru              	8	Senior Manager                	t
82	Евстафий Иларионович Игнатьев           	8 (320) 149-3698    	varfolomeandreev@mail.ru                	11	Manager                       	f
83	Суханов Якуб Юльевич                    	+7 744 608 60 27    	bikovnikodim@gmail.com                  	21	Senior Manager                	f
84	Гаврила Арсеньевич Марков               	+7 125 486 6424     	agafonovakira@yandex.ru                 	3	Manager                       	f
85	Вишнякова Таисия Николаевна             	8 (517) 784-15-84   	fseliverstov@yahoo.com                  	16	Manager                       	t
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.orders (id, customer_id, department_id, manager_id, creation_date, due_date, actual_finish_date, status, is_prepayed, is_express, to_be_delievered, customer_comment, delivery_comment) FROM stdin;
1	120	17	66	2019-11-25	2019-12-02	2019-12-01	arrived to customer           	f	f	t	\N	\N
2	363	24	41	2018-02-02	2018-02-09	2018-02-09	arrived to customer           	f	f	t	\N	\N
3	184	5	78	2018-11-19	2018-11-23	\N	being cleaned                 	f	f	f	\N	\N
4	270	6	73	2021-06-11	2021-06-15	2021-06-14	arrived to customer           	f	f	t	\N	\N
5	227	2	50	2020-03-28	2020-04-01	\N	created                       	f	f	f	\N	\N
6	181	25	83	2020-10-23	2020-10-27	\N	awaiting other clothes        	f	f	f	\N	\N
7	113	7	64	2018-06-29	2018-07-03	\N	being cleaned                 	f	f	f	\N	\N
8	292	12	71	2021-09-07	2021-09-14	\N	created                       	f	f	f	\N	\N
9	129	13	76	2019-04-20	2019-04-27	\N	being cleaned                 	f	f	f	\N	\N
10	279	3	45	2019-11-21	2019-11-28	\N	being cleaned                 	f	f	f	\N	\N
11	233	25	45	2018-10-08	2018-10-15	\N	created                       	f	f	f	\N	\N
12	287	20	39	2019-12-13	2019-12-20	2019-12-19	arrived to customer           	f	f	t	\N	\N
13	151	22	40	2019-04-01	2019-04-08	\N	awaiting other clothes        	f	f	f	\N	\N
14	128	25	47	2019-06-08	2019-06-12	2019-06-12	arrived back to department    	f	f	f	\N	\N
15	163	21	45	2018-10-30	2018-11-03	2018-11-02	arrived to customer           	f	f	t	\N	\N
16	198	6	36	2018-02-21	2018-02-25	2018-02-24	arrived to customer           	f	f	t	\N	\N
17	365	2	69	2019-06-11	2019-06-18	\N	being cleaned                 	f	f	f	\N	\N
18	150	22	66	2020-08-24	2020-08-31	\N	awaiting other clothes        	f	f	f	\N	\N
19	269	12	39	2018-09-02	2018-09-06	\N	created                       	f	f	f	\N	\N
20	164	23	65	2018-12-14	2018-12-18	\N	being cleaned                 	f	f	f	\N	\N
21	201	23	42	2019-08-03	2019-08-07	\N	awaiting other clothes        	f	f	f	\N	\N
22	369	13	62	2018-01-24	2018-01-28	2018-01-27	arrived to customer           	f	f	t	\N	\N
23	185	19	70	2020-03-03	2020-03-07	2020-03-06	arrived to customer           	f	f	t	\N	\N
24	216	17	82	2021-08-15	2021-08-22	\N	created                       	f	f	f	\N	\N
25	362	17	65	2021-03-04	2021-03-08	2021-03-07	arrived back to department    	f	f	f	\N	\N
26	100	3	84	2021-01-25	2021-01-29	\N	being cleaned                 	f	f	f	\N	\N
27	291	13	46	2020-06-25	2020-06-29	2020-06-30	arrived to customer           	f	f	t	\N	\N
28	316	24	85	2020-11-04	2020-11-08	\N	awaiting other clothes        	f	f	f	\N	\N
29	292	19	74	2021-01-09	2021-01-13	\N	created                       	f	f	f	\N	\N
30	158	21	54	2019-08-17	2019-08-24	\N	being cleaned                 	f	f	f	\N	\N
31	383	6	39	2018-07-11	2018-07-15	\N	created                       	f	f	f	\N	\N
32	244	7	77	2021-10-05	2021-10-09	\N	being cleaned                 	f	f	f	\N	\N
33	198	20	63	2018-12-23	2018-12-30	\N	awaiting other clothes        	f	f	f	\N	\N
34	225	6	56	2020-04-22	2020-04-26	\N	awaiting other clothes        	f	f	f	\N	\N
35	128	16	36	2019-05-28	2019-06-01	\N	created                       	f	f	f	\N	\N
36	352	23	57	2020-12-23	2020-12-27	\N	created                       	f	f	f	\N	\N
37	263	13	58	2021-10-25	2021-11-01	\N	being cleaned                 	f	f	f	\N	\N
38	99	4	75	2020-11-10	2020-11-14	\N	created                       	f	f	f	\N	\N
39	316	17	78	2018-03-10	2018-03-14	\N	being cleaned                 	f	f	f	\N	\N
40	289	20	41	2019-02-06	2019-02-10	2019-02-09	arrived to customer           	f	f	t	\N	\N
41	192	7	43	2021-06-28	2021-07-02	\N	being cleaned                 	f	f	f	\N	\N
42	289	6	48	2020-06-05	2020-06-12	2020-06-12	arrived back to department    	f	f	f	\N	\N
43	98	20	75	2019-04-17	2019-04-24	\N	awaiting other clothes        	f	f	f	\N	\N
44	282	9	84	2020-05-09	2020-05-13	2020-05-13	arrived to customer           	f	f	t	\N	\N
45	113	11	74	2019-06-27	2019-07-04	\N	being cleaned                 	f	f	f	\N	\N
46	211	21	53	2018-11-15	2018-11-19	\N	being cleaned                 	f	f	f	\N	\N
47	105	3	82	2021-07-14	2021-07-18	\N	awaiting other clothes        	f	f	f	\N	\N
48	136	2	70	2021-01-31	2021-02-04	\N	awaiting other clothes        	f	f	f	\N	\N
49	214	21	47	2018-04-13	2018-04-17	\N	being cleaned                 	f	f	f	\N	\N
50	178	4	51	2019-06-18	2019-06-25	\N	being cleaned                 	f	f	f	\N	\N
51	343	21	54	2020-02-19	2020-02-26	\N	being cleaned                 	f	f	f	\N	\N
52	206	4	59	2019-11-13	2019-11-17	\N	awaiting other clothes        	f	f	f	\N	\N
53	207	10	48	2020-09-30	2020-10-07	2020-10-08	arrived to customer           	f	f	t	\N	\N
54	286	11	61	2018-07-12	2018-07-19	\N	awaiting other clothes        	f	f	f	\N	\N
55	154	13	53	2018-06-17	2018-06-21	\N	created                       	f	f	f	\N	\N
56	173	12	37	2018-01-03	2018-01-07	2018-01-08	arrived back to department    	f	f	f	\N	\N
57	254	16	73	2020-11-15	2020-11-19	2020-11-19	arrived to customer           	f	f	t	\N	\N
58	143	7	51	2019-07-05	2019-07-09	\N	being cleaned                 	f	f	f	\N	\N
59	319	15	83	2018-08-12	2018-08-19	2018-08-18	arrived to customer           	f	f	t	\N	\N
60	360	23	75	2020-07-08	2020-07-12	\N	created                       	f	f	f	\N	\N
61	120	5	75	2021-08-17	2021-08-24	\N	being cleaned                 	f	f	f	\N	\N
62	259	5	43	2018-04-19	2018-04-23	2018-04-23	arrived back to department    	f	f	f	\N	\N
63	356	14	77	2018-12-22	2018-12-26	\N	being cleaned                 	f	f	f	\N	\N
64	204	24	85	2019-04-27	2019-05-01	\N	created                       	f	f	f	\N	\N
65	349	11	55	2021-09-14	2021-09-21	2021-09-22	arrived to customer           	f	f	t	\N	\N
66	168	10	57	2021-12-02	2021-12-06	2021-12-05	arrived to customer           	f	f	t	\N	\N
67	357	21	74	2020-11-24	2020-11-28	\N	created                       	f	f	f	\N	\N
68	359	1	58	2020-10-17	2020-10-24	2020-10-23	arrived back to department    	f	f	f	\N	\N
69	185	14	69	2020-07-31	2020-08-07	2020-08-07	arrived back to department    	f	f	f	\N	\N
70	326	24	72	2019-10-09	2019-10-16	\N	being cleaned                 	f	f	f	\N	\N
71	132	11	74	2018-03-24	2018-03-28	\N	created                       	f	f	f	\N	\N
72	262	23	77	2021-05-15	2021-05-19	\N	awaiting other clothes        	f	f	f	\N	\N
73	95	11	55	2020-08-28	2020-09-01	2020-09-01	arrived to customer           	f	f	t	\N	\N
74	203	6	48	2019-10-25	2019-10-29	2019-10-29	arrived to customer           	f	f	t	\N	\N
75	310	19	53	2020-06-14	2020-06-21	\N	awaiting other clothes        	f	f	f	\N	\N
76	360	8	54	2021-08-03	2021-08-10	\N	created                       	f	f	f	\N	\N
77	167	15	64	2020-05-16	2020-05-20	\N	awaiting other clothes        	f	f	f	\N	\N
78	122	20	54	2021-07-08	2021-07-12	\N	being cleaned                 	f	f	f	\N	\N
79	229	18	57	2021-06-17	2021-06-24	\N	created                       	f	f	f	\N	\N
80	109	9	85	2018-04-14	2018-04-21	\N	awaiting other clothes        	f	f	f	\N	\N
81	310	1	76	2018-11-26	2018-11-30	\N	being cleaned                 	f	f	f	\N	\N
82	171	1	55	2019-08-30	2019-09-06	\N	created                       	f	f	f	\N	\N
83	309	15	54	2021-07-11	2021-07-18	2021-07-18	arrived back to department    	f	f	f	\N	\N
84	167	7	81	2018-11-17	2018-11-21	\N	created                       	f	f	f	\N	\N
85	129	15	56	2020-08-10	2020-08-17	\N	awaiting other clothes        	f	f	f	\N	\N
86	129	14	59	2019-04-28	2019-05-05	2019-05-04	arrived back to department    	f	f	f	\N	\N
87	277	11	41	2020-07-25	2020-08-01	2020-08-01	arrived back to department    	f	f	f	\N	\N
88	198	17	85	2020-10-15	2020-10-22	\N	awaiting other clothes        	f	f	f	\N	\N
89	350	25	38	2021-02-07	2021-02-14	2021-02-13	arrived back to department    	f	f	f	\N	\N
90	184	11	36	2020-04-14	2020-04-21	\N	awaiting other clothes        	f	f	f	\N	\N
91	154	18	38	2018-12-28	2019-01-04	\N	being cleaned                 	f	f	f	\N	\N
92	179	20	59	2019-04-06	2019-04-10	2019-04-09	arrived to customer           	f	f	t	\N	\N
93	173	22	67	2018-11-03	2018-11-07	2018-11-08	arrived back to department    	f	f	f	\N	\N
94	256	19	82	2018-07-14	2018-07-18	\N	created                       	f	f	f	\N	\N
95	370	22	46	2020-07-26	2020-07-30	\N	being cleaned                 	f	f	f	\N	\N
96	301	2	41	2021-04-22	2021-04-26	\N	created                       	f	f	f	\N	\N
97	207	4	78	2021-11-20	2021-11-24	2021-11-25	arrived to customer           	f	f	t	\N	\N
98	256	14	62	2020-11-18	2020-11-25	\N	being cleaned                 	f	f	f	\N	\N
99	201	6	49	2020-04-11	2020-04-18	2020-04-17	arrived to customer           	f	f	t	\N	\N
100	89	17	69	2018-03-26	2018-03-30	\N	being cleaned                 	f	f	f	\N	\N
101	119	25	81	2019-06-22	2019-06-29	2019-06-30	arrived back to department    	f	f	f	\N	\N
102	284	19	58	2021-10-08	2021-10-15	2021-10-15	arrived back to department    	f	f	f	\N	\N
103	363	20	38	2019-05-17	2019-05-21	\N	being cleaned                 	f	f	f	\N	\N
104	208	2	83	2018-05-20	2018-05-24	2018-05-23	arrived to customer           	f	f	t	\N	\N
105	368	10	45	2019-07-23	2019-07-30	2019-07-30	arrived to customer           	f	f	t	\N	\N
106	216	16	59	2021-12-07	2021-12-11	2021-12-11	arrived to customer           	f	f	t	\N	\N
107	113	9	81	2018-10-23	2018-10-27	\N	being cleaned                 	f	f	f	\N	\N
108	324	21	56	2018-05-06	2018-05-10	\N	being cleaned                 	f	f	f	\N	\N
109	321	21	73	2021-05-01	2021-05-05	\N	created                       	f	f	f	\N	\N
110	109	5	50	2018-04-02	2018-04-09	2018-04-08	arrived back to department    	f	f	f	\N	\N
111	114	14	81	2021-02-10	2021-02-17	\N	being cleaned                 	f	f	f	\N	\N
112	263	1	84	2019-12-21	2019-12-25	\N	being cleaned                 	f	f	f	\N	\N
113	107	8	71	2020-10-30	2020-11-06	2020-11-07	arrived back to department    	f	f	f	\N	\N
114	133	19	83	2019-03-17	2019-03-24	\N	created                       	f	f	f	\N	\N
115	367	1	66	2020-06-22	2020-06-26	\N	being cleaned                 	f	f	f	\N	\N
116	225	13	44	2019-08-14	2019-08-21	2019-08-20	arrived to customer           	f	f	t	\N	\N
117	119	22	48	2021-01-22	2021-01-26	2021-01-26	arrived back to department    	f	f	f	\N	\N
118	126	24	76	2020-04-12	2020-04-19	2020-04-18	arrived to customer           	f	f	t	\N	\N
119	244	17	50	2021-04-08	2021-04-15	\N	awaiting other clothes        	f	f	f	\N	\N
120	198	20	80	2018-04-28	2018-05-02	2018-05-03	arrived to customer           	f	f	t	\N	\N
121	253	1	72	2019-04-18	2019-04-25	\N	created                       	f	f	f	\N	\N
122	315	23	64	2019-04-02	2019-04-06	\N	created                       	f	f	f	\N	\N
123	209	1	43	2019-12-23	2019-12-30	\N	being cleaned                 	f	f	f	\N	\N
124	233	9	63	2018-08-05	2018-08-12	\N	created                       	f	f	f	\N	\N
125	333	16	37	2020-04-17	2020-04-24	\N	being cleaned                 	f	f	f	\N	\N
126	167	12	77	2018-04-06	2018-04-13	\N	awaiting other clothes        	f	f	f	\N	\N
127	315	11	59	2020-08-09	2020-08-16	2020-08-17	arrived back to department    	f	f	f	\N	\N
128	157	5	82	2020-03-01	2020-03-05	\N	being cleaned                 	f	f	f	\N	\N
129	235	20	73	2020-01-16	2020-01-23	\N	awaiting other clothes        	f	f	f	\N	\N
130	145	14	55	2021-01-27	2021-02-03	\N	created                       	f	f	f	\N	\N
131	107	7	66	2020-07-22	2020-07-29	\N	being cleaned                 	f	f	f	\N	\N
132	95	25	37	2019-04-12	2019-04-19	\N	being cleaned                 	f	f	f	\N	\N
133	384	21	75	2018-08-10	2018-08-14	2018-08-13	arrived back to department    	f	f	f	\N	\N
134	357	4	57	2021-07-28	2021-08-04	2021-08-03	arrived back to department    	f	f	f	\N	\N
135	324	12	38	2020-01-13	2020-01-20	2020-01-19	arrived back to department    	f	f	f	\N	\N
136	100	13	85	2019-07-22	2019-07-26	2019-07-27	arrived back to department    	f	f	f	\N	\N
137	306	9	44	2021-08-27	2021-08-31	2021-09-01	arrived back to department    	f	f	f	\N	\N
138	315	6	42	2021-02-19	2021-02-23	2021-02-24	arrived to customer           	f	f	t	\N	\N
139	135	5	68	2020-01-07	2020-01-14	\N	being cleaned                 	f	f	f	\N	\N
140	197	2	64	2018-09-04	2018-09-11	\N	created                       	f	f	f	\N	\N
141	289	10	69	2019-02-24	2019-03-03	2019-03-03	arrived to customer           	f	f	t	\N	\N
142	358	17	53	2019-09-02	2019-09-09	2019-09-10	arrived back to department    	f	f	f	\N	\N
143	280	14	37	2021-04-25	2021-04-29	2021-04-28	arrived to customer           	f	f	t	\N	\N
144	134	6	42	2018-08-16	2018-08-20	\N	created                       	f	f	f	\N	\N
145	116	7	36	2019-12-04	2019-12-08	\N	created                       	f	f	f	\N	\N
146	324	16	66	2020-04-21	2020-04-25	2020-04-24	arrived to customer           	f	f	t	\N	\N
147	323	22	53	2019-06-23	2019-06-30	\N	created                       	f	f	f	\N	\N
148	245	16	84	2020-07-12	2020-07-19	\N	being cleaned                 	f	f	f	\N	\N
149	291	3	57	2021-09-08	2021-09-12	\N	created                       	f	f	f	\N	\N
150	216	5	81	2020-11-02	2020-11-06	2020-11-05	arrived back to department    	f	f	f	\N	\N
151	227	6	54	2020-08-05	2020-08-12	2020-08-11	arrived back to department    	f	f	f	\N	\N
152	311	9	37	2019-08-11	2019-08-15	\N	created                       	f	f	f	\N	\N
153	145	2	56	2021-04-05	2021-04-12	\N	being cleaned                 	f	f	f	\N	\N
154	236	22	50	2020-04-04	2020-04-11	2020-04-11	arrived back to department    	f	f	f	\N	\N
155	256	10	60	2018-05-04	2018-05-11	\N	being cleaned                 	f	f	f	\N	\N
156	197	24	74	2021-01-30	2021-02-06	2021-02-05	arrived back to department    	f	f	f	\N	\N
157	267	1	57	2019-04-05	2019-04-12	\N	awaiting other clothes        	f	f	f	\N	\N
158	347	20	52	2019-09-21	2019-09-25	2019-09-24	arrived to customer           	f	f	t	\N	\N
159	315	23	40	2019-12-25	2019-12-29	\N	created                       	f	f	f	\N	\N
160	161	24	80	2021-09-11	2021-09-15	\N	being cleaned                 	f	f	f	\N	\N
161	332	5	53	2020-01-11	2020-01-15	\N	being cleaned                 	f	f	f	\N	\N
162	122	22	51	2018-09-30	2018-10-04	\N	created                       	f	f	f	\N	\N
163	215	3	72	2019-11-20	2019-11-24	\N	created                       	f	f	f	\N	\N
164	145	25	81	2018-06-25	2018-06-29	2018-06-29	arrived back to department    	f	f	f	\N	\N
165	228	24	40	2020-03-27	2020-04-03	2020-04-02	arrived to customer           	f	f	t	\N	\N
166	191	25	61	2019-01-11	2019-01-15	\N	being cleaned                 	f	f	f	\N	\N
167	191	8	66	2021-12-04	2021-12-11	2021-12-10	arrived back to department    	f	f	f	\N	\N
168	177	6	41	2019-10-07	2019-10-14	\N	being cleaned                 	f	f	f	\N	\N
169	196	16	50	2020-09-03	2020-09-10	\N	being cleaned                 	f	f	f	\N	\N
170	218	4	78	2020-04-27	2020-05-01	2020-04-30	arrived back to department    	f	f	f	\N	\N
171	379	18	85	2021-01-15	2021-01-22	\N	created                       	f	f	f	\N	\N
172	157	24	54	2021-05-18	2021-05-22	\N	awaiting other clothes        	f	f	f	\N	\N
173	380	16	79	2018-05-17	2018-05-21	\N	created                       	f	f	f	\N	\N
174	328	25	49	2018-12-30	2019-01-03	2019-01-03	arrived back to department    	f	f	f	\N	\N
175	307	11	39	2021-07-02	2021-07-06	2021-07-06	arrived to customer           	f	f	t	\N	\N
176	356	14	49	2020-01-10	2020-01-14	2020-01-13	arrived back to department    	f	f	f	\N	\N
177	188	25	61	2020-12-15	2020-12-19	2020-12-18	arrived back to department    	f	f	f	\N	\N
178	329	14	41	2021-02-02	2021-02-06	\N	created                       	f	f	f	\N	\N
179	374	12	85	2019-09-13	2019-09-20	\N	being cleaned                 	f	f	f	\N	\N
180	94	2	45	2020-02-15	2020-02-19	\N	created                       	f	f	f	\N	\N
181	252	2	51	2019-08-07	2019-08-14	\N	awaiting other clothes        	f	f	f	\N	\N
182	311	25	76	2020-08-04	2020-08-08	\N	being cleaned                 	f	f	f	\N	\N
183	145	15	38	2018-04-16	2018-04-23	\N	created                       	f	f	f	\N	\N
184	121	10	67	2019-01-18	2019-01-22	2019-01-22	arrived to customer           	f	f	t	\N	\N
185	103	4	82	2020-09-17	2020-09-21	2020-09-20	arrived back to department    	f	f	f	\N	\N
186	360	12	53	2018-10-05	2018-10-12	2018-10-12	arrived to customer           	f	f	t	\N	\N
187	285	14	71	2019-03-30	2019-04-06	2019-04-05	arrived back to department    	f	f	f	\N	\N
188	280	5	46	2020-11-21	2020-11-25	\N	awaiting other clothes        	f	f	f	\N	\N
189	154	24	76	2021-11-29	2021-12-06	\N	awaiting other clothes        	f	f	f	\N	\N
190	116	17	58	2018-04-21	2018-04-28	2018-04-28	arrived to customer           	f	f	t	\N	\N
191	118	13	70	2021-01-23	2021-01-30	2021-01-30	arrived to customer           	f	f	t	\N	\N
192	145	22	44	2019-06-07	2019-06-14	\N	being cleaned                 	f	f	f	\N	\N
193	124	7	53	2021-05-29	2021-06-02	2021-06-02	arrived back to department    	f	f	f	\N	\N
194	116	18	58	2018-09-20	2018-09-24	\N	created                       	f	f	f	\N	\N
195	164	11	52	2018-03-25	2018-03-29	2018-03-30	arrived to customer           	f	f	t	\N	\N
196	326	4	36	2018-11-13	2018-11-17	2018-11-17	arrived to customer           	f	f	t	\N	\N
197	155	15	82	2019-06-05	2019-06-09	\N	being cleaned                 	f	f	f	\N	\N
198	132	19	47	2018-05-09	2018-05-16	\N	awaiting other clothes        	f	f	f	\N	\N
199	315	23	39	2018-03-02	2018-03-06	\N	created                       	f	f	f	\N	\N
200	94	9	63	2018-06-03	2018-06-10	\N	awaiting other clothes        	f	f	f	\N	\N
201	131	25	55	2018-01-10	2018-01-14	\N	created                       	f	f	f	\N	\N
202	284	2	48	2021-03-27	2021-03-31	\N	being cleaned                 	f	f	f	\N	\N
203	223	13	83	2021-07-05	2021-07-09	2021-07-10	arrived back to department    	f	f	f	\N	\N
204	104	15	54	2019-09-20	2019-09-27	\N	awaiting other clothes        	f	f	f	\N	\N
205	259	5	62	2020-07-07	2020-07-11	2020-07-11	arrived back to department    	f	f	f	\N	\N
206	374	11	43	2021-07-01	2021-07-08	\N	created                       	f	f	f	\N	\N
207	312	25	65	2018-01-09	2018-01-13	\N	being cleaned                 	f	f	f	\N	\N
208	293	20	64	2018-06-13	2018-06-20	2018-06-21	arrived to customer           	f	f	t	\N	\N
209	259	12	54	2019-08-27	2019-09-03	2019-09-03	arrived back to department    	f	f	f	\N	\N
210	178	17	38	2020-06-28	2020-07-05	\N	awaiting other clothes        	f	f	f	\N	\N
211	233	2	74	2019-02-16	2019-02-20	\N	awaiting other clothes        	f	f	f	\N	\N
212	305	6	65	2019-01-16	2019-01-20	2019-01-21	arrived to customer           	f	f	t	\N	\N
213	182	12	53	2019-07-17	2019-07-24	\N	being cleaned                 	f	f	f	\N	\N
214	306	12	67	2018-05-03	2018-05-07	\N	created                       	f	f	f	\N	\N
215	161	1	44	2020-09-04	2020-09-11	\N	being cleaned                 	f	f	f	\N	\N
216	108	9	60	2019-01-23	2019-01-27	\N	created                       	f	f	f	\N	\N
217	147	2	37	2018-03-18	2018-03-22	2018-03-22	arrived back to department    	f	f	f	\N	\N
218	235	13	43	2020-10-02	2020-10-09	\N	created                       	f	f	f	\N	\N
219	240	4	55	2019-05-02	2019-05-06	\N	created                       	f	f	f	\N	\N
220	280	15	47	2020-09-09	2020-09-13	\N	created                       	f	f	f	\N	\N
221	265	24	67	2020-11-12	2020-11-19	2020-11-19	arrived back to department    	f	f	f	\N	\N
222	113	15	69	2019-12-18	2019-12-25	\N	being cleaned                 	f	f	f	\N	\N
223	164	14	68	2020-03-18	2020-03-22	\N	being cleaned                 	f	f	f	\N	\N
224	119	6	85	2021-02-14	2021-02-21	2021-02-20	arrived to customer           	f	f	t	\N	\N
225	265	6	58	2021-07-25	2021-08-01	\N	created                       	f	f	f	\N	\N
226	370	1	43	2021-03-10	2021-03-17	\N	awaiting other clothes        	f	f	f	\N	\N
227	166	24	58	2019-07-28	2019-08-04	\N	awaiting other clothes        	f	f	f	\N	\N
228	255	16	84	2021-09-13	2021-09-20	\N	created                       	f	f	f	\N	\N
229	133	12	78	2019-12-19	2019-12-23	\N	being cleaned                 	f	f	f	\N	\N
230	108	20	62	2021-09-24	2021-10-01	2021-09-30	arrived back to department    	f	f	f	\N	\N
231	239	16	61	2018-05-21	2018-05-25	2018-05-26	arrived to customer           	f	f	t	\N	\N
232	198	15	41	2018-10-01	2018-10-05	\N	created                       	f	f	f	\N	\N
233	241	23	83	2019-11-27	2019-12-04	\N	awaiting other clothes        	f	f	f	\N	\N
234	380	8	60	2020-10-13	2020-10-17	\N	created                       	f	f	f	\N	\N
235	98	22	40	2020-10-03	2020-10-10	\N	being cleaned                 	f	f	f	\N	\N
236	112	25	65	2020-07-16	2020-07-23	2020-07-22	arrived back to department    	f	f	f	\N	\N
237	228	14	68	2021-04-18	2021-04-25	2021-04-25	arrived back to department    	f	f	f	\N	\N
238	144	14	74	2018-09-19	2018-09-26	\N	created                       	f	f	f	\N	\N
239	101	24	62	2021-12-09	2021-12-16	\N	awaiting other clothes        	f	f	f	\N	\N
240	323	14	39	2020-09-05	2020-09-12	2020-09-11	arrived back to department    	f	f	f	\N	\N
241	222	7	47	2018-08-27	2018-08-31	\N	created                       	f	f	f	\N	\N
242	351	22	75	2018-01-18	2018-01-22	\N	created                       	f	f	f	\N	\N
243	161	6	80	2021-10-17	2021-10-21	\N	created                       	f	f	f	\N	\N
244	289	23	63	2021-10-09	2021-10-16	\N	created                       	f	f	f	\N	\N
245	269	7	38	2018-10-12	2018-10-16	\N	being cleaned                 	f	f	f	\N	\N
246	163	21	69	2018-07-02	2018-07-09	\N	awaiting other clothes        	f	f	f	\N	\N
247	292	15	59	2020-09-27	2020-10-04	\N	created                       	f	f	f	\N	\N
248	179	4	66	2020-04-25	2020-05-02	\N	being cleaned                 	f	f	f	\N	\N
249	100	3	48	2020-04-15	2020-04-19	\N	awaiting other clothes        	f	f	f	\N	\N
250	157	19	72	2019-06-17	2019-06-21	\N	being cleaned                 	f	f	f	\N	\N
251	160	18	82	2020-06-03	2020-06-10	2020-06-10	arrived to customer           	f	f	t	\N	\N
252	221	6	42	2020-10-29	2020-11-02	\N	being cleaned                 	f	f	f	\N	\N
253	104	3	69	2019-01-14	2019-01-21	2019-01-20	arrived to customer           	f	f	t	\N	\N
254	269	22	71	2021-03-24	2021-03-28	\N	awaiting other clothes        	f	f	f	\N	\N
255	241	12	42	2019-08-19	2019-08-23	\N	awaiting other clothes        	f	f	f	\N	\N
256	178	4	75	2021-04-01	2021-04-05	\N	created                       	f	f	f	\N	\N
257	96	25	67	2021-02-23	2021-02-27	2021-02-26	arrived to customer           	f	f	t	\N	\N
258	228	13	60	2018-12-21	2018-12-25	2018-12-26	arrived back to department    	f	f	f	\N	\N
259	357	18	43	2021-12-17	2021-12-24	\N	being cleaned                 	f	f	f	\N	\N
260	299	18	75	2019-05-07	2019-05-14	\N	awaiting other clothes        	f	f	f	\N	\N
261	385	11	52	2021-09-23	2021-09-27	\N	being cleaned                 	f	f	f	\N	\N
262	198	3	74	2019-07-31	2019-08-07	2019-08-08	arrived back to department    	f	f	f	\N	\N
263	217	22	45	2018-10-19	2018-10-23	\N	awaiting other clothes        	f	f	f	\N	\N
264	110	25	79	2019-11-08	2019-11-15	2019-11-14	arrived back to department    	f	f	f	\N	\N
265	109	12	65	2018-11-08	2018-11-12	2018-11-11	arrived to customer           	f	f	t	\N	\N
266	278	22	56	2020-12-28	2021-01-01	\N	being cleaned                 	f	f	f	\N	\N
267	209	25	51	2020-08-06	2020-08-10	\N	awaiting other clothes        	f	f	f	\N	\N
268	184	6	53	2019-11-06	2019-11-13	2019-11-13	arrived back to department    	f	f	f	\N	\N
269	101	14	52	2021-04-10	2021-04-14	2021-04-14	arrived back to department    	f	f	f	\N	\N
270	318	17	54	2018-09-21	2018-09-28	\N	awaiting other clothes        	f	f	f	\N	\N
271	153	3	61	2020-12-22	2020-12-26	2020-12-25	arrived to customer           	f	f	t	\N	\N
272	275	22	73	2021-03-11	2021-03-15	2021-03-16	arrived back to department    	f	f	f	\N	\N
273	87	4	70	2020-02-10	2020-02-17	\N	created                       	f	f	f	\N	\N
274	329	8	37	2019-11-26	2019-12-03	2019-12-02	arrived back to department    	f	f	f	\N	\N
275	226	22	49	2021-04-24	2021-04-28	\N	being cleaned                 	f	f	f	\N	\N
276	135	22	72	2020-06-27	2020-07-04	\N	created                       	f	f	f	\N	\N
277	347	6	46	2020-06-29	2020-07-06	\N	being cleaned                 	f	f	f	\N	\N
278	161	21	76	2019-02-01	2019-02-08	2019-02-08	arrived back to department    	f	f	f	\N	\N
279	195	19	62	2020-06-01	2020-06-05	\N	created                       	f	f	f	\N	\N
280	286	21	79	2021-01-06	2021-01-10	\N	being cleaned                 	f	f	f	\N	\N
281	362	24	85	2019-07-21	2019-07-25	\N	being cleaned                 	f	f	f	\N	\N
282	312	2	82	2018-06-18	2018-06-22	\N	being cleaned                 	f	f	f	\N	\N
283	139	19	64	2019-11-04	2019-11-08	2019-11-08	arrived to customer           	f	f	t	\N	\N
284	156	23	44	2021-08-10	2021-08-17	\N	awaiting other clothes        	f	f	f	\N	\N
285	225	9	48	2019-12-16	2019-12-20	\N	being cleaned                 	f	f	f	\N	\N
286	336	23	50	2018-12-09	2018-12-13	2018-12-13	arrived back to department    	f	f	f	\N	\N
287	256	16	51	2020-12-09	2020-12-13	2020-12-13	arrived to customer           	f	f	t	\N	\N
288	357	21	60	2019-07-12	2019-07-16	\N	created                       	f	f	f	\N	\N
289	104	23	75	2019-12-26	2020-01-02	\N	awaiting other clothes        	f	f	f	\N	\N
290	111	5	51	2021-10-15	2021-10-22	2021-10-22	arrived to customer           	f	f	t	\N	\N
291	101	9	83	2019-03-03	2019-03-10	\N	being cleaned                 	f	f	f	\N	\N
292	245	8	75	2018-01-29	2018-02-05	2018-02-04	arrived back to department    	f	f	f	\N	\N
293	279	19	50	2021-06-04	2021-06-08	2021-06-08	arrived to customer           	f	f	t	\N	\N
294	190	25	43	2019-01-26	2019-01-30	\N	being cleaned                 	f	f	f	\N	\N
295	130	5	50	2020-03-22	2020-03-29	\N	awaiting other clothes        	f	f	f	\N	\N
296	232	10	53	2020-02-14	2020-02-21	\N	being cleaned                 	f	f	f	\N	\N
297	254	8	52	2021-07-22	2021-07-29	\N	awaiting other clothes        	f	f	f	\N	\N
298	115	23	52	2018-07-09	2018-07-13	\N	awaiting other clothes        	f	f	f	\N	\N
299	134	25	43	2018-11-14	2018-11-21	2018-11-20	arrived to customer           	f	f	t	\N	\N
300	363	21	68	2020-05-08	2020-05-15	2020-05-16	arrived back to department    	f	f	f	\N	\N
301	189	24	82	2020-04-19	2020-04-26	\N	awaiting other clothes        	f	f	f	\N	\N
302	116	18	55	2020-06-11	2020-06-15	2020-06-14	arrived back to department    	f	f	f	\N	\N
303	340	20	42	2020-01-14	2020-01-18	2020-01-19	arrived back to department    	f	f	f	\N	\N
304	233	15	66	2018-04-03	2018-04-10	\N	awaiting other clothes        	f	f	f	\N	\N
305	198	12	76	2021-09-17	2021-09-21	\N	awaiting other clothes        	f	f	f	\N	\N
306	124	4	53	2018-01-05	2018-01-12	\N	awaiting other clothes        	f	f	f	\N	\N
307	219	15	36	2018-12-01	2018-12-05	2018-12-05	arrived to customer           	f	f	t	\N	\N
308	249	12	37	2019-10-21	2019-10-25	2019-10-24	arrived back to department    	f	f	f	\N	\N
309	308	1	44	2018-08-20	2018-08-27	2018-08-27	arrived back to department    	f	f	f	\N	\N
310	222	7	85	2018-07-06	2018-07-10	\N	being cleaned                 	f	f	f	\N	\N
311	230	14	38	2018-08-26	2018-09-02	2018-09-02	arrived back to department    	f	f	f	\N	\N
312	187	3	61	2020-12-13	2020-12-20	2020-12-21	arrived to customer           	f	f	t	\N	\N
313	266	22	53	2021-01-07	2021-01-14	2021-01-14	arrived to customer           	f	f	t	\N	\N
314	324	20	54	2021-12-15	2021-12-22	2021-12-21	arrived to customer           	f	f	t	\N	\N
315	301	24	46	2020-08-22	2020-08-26	\N	awaiting other clothes        	f	f	f	\N	\N
316	300	24	75	2020-03-13	2020-03-20	2020-03-20	arrived to customer           	f	f	t	\N	\N
317	166	22	38	2020-03-14	2020-03-21	2020-03-22	arrived back to department    	f	f	f	\N	\N
318	161	20	83	2018-06-21	2018-06-25	\N	awaiting other clothes        	f	f	f	\N	\N
319	353	22	49	2021-04-06	2021-04-10	\N	created                       	f	f	f	\N	\N
320	203	22	61	2019-06-12	2019-06-16	2019-06-16	arrived back to department    	f	f	f	\N	\N
321	87	13	39	2018-02-04	2018-02-11	\N	created                       	f	f	f	\N	\N
322	285	22	57	2018-08-08	2018-08-15	\N	awaiting other clothes        	f	f	f	\N	\N
323	312	17	73	2018-04-20	2018-04-27	\N	created                       	f	f	f	\N	\N
324	246	13	81	2020-12-14	2020-12-21	2020-12-22	arrived back to department    	f	f	f	\N	\N
325	209	16	57	2021-05-30	2021-06-03	\N	created                       	f	f	f	\N	\N
326	380	16	46	2020-01-31	2020-02-07	2020-02-06	arrived back to department    	f	f	f	\N	\N
327	244	14	50	2018-11-12	2018-11-16	\N	created                       	f	f	f	\N	\N
328	143	8	71	2021-06-26	2021-06-30	2021-06-29	arrived to customer           	f	f	t	\N	\N
329	345	17	60	2018-12-04	2018-12-11	2018-12-10	arrived back to department    	f	f	f	\N	\N
330	125	8	57	2021-10-24	2021-10-31	2021-10-30	arrived to customer           	f	f	t	\N	\N
331	343	23	49	2020-12-16	2020-12-23	\N	awaiting other clothes        	f	f	f	\N	\N
332	348	1	63	2018-04-23	2018-04-30	\N	awaiting other clothes        	f	f	f	\N	\N
333	318	18	75	2021-02-12	2021-02-19	\N	created                       	f	f	f	\N	\N
334	115	14	84	2019-07-30	2019-08-06	\N	created                       	f	f	f	\N	\N
335	366	21	47	2021-08-19	2021-08-23	2021-08-24	arrived back to department    	f	f	f	\N	\N
336	144	7	52	2019-04-23	2019-04-27	\N	created                       	f	f	f	\N	\N
337	131	4	73	2018-05-28	2018-06-04	2018-06-04	arrived back to department    	f	f	f	\N	\N
338	270	7	82	2020-07-04	2020-07-11	\N	awaiting other clothes        	f	f	f	\N	\N
339	139	11	61	2020-08-25	2020-08-29	\N	being cleaned                 	f	f	f	\N	\N
340	99	23	47	2020-10-06	2020-10-13	2020-10-13	arrived to customer           	f	f	t	\N	\N
341	359	7	48	2020-01-21	2020-01-25	2020-01-24	arrived to customer           	f	f	t	\N	\N
342	163	18	49	2021-01-04	2021-01-11	2021-01-11	arrived to customer           	f	f	t	\N	\N
343	348	17	83	2018-02-25	2018-03-04	2018-03-04	arrived to customer           	f	f	t	\N	\N
344	135	2	43	2021-04-20	2021-04-24	\N	being cleaned                 	f	f	f	\N	\N
345	139	9	75	2018-09-15	2018-09-22	\N	being cleaned                 	f	f	f	\N	\N
346	205	19	59	2018-01-02	2018-01-09	2018-01-09	arrived to customer           	f	f	t	\N	\N
347	261	8	42	2020-03-21	2020-03-25	\N	being cleaned                 	f	f	f	\N	\N
348	353	24	39	2018-04-25	2018-05-02	2018-05-01	arrived to customer           	f	f	t	\N	\N
349	329	5	83	2019-09-09	2019-09-13	\N	created                       	f	f	f	\N	\N
350	364	22	55	2019-09-01	2019-09-05	\N	being cleaned                 	f	f	f	\N	\N
351	172	5	40	2018-06-11	2018-06-18	\N	created                       	f	f	f	\N	\N
352	178	4	82	2020-08-01	2020-08-08	2020-08-08	arrived back to department    	f	f	f	\N	\N
353	95	2	80	2020-10-28	2020-11-01	\N	awaiting other clothes        	f	f	f	\N	\N
354	145	2	53	2020-04-03	2020-04-07	\N	created                       	f	f	f	\N	\N
355	154	8	47	2018-01-13	2018-01-17	\N	created                       	f	f	f	\N	\N
356	125	5	84	2021-05-31	2021-06-07	\N	created                       	f	f	f	\N	\N
357	153	8	82	2018-04-24	2018-05-01	\N	being cleaned                 	f	f	f	\N	\N
358	183	2	46	2020-03-25	2020-03-29	\N	created                       	f	f	f	\N	\N
359	110	1	63	2020-07-05	2020-07-12	\N	created                       	f	f	f	\N	\N
360	348	14	57	2021-09-26	2021-09-30	\N	created                       	f	f	f	\N	\N
361	318	9	39	2019-08-15	2019-08-22	\N	created                       	f	f	f	\N	\N
362	240	18	44	2019-11-18	2019-11-22	\N	being cleaned                 	f	f	f	\N	\N
363	94	6	71	2019-03-19	2019-03-23	\N	awaiting other clothes        	f	f	f	\N	\N
364	172	5	41	2020-09-18	2020-09-22	\N	awaiting other clothes        	f	f	f	\N	\N
365	304	4	56	2019-06-09	2019-06-13	2019-06-12	arrived back to department    	f	f	f	\N	\N
366	277	3	78	2019-11-02	2019-11-09	\N	being cleaned                 	f	f	f	\N	\N
367	383	20	40	2019-11-05	2019-11-12	\N	created                       	f	f	f	\N	\N
368	310	23	78	2018-07-21	2018-07-28	\N	being cleaned                 	f	f	f	\N	\N
369	154	9	75	2021-06-23	2021-06-30	\N	being cleaned                 	f	f	f	\N	\N
370	326	4	82	2021-11-13	2021-11-20	2021-11-19	arrived to customer           	f	f	t	\N	\N
371	214	9	75	2019-01-08	2019-01-15	\N	awaiting other clothes        	f	f	f	\N	\N
372	219	15	44	2021-10-27	2021-11-03	\N	awaiting other clothes        	f	f	f	\N	\N
373	299	18	85	2021-08-07	2021-08-11	\N	created                       	f	f	f	\N	\N
374	368	25	50	2018-03-05	2018-03-12	2018-03-11	arrived back to department    	f	f	f	\N	\N
375	309	14	79	2020-03-02	2020-03-09	\N	created                       	f	f	f	\N	\N
376	172	23	46	2021-04-23	2021-04-30	2021-04-29	arrived to customer           	f	f	t	\N	\N
377	219	17	67	2019-09-30	2019-10-04	\N	created                       	f	f	f	\N	\N
378	240	13	54	2021-02-26	2021-03-02	\N	being cleaned                 	f	f	f	\N	\N
379	195	25	57	2019-08-18	2019-08-22	\N	created                       	f	f	f	\N	\N
380	190	5	82	2018-01-17	2018-01-21	2018-01-21	arrived back to department    	f	f	f	\N	\N
381	232	21	61	2021-01-13	2021-01-20	2021-01-19	arrived back to department    	f	f	f	\N	\N
382	314	7	64	2021-02-25	2021-03-01	\N	awaiting other clothes        	f	f	f	\N	\N
383	191	3	73	2020-11-07	2020-11-11	\N	being cleaned                 	f	f	f	\N	\N
384	214	5	85	2019-02-03	2019-02-10	\N	awaiting other clothes        	f	f	f	\N	\N
385	348	20	76	2018-09-29	2018-10-06	\N	created                       	f	f	f	\N	\N
386	136	13	52	2018-09-22	2018-09-26	\N	being cleaned                 	f	f	f	\N	\N
387	218	23	61	2018-03-15	2018-03-19	\N	being cleaned                 	f	f	f	\N	\N
388	318	13	81	2019-10-29	2019-11-02	\N	awaiting other clothes        	f	f	f	\N	\N
389	152	3	54	2018-09-27	2018-10-01	\N	created                       	f	f	f	\N	\N
390	257	22	84	2019-11-24	2019-11-28	\N	created                       	f	f	f	\N	\N
391	237	17	76	2020-02-11	2020-02-18	2020-02-18	arrived back to department    	f	f	f	\N	\N
392	312	1	77	2019-10-26	2019-10-30	2019-10-29	arrived back to department    	f	f	f	\N	\N
393	108	25	72	2020-06-30	2020-07-04	2020-07-03	arrived to customer           	f	f	t	\N	\N
394	273	5	67	2020-11-27	2020-12-04	\N	awaiting other clothes        	f	f	f	\N	\N
395	111	6	59	2019-11-15	2019-11-22	2019-11-21	arrived back to department    	f	f	f	\N	\N
396	214	21	76	2020-08-18	2020-08-22	\N	created                       	f	f	f	\N	\N
397	161	24	58	2021-08-31	2021-09-07	2021-09-06	arrived back to department    	f	f	f	\N	\N
398	157	19	66	2020-09-11	2020-09-15	\N	created                       	f	f	f	\N	\N
399	206	17	60	2020-02-01	2020-02-05	\N	being cleaned                 	f	f	f	\N	\N
400	270	25	37	2021-12-06	2021-12-10	2021-12-10	arrived to customer           	f	f	t	\N	\N
\.


--
-- Data for Name: people; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.people (id, name, phone_number, email) FROM stdin;
\.


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.shipments (id, department_id, sorting_department_id, cleaning_department_id, truck_id, type, is_on_route) FROM stdin;
1	\N	27	\N	\N	department_to_sorting_department                                                                    	f
2	\N	26	\N	\N	sorting_department_to_cleaning_department                                                           	f
3	\N	28	\N	\N	sorting_department_to_cleaning_department                                                           	f
4	\N	27	\N	\N	cleaning_department_to_sorting_department                                                           	f
5	\N	30	\N	\N	cleaning_department_to_sorting_department                                                           	f
6	\N	26	\N	\N	cleaning_department_to_sorting_department                                                           	f
7	\N	28	\N	\N	cleaning_department_to_sorting_department                                                           	f
8	\N	28	\N	\N	cleaning_department_to_sorting_department                                                           	f
9	\N	29	\N	18	cleaning_department_to_sorting_department                                                           	f
10	\N	28	\N	6	department_to_sorting_department                                                                    	f
11	\N	27	\N	\N	department_to_sorting_department                                                                    	f
12	\N	26	\N	\N	sorting_department_to_customer                                                                      	f
13	\N	26	\N	\N	sorting_department_to_cleaning_department                                                           	f
14	\N	30	\N	\N	sorting_department_to_department                                                                    	f
15	\N	26	\N	\N	sorting_department_to_cleaning_department                                                           	f
16	\N	26	\N	\N	cleaning_department_to_sorting_department                                                           	f
17	\N	26	\N	\N	sorting_department_to_cleaning_department                                                           	f
18	\N	29	\N	17	sorting_department_to_cleaning_department                                                           	f
19	\N	30	\N	\N	sorting_department_to_department                                                                    	f
20	\N	30	\N	\N	sorting_department_to_department                                                                    	f
21	\N	26	\N	\N	sorting_department_to_cleaning_department                                                           	f
22	\N	28	\N	\N	sorting_department_to_cleaning_department                                                           	f
23	\N	30	\N	\N	department_to_sorting_department                                                                    	f
24	\N	29	\N	\N	department_to_sorting_department                                                                    	f
25	\N	29	\N	\N	department_to_sorting_department                                                                    	f
26	\N	29	\N	5	department_to_sorting_department                                                                    	f
27	\N	29	\N	\N	cleaning_department_to_sorting_department                                                           	f
28	\N	28	\N	\N	cleaning_department_to_sorting_department                                                           	f
29	\N	27	\N	\N	department_to_sorting_department                                                                    	f
30	\N	27	\N	\N	sorting_department_to_department                                                                    	f
31	\N	29	\N	15	cleaning_department_to_sorting_department                                                           	f
32	\N	29	\N	\N	sorting_department_to_department                                                                    	f
33	\N	27	\N	\N	sorting_department_to_cleaning_department                                                           	f
34	\N	29	\N	\N	department_to_sorting_department                                                                    	f
35	\N	29	\N	\N	sorting_department_to_department                                                                    	f
36	\N	28	\N	\N	sorting_department_to_department                                                                    	f
37	\N	29	\N	\N	cleaning_department_to_sorting_department                                                           	f
38	\N	30	\N	\N	sorting_department_to_customer                                                                      	f
39	\N	26	\N	\N	sorting_department_to_customer                                                                      	f
40	\N	30	\N	\N	sorting_department_to_department                                                                    	f
41	\N	27	\N	4	cleaning_department_to_sorting_department                                                           	f
42	\N	26	\N	\N	department_to_sorting_department                                                                    	f
43	\N	27	\N	\N	cleaning_department_to_sorting_department                                                           	f
44	\N	27	\N	\N	department_to_sorting_department                                                                    	f
45	\N	27	\N	\N	department_to_sorting_department                                                                    	f
46	\N	27	\N	\N	sorting_department_to_department                                                                    	f
47	\N	28	\N	1	cleaning_department_to_sorting_department                                                           	f
48	\N	30	\N	\N	department_to_sorting_department                                                                    	f
49	\N	28	\N	\N	cleaning_department_to_sorting_department                                                           	f
50	\N	27	\N	\N	cleaning_department_to_sorting_department                                                           	f
\.


--
-- Data for Name: sorting_departments; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.sorting_departments (id, address, phone_number, requires_shipment) FROM stdin;
26	г. Москва, пер. Российский, стр. 4, 014638                                                          	+7 (991) 635-0143   	f
27	г. Москва, пер. Горный, стр. 367, 227113                                                            	+7 (542) 889-3471   	f
28	г. Москва, пер. Циолковского, стр. 4, 703333                                                        	+7 (836) 620-4113   	f
29	г. Москва, пер. Кольцова, стр. 55, 040836                                                           	8 (849) 656-5762    	f
30	г. Москва, ул. Флотская, стр. 89, 360366                                                            	+7 517 885 9400     	f
\.


--
-- Data for Name: trucks; Type: TABLE DATA; Schema: dryclean; Owner: any_user
--

COPY dryclean.trucks (id, courier_id, label, is_in_working_condition) FROM stdin;
1	\N	\N	t
2	\N	\N	t
3	\N	\N	t
4	\N	\N	t
5	\N	\N	t
6	\N	\N	t
7	\N	\N	t
8	\N	\N	t
9	\N	\N	t
10	\N	\N	t
11	\N	\N	t
12	\N	\N	t
13	\N	\N	t
14	\N	\N	t
15	\N	\N	t
16	\N	\N	t
17	\N	\N	t
18	\N	\N	t
19	\N	\N	t
20	\N	\N	t
\.


--
-- Name: buildings_id_seq; Type: SEQUENCE SET; Schema: dryclean; Owner: any_user
--

SELECT pg_catalog.setval('dryclean.buildings_id_seq', 40, true);


--
-- Name: clothing_id_seq; Type: SEQUENCE SET; Schema: dryclean; Owner: any_user
--

SELECT pg_catalog.setval('dryclean.clothing_id_seq', 700, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: dryclean; Owner: any_user
--

SELECT pg_catalog.setval('dryclean.orders_id_seq', 400, true);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: dryclean; Owner: any_user
--

SELECT pg_catalog.setval('dryclean.person_id_seq', 385, true);


--
-- Name: shipments_id_seq; Type: SEQUENCE SET; Schema: dryclean; Owner: any_user
--

SELECT pg_catalog.setval('dryclean.shipments_id_seq', 50, true);


--
-- Name: trucks_id_seq; Type: SEQUENCE SET; Schema: dryclean; Owner: any_user
--

SELECT pg_catalog.setval('dryclean.trucks_id_seq', 20, true);


--
-- Name: buildings address and phone number pair must be unique; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.buildings
    ADD CONSTRAINT "address and phone number pair must be unique" UNIQUE (address, phone_number);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: cleaning_departments cleaning_departments_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.cleaning_departments
    ADD CONSTRAINT cleaning_departments_pkey PRIMARY KEY (id);


--
-- Name: clothing clothing_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.clothing
    ADD CONSTRAINT clothing_pkey PRIMARY KEY (id);


--
-- Name: couriers courier phone number must be unique; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.couriers
    ADD CONSTRAINT "courier phone number must be unique" UNIQUE (phone_number);


--
-- Name: couriers couriers_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.couriers
    ADD CONSTRAINT couriers_pkey PRIMARY KEY (id);


--
-- Name: couriers customer email must be unique; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.couriers
    ADD CONSTRAINT "customer email must be unique" UNIQUE (email);


--
-- Name: customers customer email nmust be unique; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.customers
    ADD CONSTRAINT "customer email nmust be unique" UNIQUE (email);


--
-- Name: customers customer phone number must be unique; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.customers
    ADD CONSTRAINT "customer phone number must be unique" UNIQUE (phone_number);


--
-- Name: customers customers_address_key; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.customers
    ADD CONSTRAINT customers_address_key UNIQUE (address);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: managers manager email must be unique; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.managers
    ADD CONSTRAINT "manager email must be unique" UNIQUE (email);


--
-- Name: managers manager phone number must be unique; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.managers
    ADD CONSTRAINT "manager phone number must be unique" UNIQUE (phone_number);


--
-- Name: managers managers_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.managers
    ADD CONSTRAINT managers_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: people people_email_key; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.people
    ADD CONSTRAINT people_email_key UNIQUE (email);


--
-- Name: people people_phone_number_key; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.people
    ADD CONSTRAINT people_phone_number_key UNIQUE (phone_number);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_truck_id_key; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.shipments
    ADD CONSTRAINT shipments_truck_id_key UNIQUE (truck_id);


--
-- Name: sorting_departments sorting_departments_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.sorting_departments
    ADD CONSTRAINT sorting_departments_pkey PRIMARY KEY (id);


--
-- Name: trucks trucks_courier_id_key; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.trucks
    ADD CONSTRAINT trucks_courier_id_key UNIQUE (courier_id);


--
-- Name: trucks trucks_pkey; Type: CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.trucks
    ADD CONSTRAINT trucks_pkey PRIMARY KEY (id);


--
-- Name: clothing clothing_order_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.clothing
    ADD CONSTRAINT clothing_order_id_fkey FOREIGN KEY (order_id) REFERENCES dryclean.orders(id) ON DELETE CASCADE;


--
-- Name: clothing clothing_shipment_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.clothing
    ADD CONSTRAINT clothing_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES dryclean.shipments(id) ON UPDATE SET NULL;


--
-- Name: managers managers_department_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.managers
    ADD CONSTRAINT managers_department_id_fkey FOREIGN KEY (department_id) REFERENCES dryclean.departments(id) ON DELETE RESTRICT;


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES dryclean.customers(id) ON DELETE CASCADE;


--
-- Name: orders orders_department_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.orders
    ADD CONSTRAINT orders_department_id_fkey FOREIGN KEY (department_id) REFERENCES dryclean.departments(id) ON DELETE SET NULL;


--
-- Name: orders orders_manager_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.orders
    ADD CONSTRAINT orders_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES dryclean.managers(id) ON DELETE SET NULL;


--
-- Name: shipments shipments_cleaning_department_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.shipments
    ADD CONSTRAINT shipments_cleaning_department_id_fkey FOREIGN KEY (cleaning_department_id) REFERENCES dryclean.cleaning_departments(id) ON DELETE RESTRICT;


--
-- Name: shipments shipments_department_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.shipments
    ADD CONSTRAINT shipments_department_id_fkey FOREIGN KEY (department_id) REFERENCES dryclean.departments(id) ON DELETE RESTRICT;


--
-- Name: shipments shipments_sorting_department_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.shipments
    ADD CONSTRAINT shipments_sorting_department_id_fkey FOREIGN KEY (sorting_department_id) REFERENCES dryclean.sorting_departments(id) ON DELETE RESTRICT;


--
-- Name: shipments shipments_truck_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.shipments
    ADD CONSTRAINT shipments_truck_id_fkey FOREIGN KEY (truck_id) REFERENCES dryclean.trucks(id) ON DELETE RESTRICT;


--
-- Name: trucks trucks_courier_id_fkey; Type: FK CONSTRAINT; Schema: dryclean; Owner: any_user
--

ALTER TABLE ONLY dryclean.trucks
    ADD CONSTRAINT trucks_courier_id_fkey FOREIGN KEY (courier_id) REFERENCES dryclean.couriers(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

