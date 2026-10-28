-- ================================================
-- BLINKIT GROCERY SALES ANALYSIS (SQLite)
-- ================================================
-- Prerequisite: Contain_Raw_Data.csv imported into blinkit.db as a table
-- called `blinkit` (DB Browser for SQLite: File > Import > Table from CSV).
-- The script never changes `blinkit`. It builds a typed, cleaned copy called
-- `blinkit_clean` and runs every analysis query against that copy, so it can
-- be re-run as many times as you like.
--
-- Note on the data: each row is one product listed at one outlet, and
-- Item_Outlet_Sales is the sales value for that pair. There are no dates,
-- quantities, costs or customers in the dataset, so no time trends, profit
-- or footfall can be calculated from it.


-- ------------------------------------------------
-- STEP 1: BUILD THE CLEANED TABLE
-- ------------------------------------------------
-- Cleaning rules (mirrored in scripts/build_dashboard_data.py):
--   * Fat content: 'LF' and 'low fat' -> 'Low Fat', 'reg' -> 'Regular'.
--     Items whose ID starts with NC are non-consumables (household,
--     hygiene, others), so they get 'Non-Edible' instead of a fat label.
--   * Outlet size: blank for outlets OUT010, OUT017 and OUT045 -> 'Unknown'.
--   * Item weight: missing values filled from the same product at other
--     outlets (weight is a product attribute). 4 rows stay NULL because the
--     product never has a recorded weight.
--   * Item visibility: 0 is impossible for an item that sold, so zeros are
--     replaced with that product's average non-zero visibility.

DROP TABLE IF EXISTS blinkit_clean;

CREATE TABLE blinkit_clean (
    Item_Identifier           TEXT,
    Item_Weight               REAL,
    Item_Fat_Content          TEXT,
    Item_Visibility           REAL,
    Item_Type                 TEXT,
    Item_MRP                  REAL,
    Outlet_Identifier         TEXT,
    Outlet_Establishment_Year INTEGER,
    Outlet_Size               TEXT,
    Outlet_Location_Type      TEXT,
    Outlet_Type               TEXT,
    Item_Outlet_Sales         REAL
);

INSERT INTO blinkit_clean
SELECT
    b.Item_Identifier,
    COALESCE(
        CAST(NULLIF(b.Item_Weight, '') AS REAL),
        (SELECT AVG(CAST(NULLIF(w.Item_Weight, '') AS REAL))
           FROM blinkit w
          WHERE w.Item_Identifier = b.Item_Identifier)
    ),
    CASE
        WHEN b.Item_Identifier LIKE 'NC%'              THEN 'Non-Edible'
        WHEN b.Item_Fat_Content IN ('LF', 'low fat')   THEN 'Low Fat'
        WHEN b.Item_Fat_Content = 'reg'                THEN 'Regular'
        ELSE b.Item_Fat_Content
    END,
    CASE
        WHEN b.Item_Visibility > 0 THEN b.Item_Visibility
        ELSE (SELECT AVG(v.Item_Visibility)
                FROM blinkit v
               WHERE v.Item_Identifier = b.Item_Identifier
                 AND v.Item_Visibility > 0)
    END,
    b.Item_Type,
    b.Item_MRP,
    b.Outlet_Identifier,
    b.Outlet_Establishment_Year,
    COALESCE(NULLIF(b.Outlet_Size, ''), 'Unknown'),
    b.Outlet_Location_Type,
    b.Outlet_Type,
    b.Item_Outlet_Sales
FROM blinkit b;

-- Sanity checks: expect 8523 rows, 3 fat labels, 0 zero visibilities.
SELECT COUNT(*) AS row_count FROM blinkit_clean;
SELECT Item_Fat_Content, COUNT(*) AS row_count
FROM blinkit_clean
GROUP BY Item_Fat_Content;
SELECT SUM(Item_Visibility = 0) AS zero_visibility,
       SUM(Item_Weight IS NULL)  AS missing_weight
FROM blinkit_clean;


-- ------------------------------------------------
-- STEP 2: HEADLINE KPIs
-- ------------------------------------------------
SELECT ROUND(SUM(Item_Outlet_Sales), 2)   AS total_sales,
       ROUND(AVG(Item_Outlet_Sales), 2)   AS avg_sales_per_listing,
       COUNT(*)                           AS listings,
       COUNT(DISTINCT Item_Identifier)    AS unique_products,
       COUNT(DISTINCT Outlet_Identifier)  AS outlets,
       ROUND(AVG(Item_MRP), 2)            AS avg_mrp
FROM blinkit_clean;


-- ------------------------------------------------
-- STEP 3: BUSINESS ANALYSIS
-- ------------------------------------------------

