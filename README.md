# Automotive Parts Inventory Analysis | Power BI

A three-page Power BI report for reviewing inventory value, identifying products that need attention, and understanding stock concentration and warehouse outflows.

**Reporting period:** 1 January–8 September 2026  
**Coverage:** 191 products in one recorded warehouse  
**Currency:** Vietnamese dong (VND), displayed in full amounts

**Main finding:** Closing inventory value increased by **293,621,312 VND (14.6%)** during the period. At period end, **721,243,300 VND (31.4%)** was held in 75 products with no recorded issues. These products form a review list; the data does not establish that they are obsolete or unnecessary.

[Open or download the Power BI report](Inventory%20Dashboard.pbix)

## Business problem

An inventory balance shows how much stock is recorded, but it does not explain which products deserve attention first. This project combines stock value, warehouse movement and ABC classification to help an inventory manager answer:

1. How did inventory value change between the opening and closing balances?
2. Which products hold substantial value with little or no recorded outflow?
3. How concentrated is closing inventory value across products?
4. Which products ended with zero stock after recording issues?

The intended outcome is a prioritised starting point for purchasing and stock review. Recommendations are proposed actions, not measured business results.

## Dashboard pages

| Page | Main question | Main visuals and interactions |
|---|---|---|
| **Inventory Change** | What explains the change in recorded inventory value? | KPI cards, a waterfall showing net value change by movement status, and product rankings for increases and decreases. |
| **Review Priorities** | Where should stock review begin? | Cards for stock with no issues, a product scatter plot of closing value against the share of available quantity issued, ABC columns split by movement status, a no-issue product ranking, and explanatory notes. |
| **Concentration & Issues** | How concentrated is stock value, and how do issues relate to ending stock? | Concentration KPIs, a Pareto chart, an issued-value pie split by closing-stock position, and the ten largest issued values. |

A hidden **Product Detail** page supports product-level drill-through. It presents the selected product's identity, unit, movement status, quantities and monetary values.

The report uses chart selections, filters and tooltips to connect the portfolio view with individual products. Monetary amounts remain in full VND. Product quantities are shown in their recorded units rather than combined into an ambiguous portfolio total.

### Inventory Change

![Inventory Change dashboard showing opening and closing values, net change by movement status, and the largest product increases and decreases.](images/inventory-change.png)

### Review Priorities

![Review Priorities dashboard showing stock with no issues, product movement, ABC classes, and high-value products for review.](images/review-priorities.png)

### Concentration & Issues

![Concentration and Issues dashboard showing cumulative stock-value concentration, issued value by ending stock position, and the ten largest issued values.](images/concentration-and-issues.png)

## Key results

The figures below describe the full dataset before interactive filters are applied. Percentages are rounded independently.

| Metric | Result |
|---|---:|
| Products | 191 |
| Opening inventory value | 2,006,541,500 VND |
| Received inventory value | 1,048,296,500 VND |
| Issued inventory value | 754,675,188 VND |
| Closing inventory value | 2,300,162,812 VND |
| Net inventory value change | +293,621,312 VND |
| Change relative to opening value | +14.6% |
| Products with recorded issues | 116 |
| Products with recorded receipts | 42 |

### 1. Receipts exceeded issues, increasing recorded stock value

The opening-to-closing reconciliation is:

```text
Opening value     2,006,541,500 VND
+ Received value  1,048,296,500 VND
− Issued value      754,675,188 VND
= Closing value   2,300,162,812 VND
```

This explains the net increase arithmetically. It does not establish whether purchasing was excessive, because demand, purchase commitments and receipt timing are not available.

**Suggested action:** Review the largest product-level increases alongside purchase orders, expected demand and delivery timing before changing purchasing plans.

### 2. Almost one-third of closing value was held in products with no issues

**75 products** had positive closing stock and no recorded issues during the reporting period. Their combined closing value was **721,243,300 VND**, or **31.4%** of all closing value.

This group includes two different situations:

| Situation | Products | Closing value |
|---|---:|---:|
| No receipts or issues, with stock remaining | 53 | 279,248,000 VND |
| Receipts recorded, but no issues | 22 | 441,995,300 VND |
| **Total stock with no issues** | **75** | **721,243,300 VND** |

Within that group, **15 A-class products held 494,384,000 VND**. These are a practical starting point because they combine high closing value with no recorded outflow.

**Suggested action:** Validate expected demand, recent receipts, committed orders and product relevance for these 15 products first. Consider changes to purchasing only after that review. No issues during the period does not prove obsolescence.

### 3. A relatively small group accounts for most closing value

