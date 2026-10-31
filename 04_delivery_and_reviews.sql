-- Phase 4: Does late delivery hurt reviews, and where?

-- Average review and bad review share, late vs on time
SELECT is_late,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review_score,
       SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
       ROUND(100 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(review_score), 1) AS pct_bad
FROM orders_clean
WHERE is_valid_delivery = 1
GROUP BY is_late;

-- Late rate by state
SELECT customer_state,
       COUNT(*) AS delivered_orders,
       SUM(is_late) AS late_orders,
       ROUND(100 * SUM(is_late) / COUNT(*), 2) AS late_rate_pct,
       ROUND(100 * SUM(is_late) / SUM(SUM(is_late)) OVER (), 1) AS share_of_all_late_pct,
       ROUND(AVG(review_score), 2) AS avg_review
FROM orders_clean
WHERE is_valid_delivery = 1
GROUP BY customer_state
ORDER BY late_rate_pct DESC;

-- Does the review gap hold inside each state? (states with 1,000+ orders)
SELECT customer_state,
       COUNT(*) AS delivered_orders,
       SUM(is_late) AS late_orders,
       ROUND(AVG(CASE WHEN is_late = 0 THEN review_score END), 2) AS avg_review_on_time,
       ROUND(AVG(CASE WHEN is_late = 1 THEN review_score END), 2) AS avg_review_late
FROM orders_clean
WHERE is_valid_delivery = 1
GROUP BY customer_state
HAVING COUNT(*) >= 1000
ORDER BY avg_review_late;

-- Review score by delay bucket
SELECT CASE
           WHEN days_vs_estimate <= -8 THEN '1) 8+ days early'
           WHEN days_vs_estimate BETWEEN -7 AND -1 THEN '2) 1-7 days early'
           WHEN days_vs_estimate = 0 THEN '3) on promised day'
           WHEN days_vs_estimate BETWEEN 1 AND 3 THEN '4) 1-3 days late'
           WHEN days_vs_estimate BETWEEN 4 AND 7 THEN '5) 4-7 days late'
           WHEN days_vs_estimate BETWEEN 8 AND 14 THEN '6) 8-14 days late'
           ELSE '7) 15+ days late'
       END AS delivery_bucket,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review,
       ROUND(100 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(review_score), 1) AS pct_bad
FROM orders_clean
WHERE is_valid_delivery = 1
GROUP BY delivery_bucket
ORDER BY delivery_bucket;