-- Q1: Sales by fat content
SELECT Item_Fat_Content,
       ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
       COUNT(*)                         AS listings,
       ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales,
       ROUND(100.0 * SUM(Item_Outlet_Sales)
             / (SELECT SUM(Item_Outlet_Sales) FROM blinkit_clean), 1) AS pct_of_sales
FROM blinkit_clean
GROUP BY Item_Fat_Content
ORDER BY total_sales DESC;

-- Q2: Sales by product category
SELECT Item_Type,
       ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
       COUNT(*)                         AS listings,
       ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit_clean
GROUP BY Item_Type
ORDER BY total_sales DESC;

-- Q3: Sales by outlet size. Totals depend on how many outlets of each size
-- exist, so the per-outlet average is the fairer comparison.
SELECT Outlet_Size,
       COUNT(DISTINCT Outlet_Identifier) AS outlets,
       COUNT(*)                          AS listings,
       ROUND(SUM(Item_Outlet_Sales), 2)  AS total_sales,
       ROUND(SUM(Item_Outlet_Sales) / COUNT(DISTINCT Outlet_Identifier), 2) AS sales_per_outlet,
       ROUND(AVG(Item_Outlet_Sales), 2)  AS avg_sales_per_listing
FROM blinkit_clean
GROUP BY Outlet_Size
ORDER BY sales_per_outlet DESC;

-- Q4: Sales by location tier (Tier 3 has 4 outlets, Tiers 1 and 2 have 3 each)
SELECT Outlet_Location_Type,
       COUNT(DISTINCT Outlet_Identifier) AS outlets,
       ROUND(SUM(Item_Outlet_Sales), 2)  AS total_sales,
       ROUND(SUM(Item_Outlet_Sales) / COUNT(DISTINCT Outlet_Identifier), 2) AS sales_per_outlet
FROM blinkit_clean
GROUP BY Outlet_Location_Type
ORDER BY total_sales DESC;

-- Q5: Sales by outlet type
SELECT Outlet_Type,
       COUNT(DISTINCT Outlet_Identifier) AS outlets,
       ROUND(SUM(Item_Outlet_Sales), 2)  AS total_sales,
       COUNT(*)                          AS listings,
       ROUND(AVG(Item_Outlet_Sales), 2)  AS avg_sales_per_listing
FROM blinkit_clean
GROUP BY Outlet_Type
ORDER BY total_sales DESC;

-- Q6: Price tier segmentation. Boundaries use < so no MRP falls in two tiers.
SELECT
    CASE
        WHEN Item_MRP < 50  THEN '1. Budget (<50)'
        WHEN Item_MRP < 100 THEN '2. Mid (50-99)'
        WHEN Item_MRP < 200 THEN '3. Premium (100-199)'
        ELSE                     '4. Luxury (200+)'
    END AS price_tier,
    COUNT(*)                         AS listings,
    ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
    ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales
FROM blinkit_clean
GROUP BY price_tier
ORDER BY price_tier;

-- Q7: Outlet league table
SELECT Outlet_Identifier,
       Outlet_Type,
       Outlet_Size,
       Outlet_Location_Type,
       Outlet_Establishment_Year,
       COUNT(*)                         AS listings,
       ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales,
       ROUND(AVG(Item_Outlet_Sales), 2) AS avg_sales_per_listing
FROM blinkit_clean
GROUP BY Outlet_Identifier
ORDER BY total_sales DESC;

-- Q8: Fat content mix within each location tier
SELECT Outlet_Location_Type,
       ROUND(SUM(CASE WHEN Item_Fat_Content = 'Low Fat'    THEN Item_Outlet_Sales ELSE 0 END), 2) AS low_fat_sales,
       ROUND(SUM(CASE WHEN Item_Fat_Content = 'Regular'    THEN Item_Outlet_Sales ELSE 0 END), 2) AS regular_sales,
       ROUND(SUM(CASE WHEN Item_Fat_Content = 'Non-Edible' THEN Item_Outlet_Sales ELSE 0 END), 2) AS non_edible_sales
FROM blinkit_clean
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

-- Q9: Top 10 products by total sales across all outlets
-- (HAVING keeps products stocked in at least 3 outlets, so one lucky
-- listing can't top the chart)
SELECT Item_Identifier,
       Item_Type,
       COUNT(*)                         AS outlets_stocking,
       ROUND(AVG(Item_MRP), 2)          AS mrp,
       ROUND(SUM(Item_Outlet_Sales), 2) AS total_sales
FROM blinkit_clean
GROUP BY Item_Identifier
HAVING COUNT(*) >= 3
ORDER BY total_sales DESC
LIMIT 10;