| ABC class | Products | Closing value | Share of closing value |
|---|---:|---:|---:|
| A | 54 | 1,828,357,649 VND | 79.49% |
| B | 51 | 354,820,239 VND | 15.43% |
| C | 60 | 116,984,924 VND | 5.09% |
| Not classified | 26 | 0 VND | 0.00% |
| **Total** | **191** | **2,300,162,812 VND** | **100.00%** |

The **ten largest products by closing value held 825,445,200 VND**, or **35.9%** of the total.

**Suggested action:** Use A-class products as a focus for value-based stock review and purchasing oversight. Combine this with operational criticality before deciding which products require the strongest service protection; high stock value alone does not measure importance to customers.

### 4. Products ending with zero stock account for over half of issued value

**26 products** ended with zero stock after recording issues. Their combined issued value was **395,263,800 VND**, or **52.4%** of total issued value.

The pie chart divides total issued value into two groups:

- Products with stock remaining at period end: **47.6%**.
- Products with zero stock at period end: **52.4%**.

It is a composition of warehouse outflow value grouped by the ending stock position. It is **not** the percentage of products that stocked out, a stockout rate, or a measure of lost sales.

**Suggested action:** Check subsequent demand, replenishment plans and supplier lead times for the zero-closing products. The snapshot does not reveal when stock ran out or whether any demand went unfulfilled.

## Data sources and scope

The project starts from five supplied CSV exports. The three dashboard pages focus on inventory; the catalogue files are a separate analytical scope.

| File | Rows | Role |
|---|---:|---|
| `inventory_status.csv` | 191 | Main inventory detail: opening, received, issued and closing quantities and values. |
| `inventory_abc.csv` | 165 | Precomputed ABC classes for products with positive closing value. |
| `inventory_kpis.csv` | 1 | Independent summary control used to validate the inventory detail. |
| `catalogue_price_change_analysis.csv` | 171 | Catalogue comparison export; not used in these inventory dashboard pages. |
| `catalogue_kpis.csv` | 1 | Catalogue summary export; not used in these inventory dashboard pages. |

Row counts exclude headers. The main inventory export has one row per product for the single warehouse and reporting period. Product code is unique in this snapshot.

The analysis validates the supplied exports and their internal consistency. It does not independently audit the original accounting system, physical stock or upstream transformations. Values are presented as VND following the supplied business context; the inventory valuation method has not been confirmed.

## Preparation and data model

1. Imported comma-delimited CSV data using UTF-8 to preserve Vietnamese product names.
2. Promoted headers and assigned explicit types: identifiers and descriptions as text, reporting boundaries as dates, quantities as numeric values, and monetary fields as fixed decimals.
3. Checked product identifiers, duplicates, completeness and inventory balances.
4. Left-joined ABC classification onto the main inventory table using `product_code`, preserving all 191 products.
5. Labelled the 26 products absent from the ABC export as **Not classified** after verifying that all had zero closing quantity and value.
6. Created DAX measures for reconciliation, review priorities, concentration and product-level detail.
7. Built and checked interactive visuals, tooltips and product drill-through.

The analytical model uses the enriched `inventory_status` table. The ABC export supplies classification through Power Query rather than adding a second copy of inventory balances to the visuals. The inventory KPI export is a validation reference, not the source of interactive totals.

The current product-code join is appropriate for this single snapshot. A multi-period or multi-warehouse version would require a revised grain and matching keys.

## Methodology and metric definitions

### What “issued” means

**Issued** means goods removed from the recorded warehouse stock during the reporting period—*xuất kho* in Vietnamese. An issue is not automatically a sale. Issued value should not be interpreted as revenue or cost of sales without confirming the underlying transaction and valuation definitions.

### Core calculations

| Metric | Definition |
|---|---|
| Closing inventory value | Sum of recorded `closing_value`. |
| Net inventory value change | Closing value minus opening value. |
| Inventory value change % | Net value change divided by opening value. |
| Products with issues | Distinct product codes with `issued_quantity > 0`. |
| Products with receipts | Distinct product codes with `received_quantity > 0`. |
| Stock value with no issues | Closing value for products with `issued_quantity = 0` and `closing_quantity > 0`. |
| No-issue value share | Stock value with no issues divided by total closing value in the current filter context. |
| Share of available quantity issued | For one product: issued quantity divided by opening quantity plus received quantity. |
| Top-ten closing value share | Closing value of the ten highest-value products divided by closing value in the selected population. |
| Issued-value share from zero-closing products | Issued value for products with zero closing quantity and positive issued quantity, divided by total issued value. |

The quantity-issued share is calculated at product level. It is not a time-based turnover measure or a sales conversion rate. Quantities across different units—such as pieces, pairs and boxes—are not added together for portfolio interpretation.

### ABC classification

ABC groups products by their contribution to **closing inventory value**:

