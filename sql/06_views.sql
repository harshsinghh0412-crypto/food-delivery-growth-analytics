USE food_delivery_analytics;

CREATE OR REPLACE VIEW vw_monthly_performance AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS total_orders,
    SUM(order_status = 'Delivered') AS delivered_orders,
    SUM(order_status = 'Cancelled') AS cancelled_orders,
    SUM(order_status = 'Rejected') AS rejected_orders,
    ROUND(SUM(CASE
        WHEN order_status = 'Delivered' THEN order_value
        ELSE 0
    END), 2) AS gmv,
    ROUND(AVG(CASE
        WHEN order_status = 'Delivered' THEN order_value
    END), 2) AS aov
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

CREATE OR REPLACE VIEW vw_customer_metrics AS
SELECT
    c.customer_id,
    c.city,
    c.age_group,
    c.acquisition_channel,
    c.signup_date,

    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN 1
    END) AS delivered_orders,

    ROUND(SUM(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
        ELSE 0
    END), 2) AS total_spend,

    ROUND(AVG(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
    END), 2) AS aov,

    MIN(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_date
    END) AS first_order_date,

    MAX(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_date
    END) AS last_order_date

FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.city,
    c.age_group,
    c.acquisition_channel,
    c.signup_date;
    
CREATE OR REPLACE VIEW vw_customer_rfm AS
SELECT
    customer_id,
    recency_days AS recency,
    delivered_orders AS frequency,
    total_spend AS monetary,

    NTILE(5) OVER (
        ORDER BY recency_days DESC
    ) AS r_score,

    NTILE(5) OVER (
        ORDER BY delivered_orders
    ) AS f_score,

    NTILE(5) OVER (
        ORDER BY total_spend
    ) AS m_score

FROM (
    SELECT
        customer_id,
        DATEDIFF(
            '2026-06-30',
            last_order_date
        ) AS recency_days,
        delivered_orders,
        total_spend
    FROM vw_customer_metrics
    WHERE delivered_orders > 0
) x;

CREATE OR REPLACE VIEW vw_city_performance AS
SELECT
    r.city,

    COUNT(DISTINCT o.customer_id) AS customers,

    COUNT(*) AS total_orders,

    SUM(o.order_status = 'Delivered') AS delivered_orders,

    SUM(o.order_status = 'Cancelled') AS cancelled_orders,

    SUM(o.order_status = 'Rejected') AS rejected_orders,

    ROUND(
        (
            SUM(o.order_status IN ('Cancelled', 'Rejected'))
            / COUNT(*)
        ) * 100,
        2
    ) AS failure_rate_pct,

    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN o.order_value
                ELSE 0
            END
        ),
        2
    ) AS gmv,

    ROUND(
        AVG(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN o.order_value
            END
        ),
        2
    ) AS aov,

    ROUND(
        AVG(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN o.delivery_time_minutes
            END
        ),
        2
    ) AS avg_delivery_time

FROM orders o
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id

GROUP BY r.city;

--

-- 5. Restaurant Performance

CREATE OR REPLACE VIEW vw_restaurant_performance AS
SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating AS restaurant_rating,
    r.cost_for_two,

    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN 1
    END) AS delivered_orders,

    ROUND(SUM(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
        ELSE 0
    END), 2) AS gmv,

    ROUND(AVG(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
    END), 2) AS aov,

    ROUND(AVG(CASE
        WHEN o.order_status = 'Delivered'
         AND o.rating > 0
        THEN o.rating
    END), 2) AS avg_customer_rating

FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id

GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating,
    r.cost_for_two;
    
-- 6. Operations Performance

CREATE OR REPLACE VIEW vw_operations AS
SELECT
    o.order_id,
    o.customer_id,
    o.restaurant_id,
    o.order_date,
    o.order_time,
    o.order_value,
    o.delivery_time_minutes,
    o.rating,

    r.city,

    od.partner_id,
    dp.vehicle_type,

    od.distance_km,
    od.pickup_time,
    od.delivered_time

FROM orders o
JOIN order_delivery od
    ON o.order_id = od.order_id
JOIN restaurants r
    ON o.restaurant_id = r.restaurant_id
JOIN delivery_partners dp
    ON od.partner_id = dp.partner_id

WHERE o.order_status = 'Delivered';

-- 7. Customer RFM Segments

CREATE OR REPLACE VIEW vw_customer_rfm_segments AS
SELECT
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_score,

    CASE
        WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3
             AND f_score >= 4
            THEN 'Loyal Customers'

        WHEN r_score >= 4
             AND f_score <= 2
            THEN 'Recent Customers'

        WHEN r_score <= 2
             AND f_score >= 3
            THEN 'At Risk'

        ELSE 'Others'
    END AS segment

FROM vw_customer_rfm;

-- 8. Order Status Summary

CREATE OR REPLACE VIEW vw_order_status AS
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

--

-- 9. Acquisition Channel Performance

CREATE OR REPLACE VIEW vw_acquisition_performance AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN 1
    END) AS delivered_orders,

    ROUND(SUM(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
        ELSE 0
    END), 2) AS gmv,

    ROUND(AVG(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
    END), 2) AS aov,

    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END) / COUNT(DISTINCT c.customer_id),
        2
    ) AS gmv_per_customer

FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY c.acquisition_channel;

-- 10. Cuisine Performance

CREATE OR REPLACE VIEW vw_cuisine_performance AS
SELECT
    r.cuisine,

    COUNT(DISTINCT r.restaurant_id) AS restaurants,

    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN 1
    END) AS delivered_orders,

    ROUND(SUM(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
        ELSE 0
    END), 2) AS gmv,

    ROUND(AVG(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_value
    END), 2) AS aov,

    ROUND(AVG(r.rating), 2) AS avg_restaurant_rating

FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id

GROUP BY r.cuisine;

-- 11. Payment Method Performance

CREATE OR REPLACE VIEW vw_payment_performance AS
SELECT
    payment_method,

    COUNT(*) AS total_orders,

    SUM(order_status = 'Delivered') AS delivered_orders,

    SUM(order_status = 'Cancelled') AS cancelled_orders,

    SUM(order_status = 'Rejected') AS rejected_orders,

    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered'
            THEN order_value
            ELSE 0
        END),
        2
    ) AS gmv,

    ROUND(
        AVG(CASE
            WHEN order_status = 'Delivered'
            THEN order_value
        END),
        2
    ) AS aov

FROM orders
GROUP BY payment_method;

-- 12. Daily Demand Performance

CREATE OR REPLACE VIEW vw_daily_performance AS
SELECT
    order_date,

    DAYNAME(order_date) AS day_of_week,

    COUNT(*) AS total_orders,

    SUM(order_status = 'Delivered') AS delivered_orders,

    SUM(order_status = 'Cancelled') AS cancelled_orders,

    SUM(order_status = 'Rejected') AS rejected_orders,

    ROUND(
        SUM(CASE
            WHEN order_status = 'Delivered'
            THEN order_value
            ELSE 0
        END),
        2
    ) AS gmv

FROM orders
GROUP BY
    order_date,
    DAYNAME(order_date)

ORDER BY order_date;