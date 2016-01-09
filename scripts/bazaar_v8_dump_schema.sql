--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: bazaar; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bazaar;


ALTER SCHEMA bazaar OWNER TO postgres;

--
-- Name: SCHEMA bazaar; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA bazaar IS 'bazaar schema';


--
-- Name: payment; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA payment;


ALTER SCHEMA payment OWNER TO postgres;

--
-- Name: system; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA system;


ALTER SCHEMA system OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = system, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: base; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE base (
    organization_id uuid,
    client_id uuid,
    created timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid,
    priority double precision
);


ALTER TABLE system.base OWNER TO postgres;

--
-- Name: TABLE base; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE base IS 'Base table contains the creation and modification status of a record';


--
-- Name: COLUMN base.priority; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN base.priority IS 'priority of saving data and eviction';


--
-- Name: record; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE record (
    name character varying,
    description character varying,
    help text,
    active boolean DEFAULT true NOT NULL
)
INHERITS (base);


ALTER TABLE system.record OWNER TO postgres;

--
-- Name: TABLE record; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE record IS 'All User table should inherit from this one';


--
-- Name: COLUMN record.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN record.active IS '@Active';


SET search_path = bazaar, pg_catalog;

--
-- Name: address; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE address (
    address_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    latitude double precision,
    longitude double precision,
    distance double precision
)
INHERITS (system.record);


ALTER TABLE bazaar.address OWNER TO postgres;

--
-- Name: TABLE address; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON TABLE address IS '@Address';


--
-- Name: COLUMN address.distance; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN address.distance IS 'distance is computed on the fly using the formula in sql, this is here to provide a property on the Models to store the value';


--
-- Name: api_key; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE api_key (
    api_key_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    api_key character varying NOT NULL,
    user_id uuid NOT NULL,
    valid_starting timestamp with time zone,
    valid_until timestamp with time zone
)
INHERITS (system.record);


ALTER TABLE bazaar.api_key OWNER TO postgres;

