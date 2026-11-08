-- RECOVERED CHAT SQL. Suggested historically; execution is not established by these messages.
-- Reference only; not a tested replay pipeline. See sql/README.md and PROVENANCE.md.
-- Historical COPY examples; these write data and are not automatically safe to rerun.
-- Placeholders must be reviewed in a separate disposable environment before any execution.
-- COPY FROM paths are server-side. Identity/default columns are omitted for catalogue imports.
-- The inventory CSV must match the exported staging column order (19 columns).
-- The prepared input CSVs are not supplied. Reporting exports are NOT staging import files.


-- Q025 | 2026-09-17 23:12:16 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016aac035acec087d0a9830ce74bc04ce4
-- ADAPTED FOR PORTABILITY: historical local path replaced by a non-working placeholder.
COPY staging.inventory_summary
FROM '/REPLACE_WITH_SERVER_PATH/inventory_summary_working.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    ENCODING 'UTF8'
);


-- Q085 | 2026-10-11 20:22:52 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016acb7fa7f2e087d0bd7da12a911333e0
-- ADAPTED FOR PORTABILITY: historical local path replaced by a non-working placeholder.
COPY staging.catalogue_prices_raw (
    catalogue_version,
    effective_date,
    catalogue_row_number,
    item_description_raw,
    price_raw,
    selling_unit_raw,
    source_file
)
FROM '/REPLACE_WITH_SERVER_PATH/catalogue_2025_raw.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8',
    NULL ''
);


-- Q086 | 2026-10-11 20:24:01 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016acb7fe9b91887d094b177f722312b9a
-- ADAPTED FOR PORTABILITY: historical local path replaced by a non-working placeholder.
COPY staging.catalogue_prices_raw (
    catalogue_version,
    effective_date,
    catalogue_row_number,
    item_description_raw,
    price_raw,
    selling_unit_raw,
    source_file
)
FROM '/REPLACE_WITH_SERVER_PATH/catalogue_2026_raw.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    QUOTE '"',
    ESCAPE '"',
    ENCODING 'UTF8',
    NULL ''
);
