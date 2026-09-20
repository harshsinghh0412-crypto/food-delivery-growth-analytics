-- ============================================================
-- 05_OPERATIONS_ANALYSIS.SQL
-- Food Delivery Growth & Operations Analytics
-- ============================================================

-- 1. Overall delivery operations

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    MIN(o.delivery_time_minutes) AS fastest_delivery_minutes,
    MAX(o.delivery_time_minutes) AS slowest_delivery_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered';

-- 2. Delivery performance by vehicle type

SELECT
    dp.vehicle_type,
    COUNT(*) AS delivered_orders,
    COUNT(DISTINCT dp.partner_id) AS delivery_partners,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
JOIN delivery_partners dp
    ON od.partner_id = dp.partner_id
WHERE o.order_status = 'Delivered'
GROUP BY dp.vehicle_type
ORDER BY avg_delivery_time_minutes;

-- 3. Delivery performance by city

SELECT
    c.city,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.city
ORDER BY avg_delivery_time_minutes DESC;

-- 4. Delivery performance by distance band

SELECT
    CASE
        WHEN od.distance_km < 2 THEN '0–2 km'
        WHEN od.distance_km < 4 THEN '2–4 km'
        WHEN od.distance_km < 6 THEN '4–6 km'
        WHEN od.distance_km < 8 THEN '6–8 km'
        ELSE '8+ km'
    END AS distance_band,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    CASE
        WHEN od.distance_km < 2 THEN '0–2 km'
        WHEN od.distance_km < 4 THEN '2–4 km'
        WHEN od.distance_km < 6 THEN '4–6 km'
        WHEN od.distance_km < 8 THEN '6–8 km'
        ELSE '8+ km'
    END
ORDER BY MIN(od.distance_km);

-- 5. Delivery partner performance

SELECT
    dp.partner_id,
    dp.city,
    dp.vehicle_type,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
JOIN delivery_partners dp
    ON od.partner_id = dp.partner_id
WHERE o.order_status = 'Delivered'
GROUP BY
    dp.partner_id,
    dp.city,
    dp.vehicle_type
HAVING COUNT(*) >= 20
ORDER BY avg_delivery_time_minutes;

-- 6. Delivery performance by hour

SELECT
    HOUR(o.order_time) AS order_hour,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
GROUP BY HOUR(o.order_time)
ORDER BY order_hour;

-- 7. Delivery performance by day of week

SELECT
    DAYNAME(o.order_date) AS day_of_week,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
GROUP BY
    DAYOFWEEK(o.order_date),
    DAYNAME(o.order_date)
ORDER BY DAYOFWEEK(o.order_date);

-- 8. Delivery performance by payment method

SELECT
    o.payment_method,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
GROUP BY o.payment_method
ORDER BY delivered_orders DESC;

-- 9. Delivery performance by restaurant

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city
HAVING COUNT(*) >= 20
ORDER BY avg_delivery_time_minutes;

-- 10. Delivery time distribution

SELECT
    CASE
        WHEN o.delivery_time_minutes < 20 THEN '<20 min'
        WHEN o.delivery_time_minutes < 30 THEN '20–29 min'
        WHEN o.delivery_time_minutes < 40 THEN '30–39 min'
        WHEN o.delivery_time_minutes < 50 THEN '40–49 min'
        ELSE '50+ min'
    END AS delivery_time_band,
    COUNT(*) AS delivered_orders,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM orders
         WHERE order_status = 'Delivered'),
        2
    ) AS percentage_of_deliveries
FROM orders o
WHERE o.order_status = 'Delivered'
GROUP BY
    CASE
        WHEN o.delivery_time_minutes < 20 THEN '<20 min'
        WHEN o.delivery_time_minutes < 30 THEN '20–29 min'
        WHEN o.delivery_time_minutes < 40 THEN '30–39 min'
        WHEN o.delivery_time_minutes < 50 THEN '40–49 min'
        ELSE '50+ min'
    END
ORDER BY MIN(o.delivery_time_minutes);

-- 11. Distance vs delivery time

SELECT
    ROUND(od.distance_km, 0) AS distance_km_rounded,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
GROUP BY ROUND(od.distance_km, 0)
ORDER BY distance_km_rounded;

-- 12. Peak delivery hours

SELECT
    HOUR(o.order_time) AS order_hour,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
GROUP BY HOUR(o.order_time)
ORDER BY delivered_orders DESC;

-- 13. Delivery performance by customer rating

SELECT
    o.rating AS customer_rating,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
WHERE o.order_status = 'Delivered'
  AND o.rating > 0
GROUP BY o.rating
ORDER BY o.rating DESC;

-- 14. Slow deliveries by city

SELECT
    r.city,
    COUNT(*) AS slow_deliveries,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
  AND o.delivery_time_minutes >= 40
GROUP BY r.city
ORDER BY slow_deliveries DESC;

-- 15. Delivery efficiency by vehicle type

SELECT
    dp.vehicle_type,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(
        AVG(od.distance_km) /
        NULLIF(AVG(o.delivery_time_minutes), 0),
        3
    ) AS avg_km_per_minute,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
JOIN delivery_partners dp
    ON od.partner_id = dp.partner_id
WHERE o.order_status = 'Delivered'
GROUP BY dp.vehicle_type
ORDER BY avg_km_per_minute DESC;