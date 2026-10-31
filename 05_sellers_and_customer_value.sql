-- Phase 5: Sellers and customer value

-- One row per order and seller (an order can have several sellers)
CREATE INDEX idx_items_order ON order_items (order_id(32));

CREATE TABLE order_seller AS
SELECT DISTINCT order_id, seller_id
FROM order_items;

CREATE INDEX idx_os_order ON order_seller (order_id(32));
CREATE INDEX idx_os_seller ON order_seller (seller_id(32));

SELECT COUNT(*) AS orders_with_multiple_sellers
FROM (
    SELECT order_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(DISTINCT seller_id) > 1
) t;

-- Worst sellers by late rate (minimum 50 orders)
SELECT os.seller_id,
       COUNT(*) AS delivered_orders,
       SUM(oc.is_late) AS late_orders,
       ROUND(100 * SUM(oc.is_late) / COUNT(*), 2) AS late_rate_pct,
       ROUND(AVG(oc.review_score), 2) AS avg_review
FROM order_seller os
JOIN orders_clean oc ON os.order_id = oc.order_id
WHERE oc.is_valid_delivery = 1
GROUP BY os.seller_id
HAVING COUNT(*) >= 50
ORDER BY late_rate_pct DESC
LIMIT 20;

-- Seller concentration: share of late orders vs share of all orders
WITH seller_stats AS (
    SELECT os.seller_id,
           COUNT(*) AS delivered_orders,
           SUM(oc.is_late) AS late_orders
    FROM order_seller os
    JOIN orders_clean oc ON os.order_id = oc.order_id
    WHERE oc.is_valid_delivery = 1
    GROUP BY os.seller_id
),
ranked AS (
    SELECT seller_id, delivered_orders, late_orders,
           ROW_NUMBER() OVER (ORDER BY late_orders DESC, seller_id) AS rnk,
           SUM(late_orders) OVER (ORDER BY late_orders DESC, seller_id
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_late,
           SUM(delivered_orders) OVER (ORDER BY late_orders DESC, seller_id
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_orders,
           SUM(late_orders) OVER () AS total_late,
           SUM(delivered_orders) OVER () AS total_orders
    FROM seller_stats
)
SELECT rnk,
       ROUND(100 * cum_late / total_late, 1)     AS cum_share_of_late_pct,
       ROUND(100 * cum_orders / total_orders, 1) AS cum_share_of_orders_pct,
       ROUND(100 * cum_late / cum_orders, 2)     AS group_late_rate_pct,
       ROUND(100 * total_late / total_orders, 2) AS overall_late_rate_pct
FROM ranked
WHERE rnk IN (10, 20, 50, 100, 200)
ORDER BY rnk;

-- Order value (payments summed per order) and customer value
CREATE TABLE order_value AS
SELECT order_id, SUM(payment_value) AS order_value
FROM payments
GROUP BY order_id;

CREATE INDEX idx_ov_order ON order_value (order_id(32));

CREATE TABLE customer_value AS
SELECT oc.customer_unique_id,
       COUNT(*) AS orders,
       SUM(ov.order_value) AS total_value
FROM orders_clean oc
LEFT JOIN order_value ov ON oc.order_id = ov.order_id
WHERE oc.order_status NOT IN ('canceled', 'unavailable')
GROUP BY oc.customer_unique_id;

-- Repeat vs one-time customers: value and share of revenue
SELECT CASE WHEN orders >= 2 THEN 'repeat' ELSE 'one-time' END AS segment,
       COUNT(*) AS customers,
       ROUND(AVG(total_value), 2) AS avg_value_per_customer,
       ROUND(SUM(total_value) / SUM(orders), 2) AS avg_value_per_order,
       ROUND(SUM(total_value), 0) AS total_value,
       ROUND(100 * SUM(total_value) / SUM(SUM(total_value)) OVER (), 1) AS share_of_revenue_pct
FROM customer_value
GROUP BY segment;

-- Revenue by customer spend decile
SELECT decile,
       COUNT(*) AS customers,
       ROUND(MIN(total_value), 0) AS min_spend,
       ROUND(SUM(total_value), 0) AS group_value,
       ROUND(100 * SUM(total_value) / SUM(SUM(total_value)) OVER (), 1) AS share_of_revenue_pct
FROM (
    SELECT customer_unique_id, total_value,
           NTILE(10) OVER (ORDER BY total_value DESC) AS decile
    FROM customer_value
    WHERE total_value IS NOT NULL
) t
GROUP BY decile
ORDER BY decile;

-- Late rate and review by spend decile
WITH d AS (
    SELECT customer_unique_id,
           NTILE(10) OVER (ORDER BY total_value DESC) AS decile
    FROM customer_value
    WHERE total_value IS NOT NULL
)
SELECT d.decile,
       COUNT(*) AS delivered_orders,
       ROUND(100 * SUM(oc.is_late) / COUNT(*), 2) AS late_rate_pct,
       ROUND(AVG(oc.review_score), 2) AS avg_review
FROM orders_clean oc
JOIN d ON oc.customer_unique_id = d.customer_unique_id
WHERE oc.is_valid_delivery = 1
GROUP BY d.decile
ORDER BY d.decile;
