-- RECOVERED CHAT SQL. Suggested historically; execution is not established by these messages.
-- Reference only; not a tested replay pipeline. See sql/README.md and PROVENANCE.md.
-- Selected original SELECT checks, deduplicated for readability. No results are asserted here.
-- Q006/Q007 originated in the early proposal but refer to columns present in the final schema.
-- Q046 checks missing quantities, not missing values; NULL arithmetic can hide incomplete records.
-- Use the separately labelled reconstructed completeness check when reviewing both quantity and value.
-- Some SELECTs return business records or source paths if run; no query results are included.


-- Q031 | 2026-09-17 23:38:04 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016aac096a9d8087d0ba9c99c821b40dd8
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT UPPER(TRIM(product_code))) AS unique_product_codes,
    COUNT(*) FILTER (
        WHERE NULLIF(TRIM(product_code), '') IS NULL
    ) AS missing_product_codes
FROM staging.inventory_summary;


-- Q006 | 2026-09-14 11:13:18 +08:00 | original block 6
-- Source message: msg_02f491edd9a20d5c016aa766b986e887d0a0d45eafde113833
SELECT
    TRIM(UPPER(product_code)) AS standardized_code,
    COUNT(*) AS record_count
FROM staging.inventory_summary
GROUP BY TRIM(UPPER(product_code))
HAVING COUNT(*) > 1;


-- Q007 | 2026-09-14 11:13:18 +08:00 | original block 7
-- Source message: msg_02f491edd9a20d5c016aa766b986e887d0a0d45eafde113833
SELECT
    unit_of_measure,
    COUNT(*) AS product_count
FROM staging.inventory_summary
GROUP BY unit_of_measure
ORDER BY product_count DESC;


-- Q028 | 2026-09-17 23:36:03 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016aac08f5fe7887d0bcdee8dc1a905ede
SELECT
    warehouse_name,
    product_code,
    product_name,
    closing_quantity,
    closing_value,
    source_file
FROM staging.inventory_summary
WHERE NULLIF(TRIM(product_code), '') IS NULL;


-- Q033 | 2026-09-17 23:38:04 +08:00 | original block 3
-- Source message: msg_02f491edd9a20d5c016aac096a9d8087d0ba9c99c821b40dd8
SELECT DISTINCT
    period_start,
    period_end,
    source_file
FROM staging.inventory_summary;


-- Q036 | 2026-09-18 22:23:05 +08:00 | original block 3
-- Source message: msg_02f491edd9a20d5c016aad49632dd487d085fb955ece172a04
SELECT COUNT(*) AS product_count
FROM core.products;


-- Q040 | 2026-09-23 20:18:14 +08:00 | original block 3
-- Source message: msg_02f491edd9a20d5c016ab3c3a5d88487d0bb609d602be571a9
SELECT COUNT(*) AS inventory_records
FROM core.inventory_period;


-- Q046 | 2026-09-24 20:14:17 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016ab51428868487d0ad282586f8ec031a
SELECT
    COUNT(*) FILTER (
        WHERE opening_quantity IS NULL
           OR received_quantity IS NULL
           OR issued_quantity IS NULL
           OR closing_quantity IS NULL
    ) AS rows_missing_quantities,

    COUNT(*) FILTER (
        WHERE ABS(
            opening_quantity
            + received_quantity
            - issued_quantity
            - closing_quantity
        ) > 0.01
    ) AS quantity_reconciliation_errors,

    COUNT(*) FILTER (
        WHERE ABS(
            opening_value
            + received_value
            - issued_value
            - closing_value
        ) > 0.01
    ) AS value_reconciliation_errors
FROM core.inventory_period;


-- Q048 | 2026-09-24 20:17:21 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016ab514e4f8c487d0b3275e731c6dd38c
SELECT
    COUNT(*) FILTER (
        WHERE opening_quantity IS NULL
    ) AS missing_opening_quantity,

    COUNT(*) FILTER (
        WHERE received_quantity IS NULL
    ) AS missing_received_quantity,

    COUNT(*) FILTER (
        WHERE issued_quantity IS NULL
    ) AS missing_issued_quantity,

    COUNT(*) FILTER (
        WHERE closing_quantity IS NULL
    ) AS missing_closing_quantity
FROM core.inventory_period;


-- Q052 | 2026-09-24 20:19:58 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016ab515823c2087d086817476eb6a9481
SELECT
    inventory_status,
    COUNT(*) AS product_count,
    SUM(closing_value) AS closing_inventory_value
FROM analytics.inventory_status
GROUP BY inventory_status
ORDER BY product_count DESC;


-- Q057 | 2026-09-24 21:00:02 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016ab51ee5207087d088f0d615e621ffbb
SELECT
    COUNT(*) AS review_products,
    SUM(closing_value) AS review_inventory_value
FROM analytics.no_movement_review;


-- Q060 | 2026-09-24 21:00:02 +08:00 | original block 5
-- Source message: msg_02f491edd9a20d5c016ab51ee5207087d088f0d615e621ffbb
SELECT COUNT(*) AS zero_closing_products
FROM analytics.zero_closing_review;


