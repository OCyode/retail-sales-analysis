-- ============================================================
--  NIGERIAN RETAIL SALES ANALYSIS — Jan to Jun 2025
--  Author : Data Analyst Portfolio Project
--  Engine : SQLite / PostgreSQL / MySQL compatible
--  Dataset: 294 transactions | 3 Lagos branches | 9 products
-- ============================================================


-- ============================================================
-- SECTION 0: TABLE SETUP
-- (Skip if loading from Excel directly into your SQL client)
-- ============================================================

CREATE TABLE IF NOT EXISTS retail_sales (
    transaction_id  INTEGER,
    date            DATE,
    branch          TEXT,
    product_name    TEXT,
    category        TEXT,
    quantity        INTEGER,
    unit_price      INTEGER,
    unit_cost       INTEGER,
    revenue         INTEGER,
    profit          INTEGER,
    margin_pct      REAL        -- stored as decimal e.g. 0.4286 = 42.86%
);


-- ============================================================
-- SECTION 1: DATA QUALITY CHECK
-- Always validate before analysing
-- ============================================================

-- 1a. Row count
SELECT COUNT(*) AS total_rows FROM retail_sales;
-- Expected: 294

-- 1b. Check for NULLs in every column
SELECT
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN date          IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN branch        IS NULL THEN 1 ELSE 0 END) AS null_branch,
    SUM(CASE WHEN product_name  IS NULL THEN 1 ELSE 0 END) AS null_product,
    SUM(CASE WHEN category      IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN quantity      IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN revenue       IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    SUM(CASE WHEN profit        IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM retail_sales;
-- Expected: all zeros (clean dataset)

-- 1c. Check for duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS occurrences
FROM retail_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;
-- Expected: no rows returned

-- 1d. Date range
SELECT
    MIN(date) AS first_transaction,
    MAX(date) AS last_transaction
FROM retail_sales;
-- Expected: 2025-01-01 to 2025-06-30

-- 1e. Distinct lookup values
SELECT DISTINCT branch    FROM retail_sales ORDER BY branch;
SELECT DISTINCT category  FROM retail_sales ORDER BY category;
SELECT DISTINCT product_name FROM retail_sales ORDER BY product_name;


-- ============================================================
-- SECTION 2: EXECUTIVE KPIs (Top-Line Summary)
-- ============================================================

SELECT
    COUNT(*)                                    AS total_transactions,
    SUM(revenue)                                AS total_revenue,
    SUM(profit)                                 AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 1) AS overall_margin_pct,
    ROUND(AVG(revenue), 0)                      AS avg_order_value,
    SUM(quantity)                               AS total_units_sold
FROM retail_sales;

/*
  Expected results (reference):
  total_transactions : 294
  total_revenue      : 200,537,000
  total_profit       : 31,959,600
  overall_margin_pct : 15.9%
  avg_order_value    : 682,099
  total_units_sold   : 3,421
*/


-- ============================================================
-- SECTION 3: MONTHLY TREND ANALYSIS
-- ============================================================

-- 3a. Revenue and profit by month
SELECT
    STRFTIME('%Y-%m', date)                       AS month,       -- SQLite
    -- TO_CHAR(date, 'YYYY-MM')                   AS month,       -- PostgreSQL
    -- DATE_FORMAT(date, '%Y-%m')                 AS month,       -- MySQL
    COUNT(*)                                      AS transactions,
    SUM(revenue)                                  AS monthly_revenue,
    SUM(profit)                                   AS monthly_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 1) AS margin_pct,
    SUM(quantity)                                 AS units_sold
FROM retail_sales
GROUP BY STRFTIME('%Y-%m', date)
ORDER BY month;

-- 3b. Month-over-month revenue change
WITH monthly AS (
    SELECT
        STRFTIME('%Y-%m', date)  AS month,
        SUM(revenue)             AS monthly_revenue
    FROM retail_sales
    GROUP BY STRFTIME('%Y-%m', date)
)
SELECT
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY month)   AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month)) * 100.0
        / LAG(monthly_revenue) OVER (ORDER BY month),
    1) AS mom_growth_pct
FROM monthly
ORDER BY month;

/*
  Key finding: Feb dipped -43.7% vs Jan; March surged +116.8% — 
  the largest single-month swing in the dataset. Worth investigating.
*/


-- ============================================================
-- SECTION 4: BRANCH PERFORMANCE
-- ============================================================

