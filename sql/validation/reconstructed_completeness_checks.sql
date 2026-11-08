-- RECONSTRUCTED ON 2026-11-08: new portfolio validation, not recovered original SQL.
-- Based on the exported core.inventory_period schema and the limitations of Q046/Q050.
-- Read-only SELECTs. Not executed against any database during this task.
-- Missing rows are reported separately; NULL arithmetic must not imply reconciliation success.
-- The original historical tolerance (> 0.01) is retained, not an exact-equality test.

WITH completeness AS (
    SELECT *,
        opening_quantity IS NOT NULL AND received_quantity IS NOT NULL
            AND issued_quantity IS NOT NULL AND closing_quantity IS NOT NULL AS quantities_complete,
        opening_value IS NOT NULL AND received_value IS NOT NULL
            AND issued_value IS NOT NULL AND closing_value IS NOT NULL AS values_complete
    FROM core.inventory_period
)
SELECT warehouse_name, period_start, period_end,
    COUNT(*) AS inventory_records,
    COUNT(DISTINCT product_id) AS distinct_products,
    COUNT(*) FILTER (WHERE NOT quantities_complete) AS records_missing_quantities,
    COUNT(*) FILTER (WHERE NOT values_complete) AS records_missing_values,
    COUNT(*) FILTER (
        WHERE quantities_complete
          AND ABS(opening_quantity + received_quantity - issued_quantity - closing_quantity) > 0.01
    ) AS quantity_reconciliation_errors,
    COUNT(*) FILTER (
        WHERE values_complete
          AND ABS(opening_value + received_value - issued_value - closing_value) > 0.01
    ) AS value_reconciliation_errors
FROM completeness
GROUP BY warehouse_name, period_start, period_end
ORDER BY warehouse_name, period_start, period_end;

-- New diagnostic: distinguishes numeric price comparisons from defined percentage changes.
-- The implemented views can classify a pair with a zero 2025 price as comparable,
-- but its percentage change is NULL; AVG/median therefore use fewer observations.
SELECT
    COUNT(*) AS exact_description_pairs,
    COUNT(*) FILTER (WHERE price_change_direction <> 'not_comparable') AS numeric_pairs,
    COUNT(price_change_percent) AS pairs_with_defined_percentage,
    COUNT(*) FILTER (
        WHERE listed_price_2025 = 0 AND listed_price_2026 IS NOT NULL
    ) AS numeric_pairs_with_zero_base_price
FROM analytics.catalogue_price_change_analysis;