-- Q067 | 2026-09-27 19:55:03 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016ab9042810c087d0a37019b4c479c888
SELECT
    abc_class,
    COUNT(*) AS product_count,
    SUM(closing_value) AS closing_inventory_value,
    ROUND(
        100.0 * SUM(closing_value)
        / SUM(SUM(closing_value)) OVER (),
        2
    ) AS share_of_inventory_value_pct
FROM analytics.inventory_abc
GROUP BY abc_class
ORDER BY abc_class;


-- Q068 | 2026-09-27 19:55:03 +08:00 | original block 3
-- Source message: msg_02f491edd9a20d5c016ab9042810c087d0a37019b4c479c888
SELECT
    COUNT(*) AS classified_products,
    SUM(closing_value) AS classified_inventory_value
FROM analytics.inventory_abc;


-- Q087 | 2026-10-11 20:24:01 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016acb7fe9b91887d094b177f722312b9a
SELECT
    catalogue_version,
    COUNT(*) AS product_rows
FROM staging.catalogue_prices_raw
GROUP BY catalogue_version
ORDER BY catalogue_version;


-- Q089 | 2026-10-11 20:24:42 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016acb8018e59887d090ccc1f9b52c2eb0
SELECT
    catalogue_version,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT catalogue_row_number) AS distinct_row_numbers,
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(item_description_raw), '') IS NULL
    ) AS missing_descriptions,
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(price_raw), '') IS NULL
    ) AS missing_prices,
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(selling_unit_raw), '') IS NULL
    ) AS missing_units
FROM staging.catalogue_prices_raw
GROUP BY catalogue_version
ORDER BY catalogue_version;


-- Q090 | 2026-10-11 20:24:42 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016acb8018e59887d090ccc1f9b52c2eb0
SELECT
    catalogue_version,
    catalogue_row_number,
    COUNT(*) AS duplicate_count
FROM staging.catalogue_prices_raw
GROUP BY catalogue_version, catalogue_row_number
HAVING COUNT(*) > 1;


-- Q092 | 2026-10-11 20:25:36 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016acb804e958087d088f456d9a10708d1
SELECT
    catalogue_version,
    price_status,
    COUNT(*) AS product_count
FROM core.catalogue_prices_clean
GROUP BY catalogue_version, price_status
ORDER BY catalogue_version, price_status;


-- Q094 | 2026-10-14 21:13:36 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016acf8019ba9c87d0b4d86ccb93525ce7
WITH descriptions AS (
    SELECT
        catalogue_version,
        LOWER(
            REGEXP_REPLACE(
                BTRIM(item_description),
                '\s+',
                ' ',
                'g'
            )
        ) AS description_key
    FROM core.catalogue_prices_clean
)
SELECT
    catalogue_version,
    description_key,
    COUNT(*) AS occurrences
FROM descriptions
GROUP BY catalogue_version, description_key
HAVING COUNT(*) > 1
ORDER BY catalogue_version, occurrences DESC;


-- Q096 | 2026-10-14 21:13:36 +08:00 | original block 3
-- Source message: msg_02f491edd9a20d5c016acf8019ba9c87d0b4d86ccb93525ce7
SELECT COUNT(*) AS exact_product_matches
FROM analytics.catalogue_price_comparison_exact;


-- Q098 | 2026-10-14 21:15:19 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016acf80741a2487d0bdb6756cbb6f4fce
SELECT
    catalogue_version,
    COUNT(*) AS unmatched_products
FROM analytics.catalogue_unmatched_review
GROUP BY catalogue_version
ORDER BY catalogue_version;


-- Q102 | 2026-10-14 21:16:30 +08:00 | original block 3
-- Source message: msg_02f491edd9a20d5c016acf80c538ac87d0a5b6304523d664ff
SELECT
    row_number_2025,
    description_2025,
    row_number_2026,
    description_2026,
    ROUND(similarity_score::NUMERIC, 3) AS similarity_score
FROM analytics.catalogue_match_candidates
WHERE candidate_rank = 1
ORDER BY similarity_score DESC;


-- Q108 | 2026-10-20 20:15:06 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016ad75b543c0087d0bf5c93c5daa14dcb
SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema IN (
    'staging',
    'core',
    'analytics'
)
ORDER BY
    table_schema,
    table_type,
    table_name;


-- Q109 | 2026-10-20 20:15:06 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016ad75b543c0087d0bf5c93c5daa14dcb
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'analytics'
ORDER BY table_name, ordinal_position;


-- Q110 | 2026-10-20 20:16:41 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016ad75bc0207c87d0aaf9f66e8ba83c23
SELECT
    table_name,
    STRING_AGG(
        column_name || ' (' || data_type || ')',
        ', '
        ORDER BY ordinal_position
    ) AS columns
FROM information_schema.columns
WHERE table_schema = 'analytics'
  AND table_name IN (
      'inventory_kpis',
      'inventory_status',
      'inventory_abc',
      'no_movement_review',
      'zero_closing_review',
      'catalogue_kpis',
      'catalogue_price_change_analysis'
  )
GROUP BY table_name
ORDER BY table_name;
