-- CURRENT EXPORTED DEFINITIONS: 8 November 2026. Extracted from pg_dump 18.6.
-- SQL statement bodies unchanged (line endings normalised). Comments added for provenance.
-- Reading/reference copy; not a tested migration. CREATE/ALTER will modify a database.
-- No SQL was executed while organising this package. Original full dump retained privately.

-- Dump line 368; object analytics.inventory_status
CREATE VIEW analytics.inventory_status AS
 SELECT p.product_id,
    p.product_code,
    p.product_name,
    p.unit_of_measure,
    i.warehouse_name,
    i.period_start,
    i.period_end,
    i.opening_quantity,
    i.received_quantity,
    i.issued_quantity,
    i.closing_quantity,
    i.opening_value,
    i.received_value,
    i.issued_value,
    i.closing_value,
        CASE
            WHEN ((i.closing_quantity = (0)::numeric) AND (i.issued_quantity > (0)::numeric)) THEN 'Zero closing after issue'::text
            WHEN ((i.received_quantity = (0)::numeric) AND (i.issued_quantity = (0)::numeric) AND (i.closing_quantity > (0)::numeric)) THEN 'No movement with stock'::text
            WHEN ((i.received_quantity = (0)::numeric) AND (i.issued_quantity = (0)::numeric) AND (i.closing_quantity = (0)::numeric)) THEN 'No movement and no stock'::text
            WHEN ((i.received_quantity > (0)::numeric) AND (i.issued_quantity = (0)::numeric)) THEN 'Received without issue'::text
            WHEN ((i.received_quantity > (0)::numeric) AND (i.issued_quantity > (0)::numeric)) THEN 'Received and issued'::text
            WHEN ((i.received_quantity = (0)::numeric) AND (i.issued_quantity > (0)::numeric)) THEN 'Issued without receipt'::text
            ELSE 'Review'::text
        END AS inventory_status
   FROM (core.inventory_period i
     JOIN core.products p ON ((p.product_id = i.product_id)));

-- Dump line 402; object analytics.inventory_abc
CREATE VIEW analytics.inventory_abc AS
 WITH ranked_products AS (
         SELECT inventory_status.product_code,
            inventory_status.product_name,
            inventory_status.unit_of_measure,
            inventory_status.closing_quantity,
            inventory_status.closing_value,
            sum(inventory_status.closing_value) OVER () AS total_closing_value,
            sum(inventory_status.closing_value) OVER (ORDER BY inventory_status.closing_value DESC, inventory_status.product_code ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_closing_value
           FROM analytics.inventory_status
          WHERE (inventory_status.closing_value > (0)::numeric)
        ), calculated_percentages AS (
         SELECT ranked_products.product_code,
            ranked_products.product_name,
            ranked_products.unit_of_measure,
            ranked_products.closing_quantity,
            ranked_products.closing_value,
            round(((100.0 * ranked_products.closing_value) / NULLIF(ranked_products.total_closing_value, (0)::numeric)), 2) AS inventory_value_pct,
            round(((100.0 * ranked_products.cumulative_closing_value) / NULLIF(ranked_products.total_closing_value, (0)::numeric)), 2) AS cumulative_inventory_value_pct
           FROM ranked_products
        )
 SELECT product_code,
    product_name,
    unit_of_measure,
    closing_quantity,
    closing_value,
    inventory_value_pct,
    cumulative_inventory_value_pct,
        CASE
            WHEN (cumulative_inventory_value_pct <= (80)::numeric) THEN 'A'::text
            WHEN (cumulative_inventory_value_pct <= (95)::numeric) THEN 'B'::text
            ELSE 'C'::text
        END AS abc_class
   FROM calculated_percentages;

-- Dump line 443; object analytics.inventory_kpis
CREATE VIEW analytics.inventory_kpis AS
 SELECT count(*) AS total_products,
    count(*) FILTER (WHERE (issued_quantity > (0)::numeric)) AS products_with_issues,
    count(*) FILTER (WHERE (received_quantity > (0)::numeric)) AS products_with_receipts,
    count(*) FILTER (WHERE ((received_quantity = (0)::numeric) AND (issued_quantity = (0)::numeric) AND (closing_quantity > (0)::numeric))) AS no_movement_with_stock,
    count(*) FILTER (WHERE ((issued_quantity > (0)::numeric) AND (closing_quantity = (0)::numeric))) AS zero_closing_after_issue,
    sum(opening_value) AS opening_inventory_value,
    sum(received_value) AS received_inventory_value,
    sum(issued_value) AS issued_inventory_value,
    sum(closing_value) AS closing_inventory_value
   FROM core.inventory_period;

-- Dump line 461; object analytics.no_movement_review
CREATE VIEW analytics.no_movement_review AS
 SELECT row_number() OVER (ORDER BY closing_value DESC, product_code) AS review_rank,
    product_code,
    product_name,
    unit_of_measure,
    period_start,
    period_end,
    opening_quantity,
    closing_quantity,
    closing_value,
    round(((100.0 * closing_value) / NULLIF(sum(closing_value) OVER (), (0)::numeric)), 2) AS share_of_no_movement_value_pct
   FROM analytics.inventory_status
  WHERE (inventory_status = 'No movement with stock'::text);

-- Dump line 481; object analytics.no_movement_reviews
CREATE VIEW analytics.no_movement_reviews AS
 SELECT row_number() OVER (ORDER BY closing_value DESC, product_code) AS review_rank,
    product_code,
    product_name,
    unit_of_measure,
    period_start,
    period_end,
    opening_quantity,
    closing_quantity,
    closing_value,
    round(((100.0 * closing_value) / NULLIF(sum(closing_value) OVER (), (0)::numeric)), 2) AS share_of_no_movement_value_pct
   FROM analytics.inventory_status
  WHERE (inventory_status = 'No movement with stock'::text);

-- Dump line 501; object analytics.zero_closing_review
CREATE VIEW analytics.zero_closing_review AS
 SELECT row_number() OVER (ORDER BY issued_value DESC, product_code) AS review_rank,
    product_code,
    product_name,
    unit_of_measure,
    period_start,
    period_end,
    opening_quantity,
    received_quantity,
    issued_quantity,
    issued_value,
    closing_quantity,
    closing_value
   FROM analytics.inventory_status
  WHERE (inventory_status = 'Zero closing after issue'::text);

-- Dump line 523; object analytics.zero_closing_reviews
CREATE VIEW analytics.zero_closing_reviews AS
 SELECT row_number() OVER (ORDER BY issued_value DESC, product_code) AS review_rank,
    product_code,
    product_name,
    unit_of_measure,
    period_start,
    period_end,
    opening_quantity,
    received_quantity,
    issued_quantity,
    issued_value,
    closing_quantity,
    closing_value
   FROM analytics.inventory_status
  WHERE (inventory_status = 'Zero closing after issue'::text);