- **A:** Highest-value products, together accounting for approximately 80% of total closing value.
- **B:** The next group, accounting for approximately 15%.
- **C:** The remaining positive-value products, accounting for approximately 5%.
- **Not classified:** Products with zero closing value in this snapshot.

The project retains the classes supplied in `inventory_abc.csv`. The export was checked against descending closing value and cumulative contributions. Observed classes are consistent with thresholds around 80% and 95%; exact upstream boundary and tie-handling rules cannot be established from the export alone.

Whole products cross percentage boundaries, so actual class shares do not equal exactly 80%, 15% and 5%. Classes remain fixed for the full reporting snapshot when users filter the dashboard. Measures and visual shares respond to selections; the imported class assignments do not recalculate.

This is a closing-value classification, not an ABC analysis of annual consumption, profitability or demand criticality.

### Movement status and ranking

The supplied movement categories distinguish issued-without-receipt, no-movement stock, received-and-issued, received-without-issue, and zero-closing-after-issue products. The zero-closing category identifies a specific ending position even when receipts also occurred during the period.

The Pareto chart orders positive-closing-value products and shows cumulative value concentration. Product-code ordering resolves equal-value ranks in the dashboard. Top-ten issued values are ranked across both closing-stock color groups together, rather than selecting ten independently from each group.

## Selected DAX measures

These examples illustrate the measures used in the report. The complete model and measures are available in the PBIX.

```dax
Closing Inventory Value =
SUM(inventory_status[closing_value])

Inventory Value Change =
[Closing Inventory Value] - [Opening Inventory Value]

Inventory Value Change % =
DIVIDE([Inventory Value Change], [Opening Inventory Value])
```

```dax
Value with No Issues =
COALESCE(
    CALCULATE(
        [Closing Inventory Value],
        KEEPFILTERS(inventory_status[issued_quantity] = 0),
        KEEPFILTERS(inventory_status[closing_quantity] > 0)
    ),
    0
)

Share of Available Quantity Issued =
IF(
    HASONEVALUE(inventory_status[product_code]),
    DIVIDE(
        SUM(inventory_status[issued_quantity]),
        SUM(inventory_status[opening_quantity])
            + SUM(inventory_status[received_quantity])
    )
)
```

## Validation performed

| Check | Result |
|---|---|
| Inventory identifiers | 191 unique product codes; product IDs also unique. |
| Inventory numeric completeness | All quantity and value fields populated in the supplied snapshot. |
| Negative inventory quantities or values | None found in the supplied inventory detail. |
| Quantity reconciliation | Opening + received − issued = closing for all 191 products. |
| Value reconciliation | Opening + received − issued = closing for all 191 products. |
| Inventory KPI controls | All nine exported KPI results agree with the detail. |
| ABC coverage | 165 classified products; the 26 omitted products all have zero closing quantity and value. |
| ABC value preservation | Classified products retain the full 2,300,162,812 VND closing value. |
| Report interactions | Checked chart selections and tooltips; product drill-through tested during report development. |
| Issued ranking | Verified ten products after ranking across both closing-stock groups. |

For example, selecting the A-class / Received without issue segment returns **9 products**, **354,564,000 VND** closing value, **331,884,000 VND** receipts and zero issued value. Its closing value represents **19.4%** of A-class value before other filters.

These checks establish consistency within the exports. They do not prove that source-system records are complete or that any upstream conversion of blanks to zero was appropriate.

## How to use the report

1. Download `Inventory Dashboard Revised.pbix` and open it in Power BI Desktop.
2. Start with **Inventory Change** to understand the opening-to-closing reconciliation.
3. Move to **Review Priorities** to compare value, movement status and ABC class. Hover over products or ABC segments for additional context.
4. Select a chart category or use the available filters to explore a subset. Clear selections before comparing the displayed totals with this README.
5. Use **Concentration & Issues** to inspect the value distribution and products with the largest issued values.
6. On a product-level visual, right-click a product and use the available drill-through option to open **Product Detail**. In Desktop editing mode, use Ctrl+click on the Back control to return.

The hidden detail page is designed to receive a product filter. Opening its tab directly can show portfolio value totals and blank product quantities until one product is selected.

## Project outcome

The report provides a reconciled view of inventory value and a focused list of products for further review. Its main analytical contribution is combining financial concentration with recorded movement, while making clear which business conclusions require additional evidence. No inventory reduction, savings or service improvement is claimed as an implemented outcome.

## Repository files and data access

Keep `README.md` and `Inventory Dashboard Revised.pbix` together in the repository root for the report link above to work. The PBIX is the interactive deliverable; the README documents its scope, methods and interpretation. Raw CSV exports are not required to view the saved snapshot, but authorised access to them is needed for refresh.

The PBIX contains imported product-level data. Redistribution of the report and source files is subject to the data owner's permission; this documentation does not grant a licence to the underlying business data.
