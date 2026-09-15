# Blinkit Grocery Sales Analysis (SQL)

## Project Overview
This project conducts an end-to-end exploratory analysis of Blinkit's grocery sales dataset using SQL. The goal is to analyze revenue drivers, product category performance, store size profitability, and customer purchasing preferences across location tiers.

## Skills Demonstrated
* **Database Cleaning:** Data standardization (`UPDATE`, `WHERE`, `IN`)
* **KPI Calculation:** High-level metrics aggregation (`SUM`, `AVG`, `COUNT`, `ROUND`)
* **Business Analysis:** Data slicing and segmentation (`GROUP BY`, `ORDER BY`, `HAVING`)
* **Conditional Logic:** Price tier classification (`CASE WHEN`)

## Key Business Metrics (KPIs)
* **Total Revenue:** $[18591125.41]
* **Average Sales Per Item:** $[2181.29]
* **Total Items Sold:** [8523]

## Key Insights & Findings
1. **Fat Content Preference:** Low Fat items generated $[11904094.53] across [5517] items, outperforming Regular fat items. Where Regular Fat Content sales is $[6687030.88] across [3006] items.
2. **Top Selling Category:** [Fruits and Vegetables] is the highest revenue-generating category ($[2820059.82]).
3. **Outlet Size Impact:** [Medium] stores produced the highest overall sales volume which is [7489718.69].
4. **City Tier Performance:** [Tier 3] locations generated the most revenue Order by Tier 2 and 1.
## Dashboard
1. Key Performance Indicators (KPIs)
Total Sales ($18.59M): Cumulative revenue generated across all store outlets and grocery inventory.

Average Sales ($2.18K): Mean revenue generated per item entry across all outlet locations.

Insight: Strong cumulative revenue paired with high average sales per item indicates solid item throughput across the retail network.
<img width="600" alt="Total_sales" src="Dashboard/Total_sales.png" />
## Repository Structure
* `BlinkIT Grocery Data.csv` — Raw dataset
* `blinkit_analysis.sql` — Cleaned SQL script containing data transformation and analysis queries
* `README.md` — Project summary and business findings
