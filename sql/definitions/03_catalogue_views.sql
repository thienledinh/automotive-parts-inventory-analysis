-- CURRENT EXPORTED DEFINITIONS: 8 November 2026. Extracted from pg_dump 18.6.
-- SQL statement bodies unchanged (line endings normalised). Comments added for provenance.
-- Reading/reference copy; not a tested migration. CREATE/ALTER will modify a database.
-- No SQL was executed while organising this package. Original full dump retained privately.

-- Dump line 92; object core.catalogue_prices_clean
CREATE VIEW core.catalogue_prices_clean AS
 SELECT catalogue_record_id,
    catalogue_version,
    effective_date,
    catalogue_row_number,
    btrim(item_description_raw) AS item_description,
    btrim(price_raw) AS price_raw,
    NULLIF(btrim(selling_unit_raw), ''::text) AS selling_unit,
    source_file,
        CASE
            WHEN (NULLIF(btrim(price_raw), ''::text) IS NULL) THEN 'missing'::text
            WHEN ((lower(price_raw) ~~ '%gọi điện%'::text) OR (lower(price_raw) ~~ '%báo giá%'::text)) THEN 'call_for_price'::text
            WHEN (btrim(price_raw) ~ '^[0-9]+([.,][0-9]+)?$'::text) THEN 'single_numeric'::text
            WHEN (price_raw ~ '[0-9]'::text) THEN 'multiple_or_annotated'::text
            ELSE 'other_text'::text
        END AS price_status,
        CASE
            WHEN (btrim(price_raw) ~ '^[0-9]+([.,][0-9]+)?$'::text) THEN (replace(btrim(price_raw), ','::text, '.'::text))::numeric
            ELSE NULL::numeric
        END AS listed_price
   FROM staging.catalogue_prices_raw;

