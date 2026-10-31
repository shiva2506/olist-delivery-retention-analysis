-- Phase 3: Do customers come back?

-- Orders per customer (distribution)
SELECT counts AS orders_per_customer,
       COUNT(*) AS no_of_customers
FROM (
    SELECT customer_unique_id, COUNT(*) AS counts
    FROM orders_clean
    GROUP BY customer_unique_id
) t
GROUP BY counts
ORDER BY orders_per_customer ASC;

-- Repeat rate, excluding canceled and unavailable orders
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN counts >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100 * SUM(CASE WHEN counts >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM (
    SELECT customer_unique_id, COUNT(*) AS counts
    FROM orders_clean
    WHERE order_status NOT IN ('canceled', 'unavailable')
    GROUP BY customer_unique_id
) t;

-- Monthly cohorts
SELECT DATE_FORMAT(purchase_ts, '%Y-%m') AS first_order_month,
       COUNT(*) AS customers,
       SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) AS came_back,
       ROUND(100 * SUM(CASE WHEN total_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM (
    SELECT customer_unique_id,
           purchase_ts,
           ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY purchase_ts, order_id) AS rn,
           COUNT(*) OVER (PARTITION BY customer_unique_id) AS total_orders
    FROM orders_clean
    WHERE order_status NOT IN ('canceled', 'unavailable')
) ranked
WHERE rn = 1
GROUP BY first_order_month
ORDER BY first_order_month;

-- Late first order vs repeat purchase, fixed 90-day window
CREATE TABLE customer_orders AS
SELECT customer_unique_id,
       MAX(CASE WHEN rn = 1 THEN purchase_ts END)        AS first_ts,
       MAX(CASE WHEN rn = 1 THEN is_late END)            AS first_late,
       MAX(CASE WHEN rn = 1 THEN is_valid_delivery END)  AS first_valid,
       MAX(CASE WHEN rn = 2 THEN purchase_ts END)        AS second_ts
FROM (
    SELECT customer_unique_id, purchase_ts, is_late, is_valid_delivery,
           ROW_NUMBER() OVER (PARTITION BY customer_unique_id ORDER BY purchase_ts, order_id) AS rn
    FROM orders_clean
    WHERE order_status NOT IN ('canceled', 'unavailable')
) ranked
GROUP BY customer_unique_id;

SELECT first_late,
       COUNT(*) AS customers,
       SUM(CASE WHEN second_ts <= DATE_ADD(first_ts, INTERVAL 90 DAY) THEN 1 ELSE 0 END) AS returned_within_90d,
       ROUND(100 * SUM(CASE WHEN second_ts <= DATE_ADD(first_ts, INTERVAL 90 DAY) THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_90d_pct
FROM customer_orders
WHERE first_valid = 1
  AND first_ts < '2018-06-01'
GROUP BY first_late;
