/*
DecodeLabs Project 3 — SQL Data Analysis
Database: PostgreSQL
Source: cleaned e-commerce orders workbook (1,200 rows)

IMPORT:
1. In pgAdmin, create/connect to a database named decodelabs_project3.
2. Run the CREATE TABLE section below in Query Tool.
3. In the browser tree: Schemas > public > Tables > orders.
4. Right-click orders > Import/Export Data.
5. Choose Import; select orders_cleaned_for_sql.csv.
6. Format: CSV; Header: Yes; Delimiter: comma; Encoding: UTF8.
7. Import, then run the analysis queries below.

Privacy: shipping addresses and tracking numbers are excluded because they
are not required for this analysis. Customer IDs are also excluded.
*/

-- SECTION 1: Create the table
CREATE TABLE IF NOT EXISTS orders (
    order_id       VARCHAR(20) PRIMARY KEY,
    order_date     DATE NOT NULL,
    product        VARCHAR(50) NOT NULL,
    quantity       INTEGER NOT NULL CHECK (quantity > 0),
    unit_price     NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
    payment_method VARCHAR(50),
    order_status   VARCHAR(30),
    items_in_cart  INTEGER,
    coupon_code    VARCHAR(50),
    referral_source VARCHAR(50),
    total_price    NUMERIC(12,2) NOT NULL CHECK (total_price >= 0)
);

-- SECTION 2: Verify that data was imported
SELECT COUNT(*) AS total_orders
FROM orders;

SELECT *
FROM orders
ORDER BY order_date
LIMIT 10;

-- SECTION 3: Basic descriptive statistics
SELECT
    COUNT(*) AS total_orders,
    ROUND(AVG(total_price), 2) AS average_order_value,
    ROUND(SUM(total_price), 2) AS total_recorded_order_value,
    ROUND(AVG(quantity), 2) AS average_quantity_per_order,
    SUM(quantity) AS total_units_ordered,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders;

-- SECTION 4: Filter rows using WHERE
SELECT order_id, order_date, product, total_price, order_status
FROM orders
WHERE order_status = 'Delivered'
ORDER BY total_price DESC;

SELECT order_id, product, quantity, total_price
FROM orders
WHERE total_price >= 1000
ORDER BY total_price DESC;

-- SECTION 5: Product-level analysis using GROUP BY and aggregates
SELECT
    product,
    COUNT(*) AS number_of_orders,
    SUM(quantity) AS units_ordered,
    ROUND(AVG(total_price), 2) AS average_order_value,
    ROUND(SUM(total_price), 2) AS recorded_order_value
FROM orders
GROUP BY product
ORDER BY recorded_order_value DESC;

-- SECTION 6: Order status distribution
SELECT
    order_status,
    COUNT(*) AS number_of_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY number_of_orders DESC;

-- SECTION 7: Payment method analysis
SELECT
    payment_method,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(total_price), 2) AS average_order_value,
    ROUND(SUM(total_price), 2) AS recorded_order_value
FROM orders
GROUP BY payment_method
ORDER BY number_of_orders DESC;

-- SECTION 8: Referral source analysis
SELECT
    referral_source,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(total_price), 2) AS average_order_value
FROM orders
GROUP BY referral_source
ORDER BY number_of_orders DESC;

-- SECTION 9: Coupon usage
SELECT
    coupon_code,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(total_price), 2) AS average_order_value
FROM orders
GROUP BY coupon_code
ORDER BY number_of_orders DESC;

-- SECTION 10: Monthly order trend
SELECT
    DATE_TRUNC('month', order_date)::date AS order_month,
    COUNT(*) AS number_of_orders,
    ROUND(SUM(total_price), 2) AS recorded_order_value
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY order_month;

-- SECTION 11: Annual order trend
SELECT
    EXTRACT(YEAR FROM order_date)::int AS order_year,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(total_price), 2) AS average_order_value,
    ROUND(SUM(total_price), 2) AS recorded_order_value
FROM orders
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY order_year;

-- SECTION 12: HAVING — retain product groups with at least 170 orders
SELECT
    product,
    COUNT(*) AS number_of_orders,
    ROUND(AVG(total_price), 2) AS average_order_value
FROM orders
GROUP BY product
HAVING COUNT(*) >= 170
ORDER BY number_of_orders DESC;

-- SECTION 13: Data-quality checks
-- Duplicate order IDs (expected: 0)
SELECT order_id, COUNT(*) AS occurrences
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Missing values in key analysis fields
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE product IS NULL) AS missing_product,
    COUNT(*) FILTER (WHERE total_price IS NULL) AS missing_total_price
FROM orders;

-- Verify arithmetic consistency: total_price = quantity * unit_price
SELECT COUNT(*) AS rows_with_price_mismatch
FROM orders
WHERE ABS(total_price - (quantity * unit_price)) > 0.01;

-- END OF PROJECT 3
