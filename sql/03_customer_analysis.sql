-- ============================================================
-- 03_CUSTOMER_ANALYSIS.SQL
-- Food Delivery Growth & Operations Analytics
-- ============================================================

-- 1. Customer order frequency distribution

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(*) AS delivered_orders
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)

SELECT
    delivered_orders,
    COUNT(*) AS customers,
    ROUND(
        100 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM customer_orders
GROUP BY delivered_orders
ORDER BY delivered_orders;

-- 2. Customer spending distribution

WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(
            CASE
                WHEN order_status = 'Delivered' THEN order_value
                ELSE 0
            END
        ) AS total_spend
    FROM orders
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN total_spend < 2000 THEN 'Below ₹2K'
        WHEN total_spend < 4000 THEN '₹2K–4K'
        WHEN total_spend < 6000 THEN '₹4K–6K'
        WHEN total_spend < 8000 THEN '₹6K–8K'
        ELSE '₹8K+'
    END AS spending_band,
    COUNT(*) AS customers,
    ROUND(AVG(total_spend), 2) AS avg_customer_spend
FROM customer_spend
GROUP BY
    CASE
        WHEN total_spend < 2000 THEN 'Below ₹2K'
        WHEN total_spend < 4000 THEN '₹2K–4K'
        WHEN total_spend < 6000 THEN '₹4K–6K'
        WHEN total_spend < 8000 THEN '₹6K–8K'
        ELSE '₹8K+'
    END
ORDER BY avg_customer_spend;

-- 3. Repeat vs one-time customers

WITH customer_orders AS (
    SELECT
        c.customer_id,
        COUNT(
            CASE
                WHEN o.order_status = 'Delivered' THEN o.order_id
            END
        ) AS delivered_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
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

-- 4. Customer value by acquisition channel

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(
        CASE
            WHEN o.order_status = 'Delivered' THEN o.order_id
        END
    ) AS delivered_orders,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Delivered' THEN o.order_value
                ELSE 0
            END
        ), 2
    ) AS total_gmv,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Delivered' THEN o.order_value
                ELSE 0
            END
        ) / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS gmv_per_customer
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.acquisition_channel
ORDER BY gmv_per_customer DESC;

-- 5. Customer value by city

SELECT
    c.city,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(
        CASE
            WHEN o.order_status = 'Delivered' THEN o.order_id
        END
    ) AS delivered_orders,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Delivered' THEN o.order_value
                ELSE 0
            END
        ), 2
    ) AS total_gmv,
    ROUND(
        SUM(
            CASE
                WHEN o.order_status = 'Delivered' THEN o.order_value
                ELSE 0
            END
        ) / NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS gmv_per_customer
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY gmv_per_customer DESC;

-- 6. Customer recency analysis

WITH customer_recency AS (
    SELECT
        c.customer_id,
        MAX(
            CASE
                WHEN o.order_status = 'Delivered'
                THEN o.order_date
            END
        ) AS last_order_date
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)

SELECT
    CASE
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 30
            THEN '0–30 days'
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 90
            THEN '31–90 days'
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 180
            THEN '91–180 days'
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 365
            THEN '181–365 days'
        ELSE '365+ days'
    END AS recency_band,
    COUNT(*) AS customers
FROM customer_recency
WHERE last_order_date IS NOT NULL
GROUP BY
    CASE
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 30
            THEN '0–30 days'
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 90
            THEN '31–90 days'
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 180
            THEN '91–180 days'
        WHEN DATEDIFF('2026-06-30', last_order_date) <= 365
            THEN '181–365 days'
        ELSE '365+ days'
    END
ORDER BY
    MIN(DATEDIFF('2026-06-30', last_order_date));
    
-- 7. Customer frequency analysis

WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(*) AS delivered_orders
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN delivered_orders = 1 THEN '1 order'
        WHEN delivered_orders BETWEEN 2 AND 5 THEN '2–5 orders'
        WHEN delivered_orders BETWEEN 6 AND 10 THEN '6–10 orders'
        WHEN delivered_orders BETWEEN 11 AND 15 THEN '11–15 orders'
        ELSE '16+ orders'
    END AS frequency_band,
    COUNT(*) AS customers,
    ROUND(AVG(delivered_orders), 2) AS avg_orders_per_customer
FROM customer_frequency
GROUP BY
    CASE
        WHEN delivered_orders = 1 THEN '1 order'
        WHEN delivered_orders BETWEEN 2 AND 5 THEN '2–5 orders'
        WHEN delivered_orders BETWEEN 6 AND 10 THEN '6–10 orders'
        WHEN delivered_orders BETWEEN 11 AND 15 THEN '11–15 orders'
        ELSE '16+ orders'
    END
ORDER BY
    MIN(delivered_orders);
    
-- 8. Customer monetary analysis

WITH customer_spend AS (
    SELECT
        customer_id,
        SUM(
            CASE
                WHEN order_status = 'Delivered'
                THEN order_value
                ELSE 0
            END
        ) AS total_spend
    FROM orders
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN total_spend < 2000 THEN 'Below ₹2K'
        WHEN total_spend < 4000 THEN '₹2K–4K'
        WHEN total_spend < 6000 THEN '₹4K–6K'
        WHEN total_spend < 8000 THEN '₹6K–8K'
        ELSE '₹8K+'
    END AS monetary_band,
    COUNT(*) AS customers,
    ROUND(SUM(total_spend), 2) AS total_customer_value,
    ROUND(AVG(total_spend), 2) AS avg_customer_spend
FROM customer_spend
GROUP BY
    CASE
        WHEN total_spend < 2000 THEN 'Below ₹2K'
        WHEN total_spend < 4000 THEN '₹2K–4K'
        WHEN total_spend < 6000 THEN '₹4K–6K'
        WHEN total_spend < 8000 THEN '₹6K–8K'
        ELSE '₹8K+'
    END
ORDER BY avg_customer_spend;

-- 9. RFM customer segmentation

WITH rfm AS (
    SELECT
        customer_id,

        DATEDIFF(
            '2026-06-30',
            MAX(CASE
                WHEN order_status = 'Delivered'
                THEN order_date
            END)
        ) AS recency_days,

        COUNT(CASE
            WHEN order_status = 'Delivered'
            THEN order_id
        END) AS frequency,

        SUM(CASE
            WHEN order_status = 'Delivered'
            THEN order_value
            ELSE 0
        END) AS monetary
    FROM orders
    GROUP BY customer_id
),

scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm
)

SELECT
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4
            THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'
        ELSE 'Others'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(monetary), 2) AS avg_customer_spend
