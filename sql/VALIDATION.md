# Package validation — 8 November 2026

Validation was entirely offline. No PostgreSQL connection, SQL execution, restore or data import was performed.

| Check | Result |
|---|---|
| Source archive integrity | ZIP CRC check passed. |
| Original evidence preservation | Three original files match ZIP member bytes exactly; original ZIP retained and SHA-256 recorded. |
| Definition coverage | All 30 selected CREATE/ALTER statements match the dump after line-ending normalisation: 3 schemas, 1 extension, 4 tables, 13 views, 3 identities and 6 ALTER constraints. The table-level date CHECK remains in its CREATE statement. |
| Duplicate review definitions | Both singular/plural pairs have identical SELECT bodies. Both versions preserved. |
| Chat inventory | All 124 SQL blocks across 45 messages indexed with hashes and source message IDs. |
| Selected recovered blocks | 35 selected blocks match original SQL, allowing only the three documented COPY-path replacements and surrounding whitespace. |
| Reporting lineage | All five recovered export queries reference views present in the dump. |
| Local paths / repair commands | No original user paths, connection URLs, passwords, or active DELETE/TRUNCATE/UPDATE/role/grant/reload commands in the selected SQL files. Historical repair excerpts are fenced in Markdown. |
| Documentation links | 12 local documentation links resolve. Root README retains four links to the existing repository PBIX/screenshots, which are not repeated in this SQL update package. |

These checks establish file integrity, traceability and extraction consistency. They are not PostgreSQL syntax validation, query-result testing, data reconciliation against current database rows, or a tested end-to-end rebuild. The reconstructed SELECTs remain unexecuted. Prepared staging input CSVs are not supplied.

The earlier CSV/dashboard checks remain historical project evidence, not results of this packaging run. Publication suitability was reviewed for this selected code/documentation package only; raw chat evidence is retained privately.