-- Dump line 120; object analytics.catalogue_price_comparison_exact
CREATE VIEW analytics.catalogue_price_comparison_exact AS
 WITH prepared AS (
         SELECT catalogue_prices_clean.catalogue_record_id,
            catalogue_prices_clean.catalogue_version,
            catalogue_prices_clean.effective_date,
            catalogue_prices_clean.catalogue_row_number,
            catalogue_prices_clean.item_description,
            catalogue_prices_clean.price_raw,
            catalogue_prices_clean.selling_unit,
            catalogue_prices_clean.source_file,
            catalogue_prices_clean.price_status,
            catalogue_prices_clean.listed_price,
            lower(regexp_replace(btrim(catalogue_prices_clean.item_description), '\s+'::text, ' '::text, 'g'::text)) AS description_key
           FROM core.catalogue_prices_clean
        ), prices_2025 AS (
         SELECT prepared.catalogue_record_id,
            prepared.catalogue_version,
            prepared.effective_date,
            prepared.catalogue_row_number,
            prepared.item_description,
            prepared.price_raw,
            prepared.selling_unit,
            prepared.source_file,
            prepared.price_status,
            prepared.listed_price,
            prepared.description_key
           FROM prepared
          WHERE (prepared.catalogue_version = '2025'::text)
        ), prices_2026 AS (
         SELECT prepared.catalogue_record_id,
            prepared.catalogue_version,
            prepared.effective_date,
            prepared.catalogue_row_number,
            prepared.item_description,
            prepared.price_raw,
            prepared.selling_unit,
            prepared.source_file,
            prepared.price_status,
            prepared.listed_price,
            prepared.description_key
           FROM prepared
          WHERE (prepared.catalogue_version = '2026'::text)
        )
 SELECT p25.item_description,
    p25.catalogue_row_number AS row_number_2025,
    p26.catalogue_row_number AS row_number_2026,
    p25.price_raw AS price_2025_raw,
    p26.price_raw AS price_2026_raw,
    p25.price_status AS price_2025_status,
    p26.price_status AS price_2026_status,
    p25.listed_price AS listed_price_2025,
    p26.listed_price AS listed_price_2026,
        CASE
            WHEN ((p25.listed_price IS NOT NULL) AND (p26.listed_price IS NOT NULL)) THEN (p26.listed_price - p25.listed_price)
            ELSE NULL::numeric
        END AS listed_price_change,
        CASE
            WHEN ((p25.listed_price IS NOT NULL) AND (p26.listed_price IS NOT NULL) AND (p25.listed_price <> (0)::numeric)) THEN round((((p26.listed_price - p25.listed_price) / p25.listed_price) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS price_change_percent,
    'exact_description'::text AS match_method
   FROM (prices_2025 p25
     JOIN prices_2026 p26 ON ((p25.description_key = p26.description_key)));

-- Dump line 190; object analytics.catalogue_price_change_analysis
CREATE VIEW analytics.catalogue_price_change_analysis AS
 SELECT item_description,
    row_number_2025,
    row_number_2026,
    price_2025_raw,
    price_2026_raw,
    price_2025_status,
    price_2026_status,
    listed_price_2025,
    listed_price_2026,
    listed_price_change,
    price_change_percent,
    match_method,
        CASE
            WHEN ((listed_price_2025 IS NULL) OR (listed_price_2026 IS NULL)) THEN 'not_comparable'::text
            WHEN (listed_price_2026 > listed_price_2025) THEN 'increased'::text
            WHEN (listed_price_2026 < listed_price_2025) THEN 'decreased'::text
            ELSE 'unchanged'::text
        END AS price_change_direction
   FROM analytics.catalogue_price_comparison_exact;

-- Dump line 217; object analytics.catalogue_kpis
CREATE VIEW analytics.catalogue_kpis AS
 SELECT count(*) AS exact_matches,
    count(*) FILTER (WHERE (price_change_direction <> 'not_comparable'::text)) AS comparable_products,
    count(*) FILTER (WHERE (price_change_direction = 'increased'::text)) AS price_increases,
    count(*) FILTER (WHERE (price_change_direction = 'decreased'::text)) AS price_decreases,
    count(*) FILTER (WHERE (price_change_direction = 'unchanged'::text)) AS unchanged_prices,
    count(*) FILTER (WHERE (price_change_direction = 'not_comparable'::text)) AS not_comparable,
    round(avg(price_change_percent) FILTER (WHERE (price_change_direction <> 'not_comparable'::text)), 2) AS average_price_change_percent,
    round((percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((price_change_percent)::double precision)) FILTER (WHERE (price_change_direction <> 'not_comparable'::text)))::numeric, 2) AS median_price_change_percent
   FROM analytics.catalogue_price_change_analysis;

-- Dump line 234; object analytics.catalogue_unmatched_review
CREATE VIEW analytics.catalogue_unmatched_review AS
 WITH prepared AS (
         SELECT catalogue_prices_clean.catalogue_record_id,
            catalogue_prices_clean.catalogue_version,
            catalogue_prices_clean.effective_date,
            catalogue_prices_clean.catalogue_row_number,
            catalogue_prices_clean.item_description,
            catalogue_prices_clean.price_raw,
            catalogue_prices_clean.selling_unit,
            catalogue_prices_clean.source_file,
            catalogue_prices_clean.price_status,
            catalogue_prices_clean.listed_price,
            lower(regexp_replace(btrim(catalogue_prices_clean.item_description), '\s+'::text, ' '::text, 'g'::text)) AS description_key
           FROM core.catalogue_prices_clean
        )
 SELECT catalogue_version,
    catalogue_row_number,
    item_description,
    price_raw,
    price_status,
    listed_price,
    selling_unit,
    source_file,
    'needs_manual_review'::text AS review_status
   FROM prepared p
  WHERE (NOT (EXISTS ( SELECT 1
           FROM prepared other
          WHERE ((other.catalogue_version <> p.catalogue_version) AND (other.description_key = p.description_key)))));

-- Dump line 269; object analytics.catalogue_match_candidates
CREATE VIEW analytics.catalogue_match_candidates AS
 WITH unmatched_2025 AS (
         SELECT catalogue_unmatched_review.catalogue_version,
            catalogue_unmatched_review.catalogue_row_number,
            catalogue_unmatched_review.item_description,
            catalogue_unmatched_review.price_raw,
            catalogue_unmatched_review.price_status,
            catalogue_unmatched_review.listed_price,
            catalogue_unmatched_review.selling_unit,
            catalogue_unmatched_review.source_file,
            catalogue_unmatched_review.review_status
           FROM analytics.catalogue_unmatched_review
          WHERE (catalogue_unmatched_review.catalogue_version = '2025'::text)
        ), unmatched_2026 AS (
         SELECT catalogue_unmatched_review.catalogue_version,
            catalogue_unmatched_review.catalogue_row_number,
            catalogue_unmatched_review.item_description,
            catalogue_unmatched_review.price_raw,
            catalogue_unmatched_review.price_status,
            catalogue_unmatched_review.listed_price,
            catalogue_unmatched_review.selling_unit,
            catalogue_unmatched_review.source_file,
            catalogue_unmatched_review.review_status
           FROM analytics.catalogue_unmatched_review
          WHERE (catalogue_unmatched_review.catalogue_version = '2026'::text)
        ), candidates AS (
         SELECT old.catalogue_row_number AS row_number_2025,
            old.item_description AS description_2025,
            old.price_raw AS price_2025_raw,
            suggested.catalogue_row_number AS row_number_2026,
            suggested.item_description AS description_2026,
            suggested.price_raw AS price_2026_raw,
            suggested.similarity_score
           FROM (unmatched_2025 old
             CROSS JOIN LATERAL ( SELECT new.catalogue_row_number,
                    new.item_description,
                    new.price_raw,
                    public.similarity(lower(old.item_description), lower(new.item_description)) AS similarity_score
                   FROM unmatched_2026 new
                  ORDER BY (public.similarity(lower(old.item_description), lower(new.item_description))) DESC
                 LIMIT 3) suggested)
        )
 SELECT row_number_2025,
    description_2025,
    price_2025_raw,
    row_number_2026,
    description_2026,
    price_2026_raw,
    similarity_score,
    row_number() OVER (PARTITION BY row_number_2025 ORDER BY similarity_score DESC) AS candidate_rank
   FROM candidates;
