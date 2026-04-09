# Power BI Setup Guide
## Nigerian Retail Sales Dashboard

This guide documents exactly how to recreate the Power BI dashboard
from the raw Excel file. Useful for anyone reviewing this project
or for your own reference when building on new data.

---

## Step 1: Load the Data

1. Open Power BI Desktop
2. **Home → Get Data → Excel Workbook**
3. Navigate to `data/retail_sales_cleaned.xlsx`
4. Select the sheet → click **Load**

---

## Step 2: Transform in Power Query

Open **Transform Data** and apply these steps:

| Step | Action |
|---|---|
| Rename column | `margin_%` → `Margin_Pct` |
| Change type | `date` column → **Date** (not DateTime) |
| Add column | `Month` = `Date.ToText([date], "MMM YYYY")` |
| Add column | `Month_Sort` = `Date.ToText([date], "YYYY-MM")` (for correct sorting) |
| Add column | `Margin_Pct_Display` = `[margin_%] * 100` (stored as decimal, display as %) |
| Close & Apply | |

---

## Step 3: DAX Measures

Create a dedicated **Measures** table (right-click canvas → Enter Data, name it "Measures", blank table).

Paste each measure below into the formula bar:

```dax
-- ── Core KPIs ──────────────────────────────────────────────

Total Revenue =
SUM(retail_sales[revenue])

Total Profit =
SUM(retail_sales[profit])

Total Transactions =
COUNTROWS(retail_sales)

Total Units Sold =
SUM(retail_sales[quantity])

Overall Margin % =
DIVIDE(SUM(retail_sales[profit]), SUM(retail_sales[revenue]))

Avg Order Value =
DIVIDE([Total Revenue], [Total Transactions])


-- ── Month-on-Month Growth ──────────────────────────────────

Revenue MoM % =
VAR CurrentMonth = [Total Revenue]
VAR PreviousMonth =
    CALCULATE(
        [Total Revenue],
        DATEADD(retail_sales[date], -1, MONTH)
    )
RETURN
    DIVIDE(CurrentMonth - PreviousMonth, PreviousMonth)


-- ── Branch Analysis ────────────────────────────────────────

Branch Revenue Share % =
DIVIDE(
    [Total Revenue],
    CALCULATE([Total Revenue], ALL(retail_sales[branch]))
)

Branch vs Average =
VAR BranchRev  = [Total Revenue]
VAR AvgBranchRev =
    AVERAGEX(
        VALUES(retail_sales[branch]),
        CALCULATE([Total Revenue])
    )
RETURN BranchRev - AvgBranchRev


-- ── Product Analysis ───────────────────────────────────────

Product Revenue Rank =
RANKX(
    ALL(retail_sales[product_name]),
    [Total Revenue],
    ,
    DESC,
    DENSE
)

Avg Margin % =
AVERAGE(retail_sales[margin_%])

Margin % (formatted) =
FORMAT([Overall Margin %], "0.0%")


-- ── Running Total ──────────────────────────────────────────

Cumulative Revenue =
CALCULATE(
    [Total Revenue],
    FILTER(
        ALL(retail_sales[date]),
        retail_sales[date] <= MAX(retail_sales[date])
    )
)
```

---

## Step 4: Dashboard Layout

Build 4 report pages:

### Page 1 — Executive Summary
| Visual | Fields | Notes |
|---|---|---|
| Card | Total Revenue | Format: ₦#,##0,, "M" |
| Card | Total Profit | Format: ₦#,##0,, "M" |
| Card | Overall Margin % | Format: 0.0% |
| Card | Total Transactions | |
| Line chart | Axis: Month_Sort, Values: Total Revenue + Total Profit | Sort axis by Month_Sort |
| Donut chart | Legend: category, Values: Total Revenue | |

### Page 2 — Branch Deep-Dive
| Visual | Fields | Notes |
|---|---|---|
| Clustered bar | Axis: branch, Values: Total Revenue + Total Profit | |
| Matrix | Rows: branch, Columns: Month, Values: Total Revenue | Conditional formatting on values |
| Card | Branch vs Average | Use with branch slicer |
| Slicer | branch | Single select |

### Page 3 — Product & Category Analysis
| Visual | Fields | Notes |
|---|---|---|
| Clustered bar | Axis: product_name, Values: Total Revenue | Sort desc by value |
| Scatter chart | X: Total Revenue, Y: Avg Margin %, Size: Total Profit, Legend: category | The opportunity matrix |
| Table | product_name, category, Total Revenue, Total Profit, Avg Margin % | Conditional formatting |
| Slicer | category | |

### Page 4 — Trend & Cumulative
| Visual | Fields | Notes |
|---|---|---|
| Area chart | Axis: Month_Sort, Values: Cumulative Revenue | |
| Waterfall | Category: Month_Sort, Breakdown: Total Revenue | Shows MoM changes |
| Line + clustered column | Shared axis: Month_Sort, Column: Total Revenue, Line: Overall Margin % | Combo chart |

---

## Step 5: Formatting Standards

Apply these consistently across all pages:

```
Background colour : #0F172A  (dark navy)
Card background   : #1E293B
Accent colour 1   : #38BDF8  (blue  — Lekki / Revenue)
Accent colour 2   : #818CF8  (indigo — Ikeja / Profit)
Accent colour 3   : #34D399  (green  — Yaba / Positive)
Accent colour 4   : #FB923C  (orange — warnings / averages)
Text colour       : #F1F5F9
Font              : Segoe UI (Power BI default)
```

---

## Step 6: Export

- Save as `powerbi/retail_sales_dashboard.pbix`
- Export PDF: **File → Export → Export to PDF**
- Save PDF as `powerbi/retail_sales_dashboard.pdf`
- Take a screenshot of Page 1 and save as `visuals/powerbi_dashboard_preview.png`
  (so recruiters see it without needing Power BI installed)

---

## Notes for Reviewers

The Python visualizations in `visuals/` mirror the same charts built in Power BI.
The SQL queries in `sql/retail_sales_analysis.sql` produce the same aggregations
as the DAX measures above. All three tools — SQL, Python, Power BI — are telling
the same analytical story, just in different environments.

This is intentional: it demonstrates that the analysis logic is tool-agnostic.
The ability to replicate insights across SQL, Python, and Power BI is a core
skill for a data analyst working across different team environments.
