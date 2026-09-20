-- Data Quality Analysis
-- ============================================================
-- 01_DATA_QUALITY.SQL
-- Food Delivery Growth & Operations Analytics
-- ============================================================

-- 1. Row count validation
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'restaurants', COUNT(*)
FROM restaurants

UNION ALL

SELECT 'delivery_partners', COUNT(*)
FROM delivery_partners

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_delivery', COUNT(*)
FROM order_delivery;

-- 2. Duplicate ID checks
-- Each primary ID should be unique.

SELECT 'customers' AS table_name, customer_id AS id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'restaurants', restaurant_id, COUNT(*)
FROM restaurants
GROUP BY restaurant_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'delivery_partners', partner_id, COUNT(*)
FROM delivery_partners
GROUP BY partner_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'orders', order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1

UNION ALL

SELECT 'order_delivery', order_id, COUNT(*)
FROM order_delivery
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 3. NULL value checks
-- Check important columns for missing values.

SELECT
    'customers' AS table_name,
    SUM(customer_id IS NULL) AS null_customer_id,
    SUM(signup_date IS NULL) AS null_signup_date,
    SUM(city IS NULL) AS null_city,
    SUM(age_group IS NULL) AS null_age_group,
    SUM(acquisition_channel IS NULL) AS null_acquisition_channel
FROM customers

UNION ALL

SELECT
    'restaurants',
    SUM(restaurant_id IS NULL),
    SUM(restaurant_name IS NULL),
    SUM(city IS NULL),
    SUM(cuisine IS NULL),
    SUM(rating IS NULL)
FROM restaurants

UNION ALL

SELECT
    'orders',
    SUM(order_id IS NULL),
    SUM(customer_id IS NULL),
    SUM(restaurant_id IS NULL),
    SUM(order_date IS NULL),
    SUM(order_value IS NULL)
FROM orders

UNION ALL

SELECT
    'order_delivery',
    SUM(order_id IS NULL),
    SUM(partner_id IS NULL),
    SUM(pickup_time IS NULL),
    SUM(delivered_time IS NULL),
    SUM(distance_km IS NULL)
FROM order_delivery;

-- 4. Order status validation
-- Identify any unexpected order statuses.

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- 5. Financial data validation
-- Check for negative or logically invalid values.

SELECT
    COUNT(*) AS negative_order_values
FROM orders
WHERE order_value < 0;

SELECT
    COUNT(*) AS negative_discounts
FROM orders
WHERE discount < 0;

SELECT
    COUNT(*) AS discount_greater_than_order_value
FROM orders
WHERE discount > order_value;

SELECT
    COUNT(*) AS negative_delivery_fees
FROM orders
WHERE delivery_fee < 0;

-- 6. Rating validation
-- Restaurant ratings should be between 0 and 5.
-- Order ratings use 0.0 to represent "no rating provided".

SELECT
    COUNT(*) AS invalid_restaurant_ratings
FROM restaurants
WHERE rating < 0 OR rating > 5;

SELECT
    COUNT(*) AS invalid_order_ratings
FROM orders
WHERE rating < 0 OR rating > 5;

-- 7. Operations data validation
-- Delivery time and distance should never be negative.

SELECT
    COUNT(*) AS negative_delivery_times
FROM orders
WHERE delivery_time_minutes < 0;

SELECT
    COUNT(*) AS negative_distances
FROM order_delivery
WHERE distance_km < 0;

SELECT
    COUNT(*) AS invalid_delivery_records
FROM order_delivery od
LEFT JOIN orders o
    ON od.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 8. Final data quality summary

SELECT
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    SUM(order_status = 'Cancelled') AS cancelled_orders,
    SUM(order_status = 'Rejected') AS rejected_orders,
    ROUND(
        100 * SUM(order_status = 'Delivered') / COUNT(*),
        2
    ) AS delivery_success_rate_pct
FROM orders;
