# Blinkit grocery sales analysis

SQL and Power BI analysis of 8,523 grocery listings sold across 10 Blinkit outlets, with an interactive HTML dashboard on top.

Live dashboard: https://siyam1974.github.io/Blinkit-Dashboard/

Each row in the data is one product stocked at one outlet, and `Item_Outlet_Sales` is the sales value of that product at that outlet. The dataset has no dates, quantities, costs or customer details, so it can't show trends over time, profit or footfall. Everything below is about where the sales value sits.

## What's in the repo

```
Contain_Raw_Data.csv              raw data, 8,523 rows x 12 columns
blinkit.db                        SQLite database: raw table `blinkit` + cleaned table `blinkit_clean`
blinkit-grocery-analysis.sql      cleaning step and 9 analysis queries (SQLite)
scripts/build_dashboard_data.py   same cleaning in pandas; writes the CSV and dashboard data below
data/blinkit_clean.csv            cleaned data
interactive-dashboard/            index.html + data.js, the interactive dashboard
Dashboard_Blinkit_Project.pbix    Power BI report
powerbi-screenshots/              exported Power BI visuals
```

## How to run it

The SQL script runs in DB Browser for SQLite (open `blinkit.db`, paste the script into Execute SQL, run all). It leaves the raw `blinkit` table alone and rebuilds `blinkit_clean` each time, so it's safe to re-run.

To rebuild the cleaned CSV and the dashboard data:

```bash
pip install -r requirements.txt
python scripts/build_dashboard_data.py
```

To view the dashboard, open `interactive-dashboard/index.html` in a browser. It has no external dependencies and works offline.

## Data cleaning

| Problem in the raw data | Fix |
|---|---|
| Fat content spelled five ways (`Low Fat`, `LF`, `low fat`, `Regular`, `reg`) | Merged into `Low Fat` and `Regular` |
| 1,599 non-food items (IDs starting `NC`: household, hygiene, others) labelled "Low Fat" | Relabelled `Non-Edible` |
| Outlet size blank for 2,410 rows (all of OUT010, OUT017, OUT045) | Labelled `Unknown`, kept in every total |
| Item weight missing for 1,463 rows | Filled from the same product at other outlets; 4 rows have no weight anywhere and stay empty |
| Item visibility of 0 on 526 rows | Replaced with that product's average non-zero visibility |
| Price tiers used overlapping `BETWEEN` ranges (an MRP of exactly 100 fell in two bands) | Rewritten with `<` boundaries |

The SQL and the Python script apply the same rules, and their outputs match to the paisa.

## Headline numbers

Total sales are ₹18,591,125.41 across 8,523 listings, 1,559 distinct products and 10 outlets. The average listing sells ₹2,181.29, and the average MRP is ₹140.99.

## Findings

Fruits and vegetables are the biggest category at ₹2.82M, just ahead of snack foods at ₹2.73M. That's mostly because they have the most listings (1,232 and 1,200). Average sales per listing barely moves between categories (₹1,926 to ₹2,374).

The original version of this project said low-fat items beat regular ones by ₹11.9M to ₹6.7M. That gap came from counting 1,599 household and hygiene products as "Low Fat". Once they're split out, low fat is ₹8.48M (45.6%), regular is ₹6.69M (36.0%) and non-edible is ₹3.43M (18.4%). Per listing, regular items actually sell slightly more (₹2,225 against ₹2,164).

Price is the strongest driver in the data. MRP and sales correlate at r = 0.57, and the average listing in the ₹200+ band sells ₹3,679 against ₹616 for items under ₹50.

Outlet type matters far more than size or location. The two grocery stores (OUT010 and OUT019) average ₹340 per listing, against ₹1,996 to ₹3,694 for the supermarkets. The single Supermarket Type3 (OUT027) is the best outlet by a distance, with ₹3.45M in sales.

Medium outlets sell the most per outlet (₹2.50M) and the most in total (₹7.49M). The ₹4.39M from the three outlets with no recorded size is reported separately as Unknown.

Tier 3 has the highest total (₹7.64M), but it also has four outlets to the other tiers' three. Per outlet, Tier 2 leads with ₹2.16M, then Tier 3 at ₹1.91M and Tier 1 at ₹1.49M. Tier 1 is pulled down by OUT019, one of the two grocery stores.

## Interactive dashboard

`interactive-dashboard/index.html` shows the cleaned data with filters for location tier, outlet size, outlet type, outlet, product category, fat content and price tier. Clicking a bar in any chart filters by that value, and clicking it again clears it. Each chart ignores its own filter, so you can still see the other bars, greyed out, for comparison.

It includes:

- KPI tiles for total sales, average sales per listing, listings, unique products and average MRP
- sales by product category, by outlet (coloured by outlet type) and by fat content
- sales per outlet by size and by location tier
- average sales by price tier, and an MRP against sales scatter plot with the correlation for the current filter
- a searchable, sortable product table with paging and CSV export of the filtered rows
- light and dark mode

## Power BI

`Dashboard_Blinkit_Project.pbix` is the original Power BI report, and `powerbi-screenshots/` holds its exported visuals. Its data was imported from an earlier copy of the raw CSV, so two things in it disagree with the cleaned analysis:

- The outlet size chart puts all 2,410 blank-size rows under "Small", which makes Small look like the biggest size (about ₹8.96M). Those three outlets have no recorded size.
- The fat content donut counts household and hygiene products as "Low Fat" (₹11.90M, 64%).

The visuals also use a `$` format, while the data is in rupees. To bring the report in line, change its source to `data/blinkit_clean.csv` (Transform data, then Data source settings) and refresh.

## Skills used

SQL (SQLite): `CREATE TABLE ... AS`, `INSERT ... SELECT`, correlated subqueries for imputation, `CASE WHEN`, `COALESCE`/`NULLIF`, `GROUP BY`/`HAVING`, conditional aggregation. Python: pandas for cleaning and group-wise imputation. Front end: plain HTML, CSS and JavaScript with SVG and canvas charts.