--
-- Name: cart; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE cart (
    cart_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.cart OWNER TO postgres;

--
-- Name: cart_line; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE cart_line (
    cart_id uuid,
    cart_line_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    product_id uuid,
    qty double precision
)
INHERITS (system.record);


ALTER TABLE bazaar.cart_line OWNER TO postgres;

--
-- Name: category; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE category (
    category_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.category OWNER TO postgres;

--
-- Name: client; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE client (
    client_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.client OWNER TO postgres;

--
-- Name: invoice; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE invoice (
    invoice_id uuid DEFAULT uuid_generate_v4(),
    order_id uuid,
    is_paid boolean
)
INHERITS (system.record);


ALTER TABLE bazaar.invoice OWNER TO postgres;

--
-- Name: order_line; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE order_line (
    order_id uuid,
    product_id uuid,
    price_momentary double precision,
    freight_amt double precision,
    discount double precision,
    order_line_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    qty_ordered double precision
)
INHERITS (system.record);


ALTER TABLE bazaar.order_line OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE orders (
    order_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    customer_name character varying,
    total_items integer,
    grand_total_amount double precision,
    charges_amount double precision DEFAULT 0.00,
    processing boolean DEFAULT false,
    processed boolean DEFAULT false,
    is_confirmed boolean DEFAULT false,
    is_tax_included boolean DEFAULT true,
    date_ordered timestamp with time zone DEFAULT now(),
    is_invoiced boolean DEFAULT false,
    date_invoiced timestamp with time zone,
    is_approved boolean DEFAULT false,
    date_approved timestamp with time zone,
    amount_tendered double precision,
    amount_refunded double precision,
    cart_id uuid
)
INHERITS (system.record);


ALTER TABLE bazaar.orders OWNER TO postgres;

--
-- Name: COLUMN orders.customer_name; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN orders.customer_name IS 'For recognization purposes, this is the name shown to the seller';


--
-- Name: COLUMN orders.is_confirmed; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN orders.is_confirmed IS 'determined whether the order has been confirmed by the person who ordered it';


--
-- Name: COLUMN orders.is_approved; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN orders.is_approved IS 'if the order from the buyer is approved by the seller';


--
-- Name: COLUMN orders.cart_id; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN orders.cart_id IS 'The cart from which this order was created from';


--
-- Name: organization; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE organization (
    organization_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    parent_organization_id uuid,
    address_id uuid,
    landmark character varying
)
INHERITS (system.record);


ALTER TABLE bazaar.organization OWNER TO postgres;

--
-- Name: photo; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE photo (
    photo_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    url character varying,
    data character varying,
    seq_no integer
)
INHERITS (system.record);


ALTER TABLE bazaar.photo OWNER TO postgres;

--
-- Name: COLUMN photo.url; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN photo.url IS 'The online version of the photo, could be hosted in cdn somewhere else, to avoid payloads in the system. The online photo can be cached by creating a base64 encoding, then storing it in the local db';


--
-- Name: COLUMN photo.data; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN photo.data IS 'The base64 encoding of the image, which can be stored in the database';


--
-- Name: photo_sizes; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE photo_sizes (
    width integer,
    height integer,
    data character varying,
    url character varying,
    photo_id uuid NOT NULL,
    photo_size_id uuid NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.photo_sizes OWNER TO postgres;

--
-- Name: COLUMN photo_sizes.data; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN photo_sizes.data IS 'The base64 encoding of this photo, optimized to this size';


--
-- Name: product; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE product (
    product_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    parent_product_id uuid,
    is_service boolean DEFAULT false,
    price double precision,
    use_parent_price boolean DEFAULT false,
    unit character varying,
    tags json,
    info json,
    seq_no integer,
    upfront_fee double precision DEFAULT 0.00,
    barcode character varying,
    owner_id uuid,
    currency_id uuid
)
INHERITS (system.record);


ALTER TABLE bazaar.product OWNER TO postgres;

--
-- Name: TABLE product; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON TABLE product IS 'This will be exposed as an @Api, including @Table(users, category, product_availability, photo)';


--
-- Name: COLUMN product.organization_id; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.organization_id IS '@Value(users.user_id) , which means the value will be set with the users.user_id value

@Where(users.active=true)';


--
-- Name: COLUMN product.client_id; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.client_id IS '@Value(users.client_id) The client_id of the user creating this records';


--
-- Name: COLUMN product.created_by; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.created_by IS '@Value(users.user_id)';


--
-- Name: COLUMN product.updated_by; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.updated_by IS '@Value(users.user_id)';


--
-- Name: COLUMN product.name; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.name IS 'This is @Required it has @DisplayLength(50) - 50 character in display length a @MinLength(1) and @MaxLength(100) - Do not go over 100 characters or else the system will throw a ValueTooLong exception
can also be express with @Length(1-100)';


--
-- Name: COLUMN product.description; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.description IS '@DisplayLength(100) When building a UI for this field
@MaxLength(200) Do not go over 200 character on this one';


--
-- Name: COLUMN product.active; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.active IS '@Active';


--
-- Name: COLUMN product.info; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.info IS '{color:"red",
dimension:"10x20x30",
dimensionUnit:"mm",
weight:"4",
weightUnit:"kg"
}';


--
-- Name: COLUMN product.seq_no; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.seq_no IS '@Sequence can be used to do alternate ordering of the values, when alphetical or time can not be used';


--
-- Name: COLUMN product.upfront_fee; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.upfront_fee IS 'Applicable to services, usually services has an upfront fee';


--
-- Name: COLUMN product.barcode; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.barcode IS 'barcode if scanning the product, conflict can happen, expect to return matching list of products using the barcode';


--
-- Name: COLUMN product.owner_id; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product.owner_id IS 'Whom this product belongs, since created_by can be someone else create the product list in behalf of the owner of the product';


--
-- Name: product_availability; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE product_availability (
    product_id uuid NOT NULL,
    available boolean,
    always_available boolean,
    stocks double precision DEFAULT 1,
    available_from timestamp with time zone,
    available_until timestamp with time zone,
    available_day json,
    open_time time with time zone,
    close_time time with time zone
)
INHERITS (system.base);


ALTER TABLE bazaar.product_availability OWNER TO postgres;

--
-- Name: COLUMN product_availability.available_day; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN product_availability.available_day IS '{"Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"}';


--
-- Name: product_category; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE product_category (
    product_id uuid NOT NULL,
    category_id uuid NOT NULL
)
INHERITS (system.base);


ALTER TABLE bazaar.product_category OWNER TO postgres;

--
-- Name: product_photo; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE product_photo (
    product_id uuid NOT NULL,
    photo_id uuid NOT NULL
)
INHERITS (system.base);


ALTER TABLE bazaar.product_photo OWNER TO postgres;

--
-- Name: product_review; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE product_review (
    product_id uuid NOT NULL,
    review_id uuid NOT NULL
)
INHERITS (system.base);


ALTER TABLE bazaar.product_review OWNER TO postgres;

--
-- Name: review; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE review (
    rating integer,
    comment character varying,
    review_id uuid NOT NULL,
    user_id uuid,
    approved boolean,
    approvedby uuid
)
INHERITS (system.record);


ALTER TABLE bazaar.review OWNER TO postgres;

--
-- Name: TABLE review; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON TABLE review IS 'Reviews of buyers from the sellers and the sellers'' products';


--
-- Name: COLUMN review.rating; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN review.rating IS 'rating 1 to 5, 5 is the highest';


--
-- Name: COLUMN review.comment; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN review.comment IS 'The statement of the review';


--
-- Name: COLUMN review.approvedby; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN review.approvedby IS 'the user id who approves the review';


--
-- Name: settings; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE settings (
    user_id uuid,
    value json,
    settings_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    use_metric boolean DEFAULT true
)
INHERITS (system.record);


ALTER TABLE bazaar.settings OWNER TO postgres;

--
-- Name: COLUMN settings.use_metric; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN settings.use_metric IS 'Use metric system as unit, if false, use english system';


--
-- Name: user_info; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE user_info (
    user_id uuid NOT NULL,
    address_id uuid,
    current_location character varying,
    displayname character varying,
    photo_id uuid
)
INHERITS (system.record);


ALTER TABLE bazaar.user_info OWNER TO postgres;

--
-- Name: user_location; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE user_location (
    true_latitude double precision,
    true_longitude double precision,
    set_latitude double precision,
    set_longitude double precision,
    accuracy double precision,
    set_accuracy double precision,
    user_id uuid NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.user_location OWNER TO postgres;

--
-- Name: COLUMN user_location.set_accuracy; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN user_location.set_accuracy IS 'user can anonymize their location by setting loose accuracy';


--
-- Name: user_review; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE user_review (
    user_id uuid NOT NULL,
    review_id uuid NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.user_review OWNER TO postgres;

--
-- Name: TABLE user_review; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON TABLE user_review IS 'Reviews of the seller by the user';


--
-- Name: COLUMN user_review.user_id; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN user_review.user_id IS 'The user id of the seller being reviewed';


--
-- Name: users; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    user_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    username character varying,
    password character varying,
    email character varying
)
INHERITS (system.record);


ALTER TABLE bazaar.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON TABLE users IS 'This are @Users, will be used for @Login';


--
-- Name: COLUMN users.active; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN users.active IS '@Active';


--
-- Name: COLUMN users.username; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN users.username IS '@Username
@DisplayLength(20)
@Length(2-100)';


--
-- Name: COLUMN users.password; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN users.password IS 'The users'' @Password will be check against the value, while you can also specify hashing alogrithm used of the value @Hash(SHA256), or just @SHA256.

SHA512, CLEAR_TEXT, MD5 can also be used.
@Length(8-50)
@DisplayLength(20)';


--
-- Name: COLUMN users.email; Type: COMMENT; Schema: bazaar; Owner: postgres
--

COMMENT ON COLUMN users.email IS '@Email';


--
-- Name: wishlist; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE wishlist (
    wishlist_id uuid DEFAULT uuid_generate_v4() NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.wishlist OWNER TO postgres;

--
-- Name: wishlist_line; Type: TABLE; Schema: bazaar; Owner: postgres; Tablespace: 
--

CREATE TABLE wishlist_line (
    wishlist_id uuid,
    price_momentary double precision,
    product_id uuid,
    added_to_cart boolean DEFAULT false,
    wishlist_line_id uuid NOT NULL
)
INHERITS (system.record);


ALTER TABLE bazaar.wishlist_line OWNER TO postgres;

SET search_path = payment, pg_catalog;

--
-- Name: country; Type: TABLE; Schema: payment; Owner: postgres; Tablespace: 
--

CREATE TABLE country (
    country_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    code character varying
)
INHERITS (system.record);


ALTER TABLE payment.country OWNER TO postgres;

--
-- Name: currency; Type: TABLE; Schema: payment; Owner: postgres; Tablespace: 
--

CREATE TABLE currency (
    currency_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    country_id uuid,
    symbol character varying,
    unicode character varying
)
INHERITS (system.record);


ALTER TABLE payment.currency OWNER TO postgres;

--
-- Name: COLUMN currency.country_id; Type: COMMENT; Schema: payment; Owner: postgres
--

COMMENT ON COLUMN currency.country_id IS 'which country uses this currency';


--
-- Name: exchange_rate; Type: TABLE; Schema: payment; Owner: postgres; Tablespace: 
--

CREATE TABLE exchange_rate (
    exchange_rate_id uuid DEFAULT uuid_generate_v4() NOT NULL,
    from_currency uuid,
    exchange_rate double precision,
    to_currency uuid
)
INHERITS (system.record);


ALTER TABLE payment.exchange_rate OWNER TO postgres;

--
-- Name: COLUMN exchange_rate.exchange_rate_id; Type: COMMENT; Schema: payment; Owner: postgres
--

COMMENT ON COLUMN exchange_rate.exchange_rate_id IS 'this will be referred when processing payments with different currencies';


SET search_path = bazaar, pg_catalog;

--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY address ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY api_key ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY api_key ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY api_key ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY cart ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY cart ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY cart ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY cart_line ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY cart_line ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY cart_line ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY category ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY category ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY category ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY client ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY client ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY client ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY invoice ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY invoice ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY invoice ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY order_line ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY order_line ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY order_line ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY orders ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY organization ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY organization ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY organization ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY photo ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY photo ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY photo ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY photo_sizes ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY photo_sizes ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY photo_sizes ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_availability ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_availability ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_category ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_category ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_photo ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_photo ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_review ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_review ALTER COLUMN updated SET DEFAULT now();


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY review ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY review ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY review ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY settings ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_info ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_info ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_info ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_location ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_location ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_location ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_review ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_review ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_review ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY wishlist ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY wishlist ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY wishlist ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY wishlist_line ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY wishlist_line ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY wishlist_line ALTER COLUMN active SET DEFAULT true;


SET search_path = payment, pg_catalog;

--
-- Name: created; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY country ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY country ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY country ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY currency ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY currency ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY currency ALTER COLUMN active SET DEFAULT true;


--
-- Name: created; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY exchange_rate ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY exchange_rate ALTER COLUMN updated SET DEFAULT now();


--
-- Name: active; Type: DEFAULT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY exchange_rate ALTER COLUMN active SET DEFAULT true;


SET search_path = system, pg_catalog;

--
-- Name: created; Type: DEFAULT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY record ALTER COLUMN created SET DEFAULT now();


--
-- Name: updated; Type: DEFAULT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY record ALTER COLUMN updated SET DEFAULT now();


SET search_path = bazaar, pg_catalog;

--
-- Name: address_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- Name: api_key_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (api_key_id);


--
-- Name: cart_line_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cart_line
    ADD CONSTRAINT cart_line_pkey PRIMARY KEY (cart_line_id);


--
-- Name: cart_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (cart_id);


--
-- Name: category_name_key; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_name_key UNIQUE (name);


--
-- Name: category_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: client_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- Name: order_line_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY order_line
    ADD CONSTRAINT order_line_pkey PRIMARY KEY (order_line_id);


--
-- Name: order_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT order_pkey PRIMARY KEY (order_id);


--
-- Name: organization_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (organization_id);


--
-- Name: photo_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY photo
    ADD CONSTRAINT photo_pkey PRIMARY KEY (photo_id);


--
-- Name: photo_sizes_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY photo_sizes
    ADD CONSTRAINT photo_sizes_pkey PRIMARY KEY (photo_id, photo_size_id);


--
-- Name: product_availability_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_availability
    ADD CONSTRAINT product_availability_pkey PRIMARY KEY (product_id);


--
-- Name: product_category_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (product_id, category_id);


--
-- Name: product_photo_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_photo
    ADD CONSTRAINT product_photo_pkey PRIMARY KEY (product_id, photo_id);


--
-- Name: product_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_pkey PRIMARY KEY (product_id);


--
-- Name: product_review_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY product_review
    ADD CONSTRAINT product_review_pkey PRIMARY KEY (product_id, review_id);


--
-- Name: review_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY review
    ADD CONSTRAINT review_pkey PRIMARY KEY (review_id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (settings_id);


--
-- Name: user_info_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (user_id);


--
-- Name: user_location_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT user_location_pkey PRIMARY KEY (user_id);


--
-- Name: user_review_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY user_review
    ADD CONSTRAINT user_review_pkey PRIMARY KEY (user_id, review_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: wishlist_line_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wishlist_line
    ADD CONSTRAINT wishlist_line_pkey PRIMARY KEY (wishlist_line_id);


--
-- Name: wishlist_pkey; Type: CONSTRAINT; Schema: bazaar; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wishlist
    ADD CONSTRAINT wishlist_pkey PRIMARY KEY (wishlist_id);


SET search_path = payment, pg_catalog;

--
-- Name: country_pkey; Type: CONSTRAINT; Schema: payment; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY country
    ADD CONSTRAINT country_pkey PRIMARY KEY (country_id);


--
-- Name: currency_pkey; Type: CONSTRAINT; Schema: payment; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (currency_id);


--
-- Name: exchange_rate_id_pkey; Type: CONSTRAINT; Schema: payment; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY exchange_rate
    ADD CONSTRAINT exchange_rate_id_pkey PRIMARY KEY (exchange_rate_id);


SET search_path = bazaar, pg_catalog;

--
-- Name: api_key_user_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY api_key
    ADD CONSTRAINT api_key_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: cart_line_cart_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY cart_line
    ADD CONSTRAINT cart_line_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES cart(cart_id);


--
-- Name: order_line_order_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY order_line
    ADD CONSTRAINT order_line_order_id_fkey FOREIGN KEY (order_id) REFERENCES orders(order_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: order_line_product_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY order_line
    ADD CONSTRAINT order_line_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: organization_parent_organization_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY organization
    ADD CONSTRAINT organization_parent_organization_id_fkey FOREIGN KEY (parent_organization_id) REFERENCES organization(organization_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: photo_sizes_photo_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY photo_sizes
    ADD CONSTRAINT photo_sizes_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES photo(photo_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_availability_product_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_availability
    ADD CONSTRAINT product_availability_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_category_category_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_category
    ADD CONSTRAINT product_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES category(category_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_category_product_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_category
    ADD CONSTRAINT product_category_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_currency_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES payment.currency(currency_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_photo_photo_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_photo
    ADD CONSTRAINT product_photo_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES photo(photo_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_photo_product_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_photo
    ADD CONSTRAINT product_photo_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_review_product_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_review
    ADD CONSTRAINT product_review_product_id_fkey FOREIGN KEY (product_id) REFERENCES product(product_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_review_review_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product_review
    ADD CONSTRAINT product_review_review_id_fkey FOREIGN KEY (review_id) REFERENCES review(review_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: product_user_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_user_id_fkey FOREIGN KEY (owner_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: review_user_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY review
    ADD CONSTRAINT review_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: settings_user_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_info_address_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_address_id_fkey FOREIGN KEY (address_id) REFERENCES address(address_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_info_photo_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_photo_id_fkey FOREIGN KEY (photo_id) REFERENCES photo(photo_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_info_user_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_location_user_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT user_location_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_review_review_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_review
    ADD CONSTRAINT user_review_review_id_fkey FOREIGN KEY (review_id) REFERENCES review(review_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: user_review_user_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY user_review
    ADD CONSTRAINT user_review_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: wishlist_line_wishlist_id_fkey; Type: FK CONSTRAINT; Schema: bazaar; Owner: postgres
--

ALTER TABLE ONLY wishlist_line
    ADD CONSTRAINT wishlist_line_wishlist_id_fkey FOREIGN KEY (wishlist_id) REFERENCES wishlist(wishlist_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


SET search_path = payment, pg_catalog;

--
-- Name: currency_country_id_fkey; Type: FK CONSTRAINT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY currency
    ADD CONSTRAINT currency_country_id_fkey FOREIGN KEY (country_id) REFERENCES country(country_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: exchange_rate_from_currency_fkey; Type: FK CONSTRAINT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY exchange_rate
    ADD CONSTRAINT exchange_rate_from_currency_fkey FOREIGN KEY (from_currency) REFERENCES currency(currency_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: exchange_rate_to_currency_fkey; Type: FK CONSTRAINT; Schema: payment; Owner: postgres
--

ALTER TABLE ONLY exchange_rate
    ADD CONSTRAINT exchange_rate_to_currency_fkey FOREIGN KEY (to_currency) REFERENCES currency(currency_id) ON UPDATE CASCADE ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