-- 4a. Full branch scorecard
SELECT
    branch,
    COUNT(*)                                        AS transactions,
    SUM(revenue)                                    AS total_revenue,
    SUM(profit)                                     AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 1)   AS margin_pct,
    ROUND(AVG(revenue), 0)                          AS avg_order_value,
    SUM(quantity)                                   AS units_sold,
    ROUND(SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM retail_sales), 1) AS revenue_share_pct
FROM retail_sales
GROUP BY branch
ORDER BY total_revenue DESC;

/*
  Lekki  : ₦74.3M (37.0%)
  Ikeja  : ₦74.2M (37.0%)
  Yaba   : ₦52.1M (26.0%)  ← underperforming vs peers
*/

-- 4b. Monthly revenue by branch (pivot-style)
SELECT
    STRFTIME('%Y-%m', date)              AS month,
    SUM(CASE WHEN branch = 'Lekki' THEN revenue ELSE 0 END) AS lekki_revenue,
    SUM(CASE WHEN branch = 'Ikeja' THEN revenue ELSE 0 END) AS ikeja_revenue,
    SUM(CASE WHEN branch = 'Yaba'  THEN revenue ELSE 0 END) AS yaba_revenue,
    SUM(revenue)                                             AS total_revenue
FROM retail_sales
GROUP BY STRFTIME('%Y-%m', date)
ORDER BY month;

-- 4c. Yaba deep-dive: what is Yaba selling vs other branches?
SELECT
    branch,
    category,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (PARTITION BY branch), 1) AS pct_of_branch_revenue
FROM retail_sales
GROUP BY branch, category
ORDER BY branch, pct_of_branch_revenue DESC;


-- ============================================================
-- SECTION 5: CATEGORY ANALYSIS
-- ============================================================

-- 5a. Category scorecard
SELECT
    category,
    COUNT(*)                                        AS transactions,
    SUM(quantity)                                   AS units_sold,
    SUM(revenue)                                    AS total_revenue,
    SUM(profit)                                     AS total_profit,
    ROUND(AVG(margin_pct) * 100, 1)                 AS avg_margin_pct,
    ROUND(SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM retail_sales), 1) AS revenue_share_pct
FROM retail_sales
GROUP BY category
ORDER BY total_revenue DESC;

/*
  Groceries    : ₦99.9M (49.8%) — highest revenue, margin 24.5%
  Electronics  : ₦92.8M (46.3%) — second, margin 23.6%
  Clothing     : ₦7.9M  (3.9%)  — lowest revenue but BEST margin 43.1%
  
  Insight: Clothing is massively underweighted relative to its margin quality.
*/

-- 5b. Revenue vs margin trade-off by category
SELECT
    category,
    SUM(revenue)                        AS total_revenue,
    ROUND(AVG(margin_pct) * 100, 1)     AS avg_margin_pct,
    SUM(profit)                         AS total_profit,
    -- Rank by revenue and by margin separately
    RANK() OVER (ORDER BY SUM(revenue) DESC)           AS revenue_rank,
    RANK() OVER (ORDER BY AVG(margin_pct) DESC)        AS margin_rank
FROM retail_sales
GROUP BY category;


-- ============================================================
-- SECTION 6: PRODUCT ANALYSIS
-- ============================================================

-- 6a. Full product leaderboard
SELECT
    product_name,
    category,
    COUNT(*)                                        AS transactions,
    SUM(quantity)                                   AS units_sold,
    SUM(revenue)                                    AS total_revenue,
    SUM(profit)                                     AS total_profit,
    ROUND(AVG(margin_pct) * 100, 1)                 AS avg_margin_pct,
    ROUND(AVG(revenue), 0)                          AS avg_transaction_value,
    ROUND(SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM retail_sales), 1) AS revenue_share_pct
FROM retail_sales
GROUP BY product_name, category
ORDER BY total_revenue DESC;

/*
  Top 3 by revenue:
  Rice        ₦80.6M  margin 11.8%  ← high volume, thin margin
  Laptop      ₦63.6M  margin 13.3%  ← high ticket, thin margin
  Phone       ₦25.3M  margin 20.0%

  Hidden gems (high margin, low revenue = growth opportunity):
  T-Shirt     ₦1.6M   margin 52.5%
  Jeans       ₦3.0M   margin 42.9%
  Bread       ₦1.4M   margin 40.0%
*/

