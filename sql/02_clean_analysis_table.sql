-- Phase 2: Clean the data and build the analysis table (one row per order)
-- Run one statement at a time. Do not re-run a slow query while it is still running.

-- Indexes on the join columns (needed for speed)
CREATE INDEX idx_orders_order_id ON orders (order_id(32));
CREATE INDEX idx_orders_customer_id ON orders (customer_id(32));
CREATE INDEX idx_customers_customer_id ON customers (customer_id(32));
CREATE INDEX idx_reviews_order_id ON order_reviews (order_id(32));

-- Keep one review per order (the latest)
CREATE VIEW reviews_clean AS
SELECT order_id, review_id, review_score, review_answer_timestamp
FROM (
    SELECT order_id, review_id, review_score, review_answer_timestamp,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY CAST(review_answer_timestamp AS DATETIME) DESC, review_id DESC
           ) AS rn
    FROM order_reviews
) ranked
WHERE rn = 1;

-- Save it as a real table (a view is recalculated every time it is used)
CREATE TABLE reviews_final AS
SELECT order_id, review_id, review_score, review_answer_timestamp
FROM reviews_clean;

CREATE INDEX idx_reviews_final_order_id ON reviews_final (order_id(32));

-- The analysis table
CREATE TABLE orders_clean AS
SELECT
    o.order_id,
    o.order_status,
    c.customer_unique_id,
    c.customer_state,
    r.review_score,
    CAST(o.order_purchase_timestamp AS DATETIME)        AS purchase_ts,
    CAST(o.order_delivered_customer_date AS DATETIME)   AS delivered_ts,
    CAST(o.order_estimated_delivery_date AS DATETIME)   AS estimated_ts,
    DATEDIFF(CAST(o.order_delivered_customer_date AS DATETIME),
             CAST(o.order_purchase_timestamp AS DATETIME))   AS delivery_days,
    DATEDIFF(CAST(o.order_delivered_customer_date AS DATETIME),
             CAST(o.order_estimated_delivery_date AS DATETIME)) AS days_vs_estimate,
    CASE WHEN o.order_status = 'delivered'
              AND o.order_delivered_customer_date IS NOT NULL
         THEN 1 ELSE 0 END AS is_valid_delivery,
    CASE WHEN o.order_status = 'delivered'
              AND o.order_delivered_customer_date IS NOT NULL
         THEN CASE WHEN DATEDIFF(
                  CAST(o.order_delivered_customer_date AS DATETIME),
                  CAST(o.order_estimated_delivery_date AS DATETIME)) > 0
                   THEN 1 ELSE 0 END
    END AS is_late
FROM orders AS o
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
LEFT JOIN reviews_final AS r ON o.order_id = r.order_id;

CREATE INDEX idx_clean_order_id ON orders_clean (order_id(32));
CREATE INDEX idx_clean_customer ON orders_clean (customer_unique_id(32));
CREATE INDEX idx_clean_state ON orders_clean (customer_state(2));

-- Validation checks (expected: 99,441 / 96,470 / 89,936 late=0, 6,534 late=1, 2,971 NULL)
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_orders
FROM orders_clean;

SELECT SUM(is_valid_delivery) AS valid_deliveries FROM orders_clean;

SELECT is_late, COUNT(*) AS orders FROM orders_clean GROUP BY is_late;

-- Why NULL and not 0 for "not applicable": 0 would count undelivered orders as on time
SELECT AVG(is_late) AS late_rate_with_null,
       AVG(COALESCE(is_late, 0)) AS late_rate_if_null_were_zero
FROM orders_clean;
