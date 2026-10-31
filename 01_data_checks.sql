-- Phase 1: Understand the data
-- Run one statement at a time.

-- 1. Order status counts
SELECT order_status,
       COUNT(*) AS status_count
FROM orders
GROUP BY order_status;

-- 2. Date range
SELECT MIN(order_purchase_timestamp) AS min_orderdate,
       MAX(order_purchase_timestamp) AS max_orderdate
FROM orders;

-- 3. customer_id vs customer_unique_id
-- customer_id is created per order; customer_unique_id identifies the real person
SELECT COUNT(DISTINCT customer_id)        AS distinct_customer_id,
       COUNT(DISTINCT customer_unique_id) AS distinct_unique_id
FROM customers;

-- 4. NULL checks in orders
SELECT COUNT(*) AS total_orders,
       COUNT(*) - COUNT(order_approved_at)               AS null_approved,
       COUNT(*) - COUNT(order_delivered_carrier_date)    AS null_carrier,
       COUNT(*) - COUNT(order_delivered_customer_date)   AS null_delivered,
       COUNT(*) - COUNT(order_estimated_delivery_date)   AS null_estimated
FROM orders;

-- 5. NULL delivery dates by status
SELECT order_status,
       COUNT(*) AS total_orders,
       COUNT(*) - COUNT(order_delivered_customer_date) AS null_delivery_date
FROM orders
GROUP BY order_status;

-- 6. Duplicate reviews
SELECT COUNT(*) AS orders_with_multiple_reviews
FROM (
    SELECT order_id
    FROM order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1
) t;

SELECT COUNT(*) AS orders_with_different_scores
FROM (
    SELECT order_id
    FROM order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1
       AND MIN(review_score) <> MAX(review_score)
) t;