-- 6b. Products ranked by profitability (not just revenue)
SELECT
    product_name,
    category,
    SUM(revenue)                    AS total_revenue,
    SUM(profit)                     AS total_profit,
    ROUND(AVG(margin_pct) * 100, 1) AS avg_margin_pct,
    RANK() OVER (ORDER BY SUM(profit) DESC)          AS profit_rank,
    RANK() OVER (ORDER BY AVG(margin_pct) DESC)      AS margin_rank
FROM retail_sales
GROUP BY product_name, category
ORDER BY profit_rank;

-- 6c. Best-selling product per branch
WITH ranked AS (
    SELECT
        branch,
        product_name,
        SUM(revenue) AS product_revenue,
        RANK() OVER (PARTITION BY branch ORDER BY SUM(revenue) DESC) AS rnk
    FROM retail_sales
    GROUP BY branch, product_name
)
SELECT branch, product_name, product_revenue
FROM ranked
WHERE rnk = 1;


-- ============================================================
-- SECTION 7: ADVANCED ANALYSIS
-- ============================================================

-- 7a. Running cumulative revenue by month
WITH monthly AS (
    SELECT
        STRFTIME('%Y-%m', date) AS month,
        SUM(revenue)            AS monthly_revenue
    FROM retail_sales
    GROUP BY STRFTIME('%Y-%m', date)
)
SELECT
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING) AS cumulative_revenue
FROM monthly
ORDER BY month;

-- 7b. ABC Analysis — classify products by revenue contribution
WITH product_revenue AS (
    SELECT
        product_name,
        category,
        SUM(revenue) AS total_revenue,
        SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM retail_sales) AS pct_of_total
    FROM retail_sales
    GROUP BY product_name, category
),
cumulative AS (
    SELECT
        product_name,
        category,
        total_revenue,
        ROUND(pct_of_total, 1) AS pct_of_total,
        ROUND(SUM(pct_of_total) OVER (ORDER BY total_revenue DESC), 1) AS cumulative_pct
    FROM product_revenue
)
SELECT
    product_name,
    category,
    total_revenue,
    pct_of_total,
    cumulative_pct,
    CASE
        WHEN cumulative_pct <= 70 THEN 'A — Core Revenue Driver'
        WHEN cumulative_pct <= 90 THEN 'B — Supporting'
        ELSE                           'C — Niche / Growth Opportunity'
    END AS abc_class
FROM cumulative
ORDER BY total_revenue DESC;

/*
  A-class (top 70% of revenue): Rice, Laptop
  B-class (70-90%): Phone, Cooking Oil
  C-class (growth opportunities): Headphones, Sneakers, Jeans, T-Shirt, Bread
  
  The C-class Clothing items have margins of 43-53% — 
  prime candidates for promotional investment.
*/

-- 7c. High-value transaction analysis (top 10%)
SELECT
    transaction_id,
    date,
    branch,
    product_name,
    quantity,
    revenue,
    profit,
    ROUND(margin_pct * 100, 1) AS margin_pct
FROM retail_sales
WHERE revenue >= (
    SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY revenue)
    FROM retail_sales
)
ORDER BY revenue DESC;
-- Note: PERCENTILE_CONT is PostgreSQL syntax.
-- SQLite alternative: use a subquery with LIMIT/OFFSET


-- ============================================================
-- SECTION 8: VIEWS (save these for reuse in Power BI / Python)
-- ============================================================

-- Monthly summary view
CREATE VIEW vw_monthly_summary AS
SELECT
    STRFTIME('%Y-%m', date)                       AS month,
    COUNT(*)                                      AS transactions,
    SUM(revenue)                                  AS total_revenue,
    SUM(profit)                                   AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 1) AS margin_pct
FROM retail_sales
GROUP BY STRFTIME('%Y-%m', date);

-- Branch scorecard view
CREATE VIEW vw_branch_scorecard AS
SELECT
    branch,
    COUNT(*)                                        AS transactions,
    SUM(revenue)                                    AS total_revenue,
    SUM(profit)                                     AS total_profit,
    ROUND(SUM(profit) * 100.0 / SUM(revenue), 1)   AS margin_pct,
    ROUND(AVG(revenue), 0)                          AS avg_order_value
FROM retail_sales
GROUP BY branch;

-- Product scorecard view
CREATE VIEW vw_product_scorecard AS
SELECT
    product_name,
    category,
    SUM(revenue)                    AS total_revenue,
    SUM(profit)                     AS total_profit,
    ROUND(AVG(margin_pct)*100, 1)   AS avg_margin_pct,
    SUM(quantity)                   AS units_sold
FROM retail_sales
GROUP BY product_name, category;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================
