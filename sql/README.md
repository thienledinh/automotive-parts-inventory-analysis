# PostgreSQL inventory and catalogue analysis

This folder documents the SQL behind the project's inventory and catalogue reporting exports. It combines current database definitions exported on **8 November 2026** with SQL recovered from the original project chat. It is a portfolio reference, **not a tested migration or a one-click pipeline**.

No connection to the working database was made, and no SQL was executed while assembling this folder. There are no business-data rows or original input CSVs in this package.

## Start here

For a short technical review, read:

1. [Inventory views](definitions/02_inventory_views.sql): joins, CASE classification, filtered KPI aggregates, cumulative ABC calculation and ranked review lists.
2. [Catalogue views](definitions/03_catalogue_views.sql): regex price classification, description normalisation, exact matching, anti-joins, LATERAL trigram candidates and price-change KPIs.
3. [Reporting exports](exports/reporting_exports.sql): the five recovered SELECT queries used in the CSV-transfer workflow.
4. [Provenance and decisions](PROVENANCE.md): what is implemented, what is historical, and what was reconstructed.

## Evidence labels

| Label | What it establishes |
|---|---|
| **Current exported definition** | The object definition is present in the supplied schema-only pg_dump. SQL bodies are extracted unchanged apart from line endings. It does not prove when or by whom the object was first created. |
| **Recovered chat SQL** | The query appeared in an original assistant message. It is not an execution log or proof of independent authorship. |
| **Adapted for portability** | A recovered COPY statement has its historical local path replaced with a clearly marked placeholder. Its SQL logic is otherwise unchanged. |
| **Reconstructed validation** | A newly written, read-only check addresses a documented gap. It is not presented as original project history and has not been executed here. |
| **Historical proposal/troubleshooting** | Earlier designs, fragments, repairs or administration advice; excluded from the selected workflow. |

The original handover, full chat archive, full dump and source ZIP are preserved byte-for-byte in a separate local `private_original_evidence` folder. They are deliberately outside this GitHub upload package. [evidence_index.json](evidence_index.json) records source hashes, dump line references, message IDs, all 124 SQL-block references and their disposition.

## Folder guide

```text
sql/
├── README.md
├── PROVENANCE.md
├── VALIDATION.md
├── evidence_index.json
├── definitions/
│   ├── 01_schemas_tables_constraints.sql
│   ├── 02_inventory_views.sql
│   └── 03_catalogue_views.sql
├── recovered/
│   ├── imports.sql
│   └── inventory_population.sql
├── validation/
│   ├── recovered_checks.sql
│   └── reconstructed_completeness_checks.sql
├── exports/
│   └── reporting_exports.sql
└── history/
    ├── chat_block_index.md
    └── earlier_proposals_and_troubleshooting.md
```

Numbers on definition files provide a reading/dependency order only. They do not imply these files can be replayed safely against an existing database. CREATE/ALTER, COPY and INSERT statements change database state. The historical DELETE, TRUNCATE and null-to-zero UPDATE appear only as non-runnable Markdown excerpts. There is no execution wrapper or automatic database connection.

## Implemented model

The dump reports PostgreSQL/pg_dump version 18.6. It contains **three project schemas, four tables and thirteen views**, together with `pg_trgm`, identity columns and integrity constraints.

| Layer | Objects and purpose |
|---|---|
| `staging` | `inventory_summary` retains inventory input fields as text; `catalogue_prices_raw` retains raw descriptions/prices and source metadata. |
| `core` | `products` provides a product master; `inventory_period` stores typed balances linked by product ID; `catalogue_prices_clean` interprets price text through a view. |
| `analytics` | Seven inventory views and five catalogue views provide classifications, ranked reviews, comparisons and reporting aggregates. |

The thirteen-view total includes the core cleaning view and both singular/plural inventory review pairs. In the dump, `no_movement_review` and `no_movement_reviews` have identical SELECT bodies; so do `zero_closing_review` and `zero_closing_reviews`. Both pairs are retained as exported rather than silently removed.

Inventory uniqueness is defined by **product ID + warehouse + period start + period end**, with a foreign key to `core.products` and a date-order CHECK constraint. Several reporting views count records as products or omit warehouse/period. The current single-warehouse, single-period reporting assumptions must be revisited before expanding the data.

## Recovered preparation workflow

The selected history describes a prepared-CSV → staging → core → analytics → reporting-CSV workflow:

- Server-side `COPY` imports prepared inventory and catalogue files. The original input files are not included; the reporting CSVs are not interchangeable with them.
- `INSERT ... SELECT DISTINCT` standardises product codes with `UPPER/TRIM`, converts blank units with `NULLIF`, and uses `ON CONFLICT DO NOTHING`.
- The corrected inventory population query joins standardised product codes, removes comma thousands separators, casts numbers/dates, and preserves blank numeric fields as NULL.
- Inventory and catalogue views supply the five reporting SELECTs.

The date/version values are supplied by the prepared inputs; COPY does not independently validate that a file named for a catalogue year contains that year's data. A source labelled 2026 despite a 2025 filename requires source-content confirmation.

`ON CONFLICT DO NOTHING` avoids insertion for existing keys but does not update revised facts or resolve competing descriptions. The inventory inner join can omit rows with no product match. These are properties of the recovered code, not claims of complete production-grade import handling.

## How the CSV exports connect to Power BI

The original October 26 SELECTs are retained in [reporting_exports.sql](exports/reporting_exports.sql). These select result sets; CSV saving was a separate database-client operation, not a SQL `COPY TO` script.

| Export file | PostgreSQL view | Use in the delivered dashboard |
|---|---|---|
| `inventory_status.csv` | `analytics.inventory_status` | Main inventory detail. |
| `inventory_abc.csv` | `analytics.inventory_abc` | ABC labels merged into inventory detail in Power Query. |
| `inventory_kpis.csv` | `analytics.inventory_kpis` | Reconciliation/control reference; interactive cards are calculated from detail in DAX. |
| `catalogue_price_change_analysis.csv` | `analytics.catalogue_price_change_analysis` | Separate catalogue SQL analysis; not included in the three inventory dashboard pages. |
| `catalogue_kpis.csv` | `analytics.catalogue_kpis` | Catalogue control/reference export; not included in the three inventory dashboard pages. |

The recovered workflow and supplied CSV names establish lineage, but this packaging task did not regenerate the CSVs from the current database. The dump is dated after the exports and contains definitions, not rows or execution history.

## Interpretation that matters

- **ABC:** Only positive closing values are included. Cumulative value uses descending closing value, then product code, with a ROWS window frame. Percentages are rounded to two decimals **before** classification: A ≤80, B ≤95, C otherwise. Percentage columns use a 0–100 scale. The database view recalculates when queried; the CSV-derived class stays fixed within the saved Power BI snapshot.
- **Null handling:** The recovered September 24 UPDATE replaces missing quantities/values with zero, leaving average costs unchanged. Its existence is established; the correctness of that assumption is not. It is retained as history, not endorsed as an automatic cleaning step.
- **Reconciliation:** NULL arithmetic can omit incomplete records from exception counts. The reconstructed check separately counts missing quantities and missing values. Historical SQL uses a tolerance greater than 0.01; it is not identical to an exact-balance check of CSV exports.
- **Units and movements:** Do not interpret mixed-unit quantity sums as one homogeneous stock total. Issues are warehouse outflows, not necessarily sales. No movement does not prove obsolete stock, and zero closing does not prove unmet demand.
- **Catalogue parsing:** The implemented regex accepts one digit sequence with an optional comma or dot separator and treats comma as decimal. It does not establish currency scale, pack size or universal locale correctness. No automatic multiplication by 1,000 is applied.
- **Matching:** Normalised descriptions are matching keys, not verified common product IDs. Duplicate descriptions could multiply exact-join rows. `pg_trgm` candidates are suggestions, not approved matches; tied similarities have no explicit deterministic tiebreaker in the exported view.
- **Price KPIs:** “Comparable” means both prices parsed numerically, not commercially equivalent products/units. A zero base price can be counted as a numeric pair while its percentage is NULL and excluded from AVG/median.

## What this supports in a portfolio

The exported definitions demonstrate PostgreSQL relational modelling, joins, CTEs, CASE expressions, regex transformations, filtered aggregates, window functions, `NOT EXISTS`, `LATERAL`, `pg_trgm` and ordered-set median calculation. Recovered messages additionally document proposed import and population logic, profiling and troubleshooting.

The history is explicitly assistant-generated guidance used in project development. It supports an AI-assisted SQL workflow, not a claim that every query was independently authored or executed exactly as shown. No end-to-end reproducibility, performance benchmark or production deployment is claimed.
