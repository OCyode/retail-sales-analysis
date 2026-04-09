# Analysis Summary — Nigerian Retail Sales, Jan–Jun 2025

**Prepared by:** Data Analyst Portfolio Project
**Tools used:** SQL · Python · Power BI
**Dataset:** 294 transactions | 3 branches | Lagos, Nigeria

---

## Top-Line Numbers

| Metric | Value |
|---|---|
| Total Revenue | ₦200,537,000 |
| Total Profit | ₦31,959,600 |
| Overall Gross Margin | 15.9% (profit/revenue) |
| Avg Gross Margin per transaction | 30.2% |
| Total Transactions | 294 |
| Avg Order Value | ₦682,099 |
| Total Units Sold | 3,421 |

---

## Monthly Performance

| Month | Revenue | Profit | MoM Change |
|---|---|---|---|
| Jan 2025 | ₦34.9M | ₦10.2M | — |
| Feb 2025 | ₦19.6M | ₦6.0M | -43.7% |
| Mar 2025 | ₦42.5M | ₦12.3M | +116.8% |
| Apr 2025 | ₦35.0M | ₦10.9M | -17.7% |
| May 2025 | ₦32.8M | ₦9.9M | -6.3% |
| Jun 2025 | ₦35.7M | ₦11.0M | +8.8% |

**February–March is the key anomaly.** A 43.7% drop followed by a 116.8% surge
is not normal seasonal variation — something specific happened. Identifying the
driver (B2B bulk order? promotional event? supplier restock?) and replicating it
is the single highest-value insight in this dataset.

---

## Branch Analysis

| Branch | Revenue | Profit | Transactions | Avg Order Value | Margin |
|---|---|---|---|---|---|
| Lekki | ₦74.3M | ₦11.3M | 86 | ₦863,512 | 27.1% |
| Ikeja | ₦74.2M | ₦11.8M | 129 | ₦574,899 | 31.7% |
| Yaba | ₦52.1M | ₦8.8M | 79 | ₦659,658 | 31.2% |

**Reading this table carefully:**
- Lekki has only 86 transactions but a much higher average order value (₦863K).
  It is selling fewer, bigger tickets — likely heavy on Electronics (Laptops, Phones).
- Ikeja has the most transactions (129) at a lower average order value — higher volume, lower ticket.
- Yaba's gap is in both transaction count AND average order value — a compound problem.

The SQL branch deep-dive (Section 4c) confirms: Yaba generates 60.4% of its revenue
from Groceries and has almost no Electronics. Stocking Laptops and Phones in Yaba
would directly lift its average order value.

---

## Category Analysis

| Category | Revenue | Share | Avg Margin | Profit |
|---|---|---|---|---|
| Groceries | ₦99.9M | 49.8% | 24.5% | ₦14.0M |
| Electronics | ₦92.8M | 46.3% | 23.6% | ₦15.0M |
| Clothing | ₦7.9M | 3.9% | 43.1% | ₦2.9M |

**The Clothing paradox:** Clothing generates nearly double the margin percentage
of the other two categories but represents less than 4% of revenue. This is the
clearest growth lever in the dataset. A focused campaign — bundling, shelf space,
or a targeted discount — could meaningfully shift the blended portfolio margin.

---

## Product Analysis

| Product | Category | Revenue | Margin | ABC Class |
|---|---|---|---|---|
| Rice | Groceries | ₦80.6M | 11.8% | A — Core Revenue |
| Laptop | Electronics | ₦63.6M | 13.3% | A — Core Revenue |
| Phone | Electronics | ₦25.3M | 20.0% | B — Supporting |
| Cooking Oil | Groceries | ₦17.9M | 22.2% | B — Supporting |
| Headphones | Electronics | ₦3.9M | 37.5% | C — Growth Opportunity |
| Sneakers | Clothing | ₦3.3M | 25.0% | C — Growth Opportunity |
| Jeans | Clothing | ₦3.0M | 42.9% | C — Growth Opportunity |
| T-Shirt | Clothing | ₦1.6M | 52.5% | C — Growth Opportunity |
| Bread | Groceries | ₦1.4M | 40.0% | C — Growth Opportunity |

**The ABC analysis tells the real story:**
- Class A products (Rice, Laptop) drive the revenue but at thin margins below 14%.
  The business cannot afford to lose them — but cannot afford to only sell them either.
- Class C products have the best margins (37–52%) and the lowest revenue.
  These are not failures; they are undertapped.

---

## Recommendations (Prioritised)

### 1. Stock Electronics in Yaba — HIGH PRIORITY
Yaba has the footfall. It lacks the product. If Yaba matched Ikeja's Electronics
revenue share (~46%), Yaba's monthly revenue would rise from ₦8.7M to an estimated
₦12-13M — bringing it in line with its peers. This is the highest-confidence,
lowest-risk recommendation in this analysis.

### 2. Investigate and Replicate the March Spike — HIGH PRIORITY
March generated ₦42.5M. The average month generates ₦33.4M.
That is a ₦9.1M premium. If we can identify what drove it and build a repeatable
playbook (a campaign, a seasonal event, a B2B customer), applying it to just
two months per year adds ~₦18M in incremental annual revenue.

### 3. Run a Clothing Push Across All Branches — MEDIUM PRIORITY
T-Shirt: 52.5% margin. Jeans: 42.9%. Sneakers: 25.0%.
A targeted promotion — even at 15% discount — would still yield 30–44% margins
on Clothing items, well above the portfolio average. Focus on Ikeja first
(highest transaction volume = most promotional reach).

### 4. Reduce Rice and Laptop Concentration Risk — MEDIUM PRIORITY
Rice + Laptop = 72% of total revenue at under 14% blended margin.
If either supplier raises costs or a competitor undercuts pricing, the business
faces severe revenue exposure. The diversification strategy is already implicit
in Recommendations 1 and 3 — making them urgent, not optional.

### 5. Renegotiate Laptop Unit Cost — LOW PRIORITY
Laptop: ₦520,000 unit cost, ₦600,000 unit price. Margin: 13.3%.
A 5% reduction in cost (₦26,000 per unit) saves approximately ₦2.8M annually
based on current sales volume. This is worth a supplier conversation.

---

## Methodology Notes

- All analysis performed in SQL (aggregations, window functions, ABC classification)
  and Python (visualizations via Pandas + Matplotlib)
- Interactive dashboard built in Power BI with DAX measures matching SQL logic
- Margin stored in source data as a decimal ratio; converted to percentage for display
- ABC classification thresholds: A = top 70% cumulative revenue, B = 70–90%, C = 90–100%
- No data cleaning was required — zero nulls, zero duplicates in the source file

---

*This analysis was produced as a portfolio project. Business names and transaction data are fictional.*