FROM scores
GROUP BY
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4
            THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'
        ELSE 'Others'
    END
ORDER BY customers DESC;

-- 9. RFM customer segmentation

WITH rfm AS (
    SELECT
        customer_id,

        DATEDIFF(
            '2026-06-30',
            MAX(CASE
                WHEN order_status = 'Delivered'
                THEN order_date
            END)
        ) AS recency_days,

        COUNT(CASE
            WHEN order_status = 'Delivered'
            THEN order_id
        END) AS frequency,

        SUM(CASE
            WHEN order_status = 'Delivered'
            THEN order_value
            ELSE 0
        END) AS monetary
    FROM orders
    GROUP BY customer_id
),

scores AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM rfm
)

SELECT
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4
            THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'
        ELSE 'Others'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(monetary), 2) AS avg_customer_spend
FROM scores
GROUP BY
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4
            THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'
        ELSE 'Others'
    END
ORDER BY customers DESC;

-- 10. Top 20 high-value customers

SELECT
    c.customer_id,
    c.city,
    c.age_group,
    c.acquisition_channel,
    COUNT(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS total_spend,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS aov
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.city,
    c.age_group,
    c.acquisition_channel
HAVING delivered_orders > 0
ORDER BY total_spend DESC
LIMIT 20;

-- 11. RFM segment value

WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            '2026-06-30',
            MAX(CASE
                WHEN order_status = 'Delivered' THEN order_date
            END)
        ) AS recency_days,
        COUNT(CASE
            WHEN order_status = 'Delivered' THEN order_id
        END) AS frequency,
        SUM(CASE
            WHEN order_status = 'Delivered' THEN order_value
            ELSE 0
        END) AS monetary
    FROM orders
    GROUP BY customer_id
),

scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency) AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM customer_rfm
)

SELECT
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4
            THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'
        ELSE 'Others'
    END AS customer_segment,
    COUNT(*) AS customers,
    ROUND(SUM(monetary), 2) AS total_segment_value,
    ROUND(AVG(monetary), 2) AS avg_customer_value
FROM scored
GROUP BY
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4
            THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3
            THEN 'Loyal Customers'
        WHEN r_score >= 4
            THEN 'Recent Customers'
        WHEN r_score <= 2 AND f_score >= 3
            THEN 'At Risk'
        ELSE 'Others'
    END
ORDER BY total_segment_value DESC;

-- 12. Customer lifetime activity

SELECT
    c.customer_id,
    c.city,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    MIN(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_date
    END) AS first_order_date,
    MAX(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_date
    END) AS last_order_date,
    DATEDIFF(
        MAX(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_date
        END),
        MIN(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_date
        END)
    ) AS customer_lifetime_days,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered' THEN o.order_value
            ELSE 0
        END), 2
    ) AS total_spend
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.city
HAVING delivered_orders > 0
ORDER BY total_spend DESC;

-- 13. Customers with declining recent activity

WITH customer_activity AS (
    SELECT
        customer_id,

        SUM(CASE
            WHEN order_status = 'Delivered'
             AND order_date >= '2026-04-01'
             AND order_date <= '2026-06-30'
            THEN 1 ELSE 0
        END) AS recent_orders,

        SUM(CASE
            WHEN order_status = 'Delivered'
             AND order_date >= '2026-01-01'
             AND order_date < '2026-04-01'
            THEN 1 ELSE 0
        END) AS previous_orders

    FROM orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    previous_orders,
    recent_orders,
    previous_orders - recent_orders AS order_decline
FROM customer_activity
WHERE previous_orders > recent_orders
ORDER BY order_decline DESC;