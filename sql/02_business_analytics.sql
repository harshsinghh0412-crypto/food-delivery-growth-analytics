-- ============================================================
-- 02_BUSINESS_ANALYSIS.SQL
-- Food Delivery Growth & Operations Analytics
-- ============================================================

-- 1. Overall business performance

SELECT
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    SUM(order_status = 'Cancelled') AS cancelled_orders,
    SUM(order_status = 'Rejected') AS rejected_orders,
    ROUND(SUM(CASE
        WHEN order_status = 'Delivered' THEN order_value
        ELSE 0
    END), 2) AS total_gmv,
    ROUND(AVG(CASE
        WHEN order_status = 'Delivered' THEN order_value
    END), 2) AS average_order_value,
    ROUND(AVG(CASE
        WHEN order_status = 'Delivered' THEN delivery_time_minutes
    END), 2) AS average_delivery_time_minutes
FROM orders;

-- 2. Monthly business performance

SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered' THEN order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN order_status = 'Delivered' THEN order_value
        END), 2
    ) AS aov,
    ROUND(
        100 * SUM(order_status = 'Delivered') / COUNT(*),
        2
    ) AS delivery_success_rate_pct
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 3. Month-over-month GMV growth

WITH monthly_gmv AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(
            CASE
                WHEN order_status = 'Delivered' THEN order_value
                ELSE 0
            END
        ) AS gmv
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)

SELECT
    month,
    ROUND(gmv, 2) AS gmv,
    ROUND(
        100 * (gmv - LAG(gmv) OVER (ORDER BY month))
        / NULLIF(LAG(gmv) OVER (ORDER BY month), 0),
        2
    ) AS mom_gmv_growth_pct
FROM monthly_gmv
ORDER BY month;

-- 4. Order status analysis

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        100 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- 5. City-level business performance

SELECT
    c.city,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(*) AS total_orders,
    SUM(o.order_status = 'Delivered') AS delivered_orders,
    SUM(o.order_status IN ('Cancelled', 'Rejected')) AS failed_orders,
    ROUND(
        100 * SUM(o.order_status IN ('Cancelled', 'Rejected')) / COUNT(*),
        2
    ) AS failure_rate_pct,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
        END), 2
    ) AS aov,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.delivery_time_minutes
        END), 2
    ) AS avg_delivery_time_minutes
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY gmv DESC;

-- 6. Acquisition channel performance

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(o.order_id) AS total_orders,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
        END), 2
    ) AS aov
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY gmv DESC;

-- 7. Payment method performance

SELECT
    payment_method,
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    SUM(order_status IN ('Cancelled', 'Rejected')) AS failed_orders,
    ROUND(
        100 * SUM(order_status = 'Delivered') / COUNT(*),
        2
    ) AS delivery_success_rate_pct,
    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered' THEN order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN order_status = 'Delivered' THEN order_value
        END), 2
    ) AS aov
FROM orders
GROUP BY payment_method
ORDER BY gmv DESC;

-- 8. Discount and order value analysis

SELECT
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 50 THEN '₹1–50'
        WHEN discount <= 100 THEN '₹51–100'
        WHEN discount <= 200 THEN '₹101–200'
        ELSE '₹200+'
    END AS discount_band,
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    ROUND(
        AVG(CASE
            WHEN order_status = 'Delivered' THEN order_value
        END), 2
    ) AS average_order_value,
    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered' THEN order_value
            ELSE 0
        END), 2
    ) AS gmv
FROM orders
GROUP BY
    CASE
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 50 THEN '₹1–50'
        WHEN discount <= 100 THEN '₹51–100'
        WHEN discount <= 200 THEN '₹101–200'
        ELSE '₹200+'
    END
ORDER BY total_orders DESC;

-- 9. Customer value by acquisition channel

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END)
        / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS gmv_per_customer
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY gmv_per_customer DESC;

-- 10. Customer repeat behavior

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS delivered_orders
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN delivered_orders = 1 THEN 'One-time'
        WHEN delivered_orders >= 2 THEN 'Repeat'
        ELSE 'No Delivered Orders'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        100 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM customer_orders
GROUP BY
    CASE
        WHEN delivered_orders = 1 THEN 'One-time'
        WHEN delivered_orders >= 2 THEN 'Repeat'
        ELSE 'No Delivered Orders'
    END
ORDER BY customers DESC;

-- 11. Restaurant performance

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating AS restaurant_rating,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
        END), 2
    ) AS aov,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            AND o.rating > 0
            THEN o.rating
        END), 2
    ) AS avg_customer_rating
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating
ORDER BY gmv DESC;

-- 12. Cuisine performance

SELECT
    r.cuisine,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
        END), 2
    ) AS aov,
    ROUND(
        AVG(r.rating), 2
    ) AS avg_restaurant_rating
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY r.cuisine
ORDER BY gmv DESC;

