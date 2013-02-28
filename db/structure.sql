--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: sum_text(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sum_text(text, text) RETURNS text
    LANGUAGE sql
    AS $_$
select $1 || ' ' ||$2
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE active_admin_comments (
    id integer NOT NULL,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    namespace character varying(255)
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE active_admin_comments_id_seq OWNED BY active_admin_comments.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255),
    role character varying(255)
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bookings (
    id integer NOT NULL,
    meetup_id integer,
    lesson_id integer,
    chalkler_id integer,
    status character varying(255),
    guests integer,
    paid boolean,
    meetup_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    visible boolean,
    cost_override numeric(8,2) DEFAULT NULL::numeric
);


--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bookings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bookings_id_seq OWNED BY bookings.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: chalklers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE chalklers (
    id integer NOT NULL,
    name character varying(255),
    email character varying(255),
    meetup_id integer,
    bio text,
    meetup_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    failed_attempts integer DEFAULT 0,
    unlock_token character varying(255),
    locked_at timestamp without time zone,
    gst character varying(255),
    provider character varying(255),
    uid character varying(255),
    email_frequency character varying(255),
    email_categories text,
    email_streams text
);


--
-- Name: chalklers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE chalklers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chalklers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE chalklers_id_seq OWNED BY chalklers.id;


--
-- Name: channel_admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_admins (
    channel_id integer NOT NULL,
    admin_user_id integer NOT NULL
);


--
-- Name: channel_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_categories (
    channel_id integer NOT NULL,
    category_id integer NOT NULL
);


--
-- Name: channel_chalklers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_chalklers (
    channel_id integer NOT NULL,
    chalkler_id integer NOT NULL
);


--
-- Name: channel_lessons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channel_lessons (
    channel_id integer NOT NULL,
    lesson_id integer NOT NULL
);


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE channels (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    url_name character varying(255),
    teacher_percentage numeric(8,2) DEFAULT 0.75,
    channel_percentage numeric(8,2) DEFAULT 0.125
);


--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE channels_id_seq OWNED BY channels.id;


--
-- Name: lesson_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lesson_categories (
    lesson_id integer NOT NULL,
    category_id integer NOT NULL
);


--
-- Name: lesson_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lesson_images (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    lesson_id integer,
    image_uid character varying(255),
    image_name character varying(255)
);


--
-- Name: lesson_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lesson_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lesson_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lesson_images_id_seq OWNED BY lesson_images.id;


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lessons (
    id integer NOT NULL,
    teacher_id integer,
    meetup_id integer,
    name character varying(255),
    status character varying(255) DEFAULT 'Unreviewed'::character varying,
    description text,
    cost numeric(8,2) DEFAULT NULL::numeric,
    start_at timestamp without time zone,
    duration integer,
    meetup_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    teacher_cost numeric(8,2) DEFAULT NULL::numeric,
    venue_cost numeric(8,2),
    visible boolean,
    teacher_payment numeric(8,2) DEFAULT NULL::numeric,
    lesson_type character varying(255) DEFAULT NULL::character varying,
    teacher_bio text,
    do_during_class text,
    learning_outcomes text,
    max_attendee integer,
    min_attendee integer DEFAULT 2,
    availabilities text,
    prerequisites text,
    additional_comments text,
    donation boolean DEFAULT false,
    lesson_skill character varying(255) DEFAULT NULL::character varying,
    venue text,
    published_at timestamp without time zone,
    channel_percentage_override numeric(8,2) DEFAULT NULL::numeric
);


--
-- Name: lessons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lessons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lessons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lessons_id_seq OWNED BY lessons.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE payments (
    id integer NOT NULL,
    booking_id integer,
    xero_id character varying(255),
    xero_contact_id character varying(255),
    xero_contact_name character varying(255),
    date date,
    complete_record_downloaded boolean,
    total numeric(8,2) DEFAULT 0,
    reconciled boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reference character varying(255),
    visible boolean,
    cash_payment boolean
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE payments_id_seq OWNED BY payments.id;


--
-- Name: rails_admin_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rails_admin_histories (
    id integer NOT NULL,
    message text,
    username character varying(255),
    item integer,
    "table" character varying(255),
    month smallint,
    year bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rails_admin_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rails_admin_histories_id_seq OWNED BY rails_admin_histories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: streams; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE streams (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: streams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE streams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: streams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE streams_id_seq OWNED BY streams.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY active_admin_comments ALTER COLUMN id SET DEFAULT nextval('active_admin_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bookings ALTER COLUMN id SET DEFAULT nextval('bookings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY chalklers ALTER COLUMN id SET DEFAULT nextval('chalklers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY channels ALTER COLUMN id SET DEFAULT nextval('channels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lesson_images ALTER COLUMN id SET DEFAULT nextval('lesson_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lessons ALTER COLUMN id SET DEFAULT nextval('lessons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY payments ALTER COLUMN id SET DEFAULT nextval('payments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rails_admin_histories ALTER COLUMN id SET DEFAULT nextval('rails_admin_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY streams ALTER COLUMN id SET DEFAULT nextval('streams_id_seq'::regclass);


--
-- Name: admin_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY active_admin_comments
    ADD CONSTRAINT admin_notes_pkey PRIMARY KEY (id);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: chalklers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY chalklers
    ADD CONSTRAINT chalklers_pkey PRIMARY KEY (id);


--
-- Name: channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY streams
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY channels
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: lesson_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lesson_images
    ADD CONSTRAINT lesson_images_pkey PRIMARY KEY (id);


--
-- Name: lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: rails_admin_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rails_admin_histories
    ADD CONSTRAINT rails_admin_histories_pkey PRIMARY KEY (id);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_active_admin_comments_on_namespace ON active_admin_comments USING btree (namespace);


--
-- Name: index_admin_notes_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_admin_notes_on_resource_type_and_resource_id ON active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_channel_admins_on_channel_id_and_admin_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channel_admins_on_channel_id_and_admin_user_id ON channel_admins USING btree (channel_id, admin_user_id);


--
-- Name: index_channel_categories_on_channel_id_and_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channel_categories_on_channel_id_and_category_id ON channel_categories USING btree (channel_id, category_id);


--
-- Name: index_channel_chalklers_on_channel_id_and_chalkler_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channel_chalklers_on_channel_id_and_chalkler_id ON channel_chalklers USING btree (channel_id, chalkler_id);


--
-- Name: index_channel_lessons_on_channel_id_and_lesson_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_channel_lessons_on_channel_id_and_lesson_id ON channel_lessons USING btree (channel_id, lesson_id);


--
-- Name: index_lesson_categories_on_lesson_id_and_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_lesson_categories_on_lesson_id_and_category_id ON lesson_categories USING btree (lesson_id, category_id);


--
-- Name: index_rails_admin_histories; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rails_admin_histories ON rails_admin_histories USING btree (item, "table", month, year);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120807131310');

INSERT INTO schema_migrations (version) VALUES ('20120904112450');

INSERT INTO schema_migrations (version) VALUES ('20120904115357');

INSERT INTO schema_migrations (version) VALUES ('20120904120324');

INSERT INTO schema_migrations (version) VALUES ('20120926135411');

INSERT INTO schema_migrations (version) VALUES ('20120926135412');

INSERT INTO schema_migrations (version) VALUES ('20120926135413');

INSERT INTO schema_migrations (version) VALUES ('20120930100426');

INSERT INTO schema_migrations (version) VALUES ('20120930121519');

INSERT INTO schema_migrations (version) VALUES ('20121003103831');

INSERT INTO schema_migrations (version) VALUES ('20121019214140');

INSERT INTO schema_migrations (version) VALUES ('20121019231336');

INSERT INTO schema_migrations (version) VALUES ('20121020010911');

INSERT INTO schema_migrations (version) VALUES ('20121020035207');

INSERT INTO schema_migrations (version) VALUES ('20121023093912');

INSERT INTO schema_migrations (version) VALUES ('20121024034355');

INSERT INTO schema_migrations (version) VALUES ('20121024085045');

INSERT INTO schema_migrations (version) VALUES ('20121030020705');

INSERT INTO schema_migrations (version) VALUES ('20121030030947');

INSERT INTO schema_migrations (version) VALUES ('20121030092925');

INSERT INTO schema_migrations (version) VALUES ('20121031011223');

INSERT INTO schema_migrations (version) VALUES ('20121031230054');

INSERT INTO schema_migrations (version) VALUES ('20121101001605');

INSERT INTO schema_migrations (version) VALUES ('20121106035831');

INSERT INTO schema_migrations (version) VALUES ('20121120030116');

INSERT INTO schema_migrations (version) VALUES ('20121203084600');

INSERT INTO schema_migrations (version) VALUES ('20121209182836');

INSERT INTO schema_migrations (version) VALUES ('20121215065642');

INSERT INTO schema_migrations (version) VALUES ('20130113090638');

INSERT INTO schema_migrations (version) VALUES ('20130124031754');

INSERT INTO schema_migrations (version) VALUES ('20130124083833');

INSERT INTO schema_migrations (version) VALUES ('20130127040707');

INSERT INTO schema_migrations (version) VALUES ('20130130230012');

INSERT INTO schema_migrations (version) VALUES ('20130131212227');

INSERT INTO schema_migrations (version) VALUES ('20130131232334');

INSERT INTO schema_migrations (version) VALUES ('20130202060746');

INSERT INTO schema_migrations (version) VALUES ('20130202064111');

INSERT INTO schema_migrations (version) VALUES ('20130202073751');

INSERT INTO schema_migrations (version) VALUES ('20130202075631');

INSERT INTO schema_migrations (version) VALUES ('20130202081511');

INSERT INTO schema_migrations (version) VALUES ('20130202082810');

INSERT INTO schema_migrations (version) VALUES ('20130202083048');

INSERT INTO schema_migrations (version) VALUES ('20130202090133');

INSERT INTO schema_migrations (version) VALUES ('20130203023001');

INSERT INTO schema_migrations (version) VALUES ('20130203025256');

INSERT INTO schema_migrations (version) VALUES ('20130204010046');

INSERT INTO schema_migrations (version) VALUES ('20130207224548');

INSERT INTO schema_migrations (version) VALUES ('20130209205231');

INSERT INTO schema_migrations (version) VALUES ('20130210032122');

INSERT INTO schema_migrations (version) VALUES ('20130210033742');

INSERT INTO schema_migrations (version) VALUES ('20130211230419');

INSERT INTO schema_migrations (version) VALUES ('20130212230659');

INSERT INTO schema_migrations (version) VALUES ('20130212235126');

INSERT INTO schema_migrations (version) VALUES ('20130214002403');

INSERT INTO schema_migrations (version) VALUES ('20130214004456');

INSERT INTO schema_migrations (version) VALUES ('20130214071857');

INSERT INTO schema_migrations (version) VALUES ('20130215053430');

INSERT INTO schema_migrations (version) VALUES ('20130216032110');

INSERT INTO schema_migrations (version) VALUES ('20130217032437');

INSERT INTO schema_migrations (version) VALUES ('20130217045740');

INSERT INTO schema_migrations (version) VALUES ('20130217061832');

INSERT INTO schema_migrations (version) VALUES ('20130217234139');

INSERT INTO schema_migrations (version) VALUES ('20130218071437');

INSERT INTO schema_migrations (version) VALUES ('20130219132647');

INSERT INTO schema_migrations (version) VALUES ('20130221053536');

INSERT INTO schema_migrations (version) VALUES ('20130226214445');

INSERT INTO schema_migrations (version) VALUES ('20130226215204');

INSERT INTO schema_migrations (version) VALUES ('20130226235554');