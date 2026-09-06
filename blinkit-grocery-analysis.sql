-- ================================================
-- BLINKIT GROCERY item_outlet_Sales ANALYSIS (SQL SCRIPT)
-- ================================================

-- STEP 1: DATA CLEANING & STANDARDIZATION
-- Standardizing inconsistent Fat Content labels
UPDATE blinkit 
SET Item_Fat_Content = 'Low Fat'
WHERE Item_Fat_Content IN ('LF', 'low fat');

UPDATE blinkit 
SET Item_Fat_Content = 'Regular'
WHERE Item_Fat_Content = 'reg';


-- STEP 2: EXECUTIVE KPI CALCULATIONS
-- 1. Total item_outlet_Sales Revenue
SELECT ROUND(SUM(item_outlet_Sales), 2) AS total_item_outlet_Sales FROM blinkit;

-- 2. Average item_outlet_Sales Per Item
SELECT ROUND(AVG(item_outlet_Sales), 2) AS avg_Sales FROM blinkit;

-- 3. Total Items Sold
SELECT COUNT(*) AS total_items FROM blinkit;


-- STEP 3: BUSINESS ANALYSIS & CATEGORY PERFORMANCE
-- Q1: item_outlet_Sales Breakdown by Fat Content
SELECT Item_Fat_Content,
       ROUND(SUM(item_outlet_Sales), 2) AS total_Sales,
       COUNT(*) AS item_count
FROM blinkit
GROUP BY Item_Fat_Content;

-- Q2: Revenue by Product Category (Item Type)
SELECT Item_Type,
       ROUND(SUM(item_outlet_Sales), 2) AS total_item_outlet_Sales,
       COUNT(*) AS item_count
FROM blinkit
GROUP BY Item_Type
ORDER BY total_item_outlet_Sales DESC;

-- Q3: item_outlet_Sales Performance by Outlet Size
SELECT Outlet_Size,
       ROUND(SUM(item_outlet_Sales), 2) AS total_item_outlet_Sales,
       COUNT(*) AS outlet_count,
       ROUND(AVG(item_outlet_Sales), 2) AS avg_item_outlet_Sales_per_item
FROM blinkit
GROUP BY Outlet_Size
ORDER BY total_item_outlet_Sales DESC;

-- Q4: item_outlet_Sales Performance by Location Tier
SELECT Outlet_Location_Type,
       ROUND(SUM(item_outlet_Sales), 2) AS total_item_outlet_Sales
FROM blinkit
GROUP BY Outlet_Location_Type
ORDER BY total_item_outlet_Sales DESC;

-- Q5: item_outlet_Sales Performance by Outlet Type
SELECT Outlet_Type,
       ROUND(SUM(item_outlet_Sales), 2) AS total_item_outlet_Sales,
       COUNT(*) AS item_count,
       ROUND(AVG(item_outlet_Sales), 2) AS avg_item_outlet_Sales
FROM blinkit
GROUP BY Outlet_Type
ORDER BY total_item_outlet_Sales DESC;

-- Q6: Price Tier Segmentation (CASE WHEN)
SELECT
  CASE
    WHEN Item_MRP < 50 THEN '1. Budget (Under 50)'
    WHEN Item_MRP BETWEEN 50 AND 100 THEN '2. Mid (50-100)'
    WHEN Item_MRP BETWEEN 100 AND 200 THEN '3. Premium (100-200)'
    ELSE '4. Luxury (200+)'
  END AS price_range,
  COUNT(*) AS item_count,
  ROUND(SUM(item_outlet_Sales), 2) AS total_item_outlet_Sales
FROM blinkit
GROUP BY price_range
ORDER BY total_item_outlet_Sales DESC;