-- 13. Top 10 restaurants by GMV

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
        END), 2
    ) AS aov
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine
ORDER BY gmv DESC
LIMIT 10;

-- 14. Restaurant rating vs order performance

SELECT
    CASE
        WHEN r.rating >= 4.5 THEN '4.5–5.0'
        WHEN r.rating >= 4.0 THEN '4.0–4.49'
        WHEN r.rating >= 3.5 THEN '3.5–3.99'
        ELSE 'Below 3.5'
    END AS rating_band,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
        END), 2
    ) AS aov
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    CASE
        WHEN r.rating >= 4.5 THEN '4.5–5.0'
        WHEN r.rating >= 4.0 THEN '4.0–4.49'
        WHEN r.rating >= 3.5 THEN '3.5–3.99'
        ELSE 'Below 3.5'
    END
ORDER BY rating_band DESC;

-- 15. Delivery operations performance

SELECT
    dp.vehicle_type,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(o.rating), 2) AS avg_customer_rating
FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
JOIN delivery_partners dp
    ON od.partner_id = dp.partner_id
WHERE o.order_status = 'Delivered'
GROUP BY dp.vehicle_type
ORDER BY avg_delivery_time_minutes;

-- 16. Delivery performance by city

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

-- 17. Delivery performance by distance band

SELECT
    CASE
        WHEN od.distance_km < 2 THEN '0–2 km'
        WHEN od.distance_km < 4 THEN '2–4 km'
        WHEN od.distance_km < 6 THEN '4–6 km'
        WHEN od.distance_km < 8 THEN '6–8 km'
        ELSE '8+ km'
    END AS distance_band,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(o.delivery_time_minutes), 2) AS avg_delivery_time_minutes,
    ROUND(AVG(od.distance_km), 2) AS avg_distance_km,
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
ORDER BY avg_distance_km;

-- 18. Delivery partner performance

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

-- 19. Order failure rate by city

SELECT
    c.city,
    COUNT(*) AS total_orders,
    SUM(o.order_status IN ('Cancelled', 'Rejected')) AS failed_orders,
    ROUND(
        100 * SUM(o.order_status IN ('Cancelled', 'Rejected'))
        / COUNT(*),
        2
    ) AS failure_rate_pct,
    SUM(o.order_status = 'Delivered') AS delivered_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY failure_rate_pct DESC;

-- 20. Order volume by day of week

SELECT
    DAYNAME(order_date) AS day_of_week,
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered' THEN order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN order_status = 'Delivered' THEN order_value
        END), 2
    ) AS aov
FROM orders
GROUP BY
    DAYOFWEEK(order_date),
    DAYNAME(order_date)
ORDER BY DAYOFWEEK(order_date);

-- 21. Order volume by hour

SELECT
    HOUR(order_time) AS order_hour,
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered' THEN order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN order_status = 'Delivered' THEN order_value
        END), 2
    ) AS aov
FROM orders
GROUP BY HOUR(order_time)
ORDER BY order_hour;

-- 22. Peak demand by day and hour

SELECT
    DAYNAME(order_date) AS day_of_week,
    HOUR(order_time) AS order_hour,
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered' THEN order_value
            ELSE 0
        END), 2
    ) AS gmv
FROM orders
GROUP BY
    DAYOFWEEK(order_date),
    DAYNAME(order_date),
    HOUR(order_time)
ORDER BY total_orders DESC;

-- 23. Customer spending and order frequency

SELECT
    c.customer_id,
    c.city,
    c.age_group,
    c.acquisition_channel,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS total_spend,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
        END), 2
    ) AS aov,
    MIN(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_date
    END) AS first_order_date,
    MAX(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_date
    END) AS last_order_date
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.city,
    c.age_group,
    c.acquisition_channel
ORDER BY total_spend DESC;

-- 24. Customer RFM analysis

WITH customer_rfm AS (
    SELECT
        c.customer_id,

        DATEDIFF(
            '2026-06-30',
            MAX(CASE
                WHEN o.order_status = 'Delivered'
                THEN o.order_date
            END)
        ) AS recency_days,

        COUNT(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_id
        END) AS frequency,

        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END) AS monetary

    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id

    GROUP BY c.customer_id
)

SELECT
    customer_id,
    recency_days,
    frequency,
    ROUND(monetary, 2) AS monetary,

    NTILE(5) OVER (
        ORDER BY recency_days DESC
    ) AS recency_score,

    NTILE(5) OVER (
        ORDER BY frequency
    ) AS frequency_score,

    NTILE(5) OVER (
        ORDER BY monetary
    ) AS monetary_score

FROM customer_rfm
ORDER BY monetary DESC;