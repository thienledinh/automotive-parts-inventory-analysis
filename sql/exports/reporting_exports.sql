-- RECOVERED CHAT SQL. Suggested historically; execution is not established by these messages.
-- Reference only; not a tested replay pipeline. See sql/README.md and PROVENANCE.md.
-- Original reporting SELECTs from 26 October 2026, not server-side CSV-writing commands.
-- In order: inventory_status.csv, inventory_abc.csv, inventory_kpis.csv,
-- catalogue_price_change_analysis.csv, catalogue_kpis.csv.
-- Save separate result sets as UTF-8 CSV with headers in a database client.
-- No fresh exports were produced and no connection was made during this packaging task.


-- Q120 | 2026-10-26 12:16:57 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016aded46b28b887d08db2c997fbea6e5c
SELECT *
   FROM analytics.inventory_status
   ORDER BY product_code;


-- Q121 | 2026-10-26 12:59:41 +08:00 | original block 1
-- Source message: msg_02f491edd9a20d5c016adededc207087d080f9bad7f28c7f5b
SELECT *
FROM analytics.inventory_abc
ORDER BY product_code;


-- Q122 | 2026-10-26 12:59:41 +08:00 | original block 2
-- Source message: msg_02f491edd9a20d5c016adededc207087d080f9bad7f28c7f5b
SELECT *
FROM analytics.inventory_kpis;


-- Q123 | 2026-10-26 12:59:41 +08:00 | original block 3
-- Source message: msg_02f491edd9a20d5c016adededc207087d080f9bad7f28c7f5b
SELECT *
FROM analytics.catalogue_price_change_analysis
ORDER BY row_number_2025;


-- Q124 | 2026-10-26 12:59:41 +08:00 | original block 4
-- Source message: msg_02f491edd9a20d5c016adededc207087d080f9bad7f28c7f5b
SELECT *
FROM analytics.catalogue_kpis;
