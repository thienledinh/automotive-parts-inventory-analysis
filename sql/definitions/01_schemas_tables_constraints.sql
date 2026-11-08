-- CURRENT EXPORTED DEFINITIONS: 8 November 2026. Extracted from pg_dump 18.6.
-- SQL statement bodies unchanged (line endings normalised). Comments added for provenance.
-- Reading/reference copy; not a tested migration. CREATE/ALTER will modify a database.
-- No SQL was executed while organising this package. Original full dump retained privately.

-- Dump line 29; object analytics;
CREATE SCHEMA analytics;

-- Dump line 37; object core;
CREATE SCHEMA core;

-- Dump line 45; object staging;
CREATE SCHEMA staging;

-- Dump line 53; object public.pg_trgm
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

-- Dump line 74; object staging.catalogue_prices_raw
CREATE TABLE staging.catalogue_prices_raw (
    catalogue_record_id bigint NOT NULL,
    catalogue_version text NOT NULL,
    effective_date date,
    catalogue_row_number integer,
    item_description_raw text NOT NULL,
    price_raw text,
    selling_unit_raw text,
    source_file text NOT NULL,
    loaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Dump line 327; object core.inventory_period
CREATE TABLE core.inventory_period (
    inventory_id bigint NOT NULL,
    product_id bigint NOT NULL,
    warehouse_name text NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    opening_quantity numeric(18,2),
    opening_value numeric(18,2),
    opening_average_cost numeric(18,4),
    received_quantity numeric(18,2),
    received_value numeric(18,2),
    received_average_cost numeric(18,4),
    issued_quantity numeric(18,2),
    issued_value numeric(18,2),
    issued_average_cost numeric(18,4),
    closing_quantity numeric(18,2),
    closing_value numeric(18,2),
    closing_average_cost numeric(18,4),
    source_file text,
    CONSTRAINT valid_inventory_period CHECK ((period_end >= period_start))
);

-- Dump line 355; object core.products
CREATE TABLE core.products (
    product_id bigint NOT NULL,
    product_code text NOT NULL,
    product_name text NOT NULL,
    unit_of_measure text
);

-- Dump line 545; object core.inventory_period
ALTER TABLE core.inventory_period ALTER COLUMN inventory_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME core.inventory_period_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

-- Dump line 560; object core.products
ALTER TABLE core.products ALTER COLUMN product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME core.products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

-- Dump line 575; object staging.catalogue_prices_raw
ALTER TABLE staging.catalogue_prices_raw ALTER COLUMN catalogue_record_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME staging.catalogue_prices_raw_catalogue_record_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

-- Dump line 590; object staging.inventory_summary
CREATE TABLE staging.inventory_summary (
    warehouse_name text,
    product_code text,
    product_name text,
    unit_of_measure text,
    opening_quantity text,
    opening_value text,
    opening_average_cost text,
    received_quantity text,
    received_value text,
    received_average_cost text,
    issued_quantity text,
    issued_value text,
    issued_average_cost text,
    closing_quantity text,
    closing_value text,
    closing_average_cost text,
    period_start text,
    period_end text,
    source_file text
);

-- Dump line 618; object core.inventory_period
ALTER TABLE ONLY core.inventory_period
    ADD CONSTRAINT inventory_period_pkey PRIMARY KEY (inventory_id);

-- Dump line 627; object core.products
ALTER TABLE ONLY core.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);

-- Dump line 636; object core.products
ALTER TABLE ONLY core.products
    ADD CONSTRAINT products_product_code_key UNIQUE (product_code);

-- Dump line 645; object core.inventory_period
ALTER TABLE ONLY core.inventory_period
    ADD CONSTRAINT unique_product_inventory_period UNIQUE (product_id, warehouse_name, period_start, period_end);

-- Dump line 654; object staging.catalogue_prices_raw
ALTER TABLE ONLY staging.catalogue_prices_raw
    ADD CONSTRAINT catalogue_prices_raw_pkey PRIMARY KEY (catalogue_record_id);

-- Dump line 663; object core.inventory_period
ALTER TABLE ONLY core.inventory_period
    ADD CONSTRAINT inventory_period_product_id_fkey FOREIGN KEY (product_id) REFERENCES core.products(product_id);
