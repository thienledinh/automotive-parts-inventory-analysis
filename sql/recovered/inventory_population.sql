-- RECOVERED CHAT SQL. Suggested historically; execution is not established by these messages.
-- Reference only; not a tested replay pipeline. See sql/README.md and PROVENANCE.md.
-- Q043 is the corrected separator-removing version; the earlier Q039 is preserved in historical notes.
-- This is recovered INSERT logic, not proof of the statements used to populate the exported database.
-- Q043 treats commas as thousands separators; it is not a universal locale parser.
-- Empty numeric strings remain NULL. The disputed Q049 null-to-zero UPDATE is deliberately excluded.
-- ON CONFLICT DO NOTHING skips existing keys; it does not update changed facts or resolve conflicting descriptions.
-- Validate missing keys and conflicts first. The inner join can omit staging rows without a product match.


-- Q035 | 2026-09-18 22:23:05 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016aad49632dd487d085fb955ece172a04
INSERT INTO core.products (
    product_code,
    product_name,
    unit_of_measure
)
SELECT DISTINCT
    UPPER(TRIM(product_code)),
    TRIM(product_name),
    NULLIF(TRIM(unit_of_measure), '')
FROM staging.inventory_summary
ON CONFLICT (product_code) DO NOTHING;


-- Q043 | 2026-09-23 20:21:26 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016ab3c455293487d09f659e26b62f7c1a
INSERT INTO core.inventory_period (
    product_id,
    warehouse_name,
    period_start,
    period_end,
    opening_quantity,
    opening_value,
    opening_average_cost,
    received_quantity,
    received_value,
    received_average_cost,
    issued_quantity,
    issued_value,
    issued_average_cost,
    closing_quantity,
    closing_value,
    closing_average_cost,
    source_file
)
SELECT
    p.product_id,
    TRIM(s.warehouse_name),
    s.period_start::DATE,
    s.period_end::DATE,

    NULLIF(REPLACE(TRIM(s.opening_quantity), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.opening_value), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.opening_average_cost), ',', ''), '')::NUMERIC(18,4),

    NULLIF(REPLACE(TRIM(s.received_quantity), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.received_value), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.received_average_cost), ',', ''), '')::NUMERIC(18,4),

    NULLIF(REPLACE(TRIM(s.issued_quantity), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.issued_value), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.issued_average_cost), ',', ''), '')::NUMERIC(18,4),

    NULLIF(REPLACE(TRIM(s.closing_quantity), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.closing_value), ',', ''), '')::NUMERIC(18,2),
    NULLIF(REPLACE(TRIM(s.closing_average_cost), ',', ''), '')::NUMERIC(18,4),

    TRIM(s.source_file)
FROM staging.inventory_summary AS s
JOIN core.products AS p
    ON p.product_code = UPPER(TRIM(s.product_code))
ON CONFLICT (
    product_id,
    warehouse_name,
    period_start,
    period_end
)
DO NOTHING;
