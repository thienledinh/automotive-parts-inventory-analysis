# Provenance and reconciliation decisions

Prepared 8 November 2026 from the user's evidence archive. The archive's README was read first. No live database was accessed.

## Sources

| Source | Role | Preservation |
|---|---|---|
| `project_sql_proof_terminal.sql` | Authoritative snapshot of exported schema definitions on November 8. | Original bytes retained privately; 30 CREATE/ALTER statements extracted into public definition files. |
| `recovered_chat_queries.md` | 45 original assistant messages containing 124 SQL blocks from September 14–October 26. | Entire file retained privately; selected blocks extracted with message/date references; all blocks indexed. |
| Original `README.md` | Evidence boundaries and recovered workflow map supplied with the archive. | Preserved unchanged privately. |

SHA-256 hashes in `evidence_index.json` identify the original files. SQL-block and statement hashes use UTF-8 with LF line endings; original-file hashes use the exact supplied bytes. The private archive is the place to inspect full surrounding messages, not a file to publish or run blindly.

## Important comparisons

| Topic | Earlier history | Exported state / portfolio decision |
|---|---|---|
| Early catalogue model | Q002/Q009 proposed product-code catalogue prices and `core.price_history`. | Neither table exists in the dump. Current catalogue input is description-based `staging.catalogue_prices_raw` (Q069). Earlier objects remain historical proposals. |
| Inventory staging | Q003 omitted warehouse and used an earlier column order. | Q015 matches the current 19-column staging design. Current definitions come from the dump. |
| Product master | Q008 included `product_group`. | Q034 and the dump have product ID, code, name and unit only. |
| Inventory grain | Q010 used an earlier period key and two-decimal average costs. | Q038/dump use product + warehouse + both period dates; average costs have four decimals. |
| Inventory number conversion | Q039 directly cast numeric text; subsequent message describes a separator-related failure. | Q043 removes comma thousands separators before casting. Selected unchanged as recovered correction, not retroactively presented as the first version. |
| Missing values | Q049 proposed converting quantity/value NULLs to zero. | Dump cannot show whether this update ran or justify blank semantics. Update is preserved in history only. Previously checked non-null CSVs are consistent with, but do not prove, this execution path. |
| Review view names | Q056/Q064 create singular no-movement review; Q059 creates singular zero-closing review. | Both singular and plural pairs exist with identical bodies in the dump. No recovered plural CREATE is claimed; all four are retained. |
| Inventory ABC | Q066 provides CTEs, cumulative windows and CASE thresholds. | Dump confirms rounding before ≤80/≤95 classification, positive values only, product-code tiebreaker and ROWS frame. |
| Catalogue views | Q091/Q095/Q097/Q101/Q103/Q106 contain cleaning, matching and KPI logic. | Corresponding views exist in the dump. pg_dump adds casts, schema qualification and expands `*`; public current SQL uses the dump verbatim. No byte-for-byte match to original CREATE text is claimed. |
| Read-only connection setup | Q111–Q119 propose diagnostics, role/grants and configuration steps. | No need for the CSV workflow. Global role/network state is not established by this schema-only dump; not included in selected SQL. |
| Reporting exports | Q120–Q124 select the five named reporting views. | All referenced views exist in the dump. Queries retained; no new exports or source-data replay performed. |

## Editorial and reconstructed changes

1. **Definition extraction:** Kept SQL statement bodies from the dump; added provenance headers and grouped by subject. Omitted the dump session SET commands, TOC comments, extension COMMENT and psql restrict/unrestrict wrapper from the reading copies. All remain in the private original dump. The grouped files are not a byte-for-byte full restore script.
2. **Import paths:** Replaced historical local paths in Q025/Q085/Q086 with `/REPLACE_WITH_SERVER_PATH/...`. The incomplete Q083 illustration has its account path redacted in the public historical excerpt. No other business logic changed in selected recovered statements.
3. **Selection:** Removed repeated checks from the reading files but indexed every original SQL block. Historical/admin statements are separated from the selected workflow. Local machine paths and network setup prose remain private.
4. **New validation:** `validation/reconstructed_completeness_checks.sql` was written for this portfolio on November 8. It makes both quantity/value completeness visible, groups by warehouse/period, and distinguishes numeric price pairs from defined percentage observations. These are new checks, not recovered historical steps or changes to current views.
5. **Repository documentation:** The proposed root README update identifies SQL-to-CSV lineage and replaces the former uncertainty about ABC threshold inclusivity with the rule now established by the dump. Existing dashboard results are retained; they were not recomputed from the database here.

## Historical caveats retained

The archive includes claims such as “fully validated”, “genuine price changes” and “confidently matched”. Those are original assistant statements, not new conclusions. This package uses narrower claims: internal export consistency, numeric price comparisons and description-match candidates. Original source data, business confirmation, query execution logs and a disposable-database replay are not included.
