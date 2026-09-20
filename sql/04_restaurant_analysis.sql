-- ============================================================
-- 04_RESTAURANT_ANALYSIS.SQL
-- Food Delivery Growth & Operations Analytics
-- ============================================================

-- 1. Overall restaurant performance

SELECT
    COUNT(DISTINCT r.restaurant_id) AS total_restaurants,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS total_gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS overall_aov,
    ROUND(
        AVG(r.rating), 2
    ) AS avg_restaurant_rating
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id;
    
-- 2. Restaurant performance by city

SELECT
    r.city,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS aov,
    ROUND(
        AVG(r.rating), 2
    ) AS avg_restaurant_rating
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY r.city
ORDER BY gmv DESC;
    
-- 3. Restaurant performance by cuisine

SELECT
    r.cuisine,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
    COUNT(CASE
        WHEN o.order_status = 'Delivered' THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
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

-- 4. Top 20 restaurants by GMV

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
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS aov
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating
ORDER BY gmv DESC
LIMIT 20;

-- 5. Top 20 restaurants by delivered order volume

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
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS aov
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating
ORDER BY delivered_orders DESC
LIMIT 20;

-- 6. Restaurant rating vs order volume

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
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
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
ORDER BY MIN(r.rating) DESC;

-- 7. Customer ratings received by restaurants

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating AS restaurant_rating,
    COUNT(CASE
        WHEN o.order_status = 'Delivered'
             AND o.rating > 0
        THEN o.order_id
    END) AS rated_orders,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
                 AND o.rating > 0
            THEN o.rating
        END), 2
    ) AS avg_customer_rating,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS aov
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating
HAVING rated_orders > 0
ORDER BY avg_customer_rating DESC;

-- 8. Restaurant order concentration

WITH restaurant_orders AS (
    SELECT
        r.restaurant_id,
        r.restaurant_name,
        COUNT(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_id
        END) AS delivered_orders
    FROM restaurants r
    LEFT JOIN orders o
        ON r.restaurant_id = o.restaurant_id
    GROUP BY
        r.restaurant_id,
        r.restaurant_name
)

SELECT
    CASE
        WHEN delivered_orders = 0 THEN '0 orders'
        WHEN delivered_orders BETWEEN 1 AND 100 THEN '1–100'
        WHEN delivered_orders BETWEEN 101 AND 200 THEN '101–200'
        WHEN delivered_orders BETWEEN 201 AND 300 THEN '201–300'
        ELSE '300+'
    END AS order_volume_band,
    COUNT(*) AS restaurants,
    SUM(delivered_orders) AS total_delivered_orders,
    ROUND(AVG(delivered_orders), 2) AS avg_orders_per_restaurant
FROM restaurant_orders
GROUP BY
    CASE
        WHEN delivered_orders = 0 THEN '0 orders'
        WHEN delivered_orders BETWEEN 1 AND 100 THEN '1–100'
        WHEN delivered_orders BETWEEN 101 AND 200 THEN '101–200'
        WHEN delivered_orders BETWEEN 201 AND 300 THEN '201–300'
        ELSE '300+'
    END
ORDER BY
    MIN(delivered_orders);
    
-- 9. Average order value by cuisine

SELECT
    r.cuisine,
    COUNT(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_id
    END) AS delivered_orders,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS average_order_value,
    ROUND(
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END), 2
    ) AS gmv
FROM restaurants r
JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY r.cuisine
ORDER BY average_order_value DESC;

-- 10. Restaurant performance by city and cuisine

SELECT
    r.city,
    r.cuisine,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
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
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS aov
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.city,
    r.cuisine
ORDER BY
    r.city,
    gmv DESC;
    
-- 11. High-rated restaurants with relatively low order volume

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating AS restaurant_rating,
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
    ) AS gmv
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating
HAVING
    r.rating >= 4.5
    AND delivered_orders < 150
ORDER BY
    r.rating DESC,
    delivered_orders;
    
-- 12. High-volume restaurants with lower ratings

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating AS restaurant_rating,
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
    ) AS gmv
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating
HAVING
    delivered_orders >= 200
    AND r.rating < 4.2
ORDER BY
    delivered_orders DESC;
    
-- 13. Highest-rated restaurants with sufficient order volume

SELECT
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating AS restaurant_rating,
    COUNT(CASE
        WHEN o.order_status = 'Delivered'
             AND o.rating > 0
        THEN o.order_id
    END) AS rated_orders,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
                 AND o.rating > 0
            THEN o.rating
        END), 2
    ) AS avg_customer_rating,
    COUNT(CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_id
    END) AS delivered_orders
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    r.restaurant_id,
    r.restaurant_name,
    r.city,
    r.cuisine,
    r.rating
HAVING rated_orders >= 20
ORDER BY avg_customer_rating DESC
LIMIT 20;

-- 14. Restaurant contribution to total GMV

WITH restaurant_gmv AS (
    SELECT
        r.restaurant_id,
        r.restaurant_name,
        SUM(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
            ELSE 0
        END) AS gmv
    FROM restaurants r
    LEFT JOIN orders o
        ON r.restaurant_id = o.restaurant_id
    GROUP BY
        r.restaurant_id,
        r.restaurant_name
),

total AS (
    SELECT SUM(gmv) AS total_gmv
    FROM restaurant_gmv
)

SELECT
    rg.restaurant_id,
    rg.restaurant_name,
    ROUND(rg.gmv, 2) AS gmv,
    ROUND(
        100 * rg.gmv / NULLIF(t.total_gmv, 0),
        2
    ) AS gmv_contribution_pct
FROM restaurant_gmv rg
CROSS JOIN total t
ORDER BY rg.gmv DESC
LIMIT 20;

-- 15. Restaurant cost-for-two vs performance

SELECT
    CASE
        WHEN r.cost_for_two < 400 THEN 'Below ₹400'
        WHEN r.cost_for_two < 700 THEN '₹400–700'
        WHEN r.cost_for_two < 1000 THEN '₹700–1000'
        ELSE '₹1000+'
    END AS cost_band,
    COUNT(DISTINCT r.restaurant_id) AS restaurants,
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
    ) AS gmv,
    ROUND(
        AVG(CASE
            WHEN o.order_status = 'Delivered'
            THEN o.order_value
        END), 2
    ) AS aov,
    ROUND(AVG(r.rating), 2) AS avg_restaurant_rating
FROM restaurants r
LEFT JOIN orders o
    ON r.restaurant_id = o.restaurant_id
GROUP BY
    CASE
        WHEN r.cost_for_two < 400 THEN 'Below ₹400'
        WHEN r.cost_for_two < 700 THEN '₹400–700'
        WHEN r.cost_for_two < 1000 THEN '₹700–1000'
        ELSE '₹1000+'
    END
ORDER BY MIN(r.cost_for_two);