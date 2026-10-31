# Olist E-Commerce: Delivery and Retention Analysis

**Tools:** MySQL, Python (pandas, SQLAlchemy, statsmodels), Power BI

A self-initiated learning project on a public dataset. It is written as if I were an analyst answering a manager's question. All impact figures are **estimates from this dataset**, not real company results.

---

## 1. The business question

> The Head of Growth says: "We spend a lot to acquire customers, but few come back. Should the next budget go to ads, delivery, or weak sellers?"

I turned this into two questions:

1. **Do customers come back to buy again?**
2. **Does late delivery hurt reviews and repeat purchases, and where is the problem concentrated?**

The dataset has no advertising cost data, so I could not compare delivery against ads. I say this again in the limitations.

## 2. Short answer

- **Customers rarely return.** Only 3.04% placed a second order.
- **Late delivery badly hurts reviews.** 62.4% of late orders got 1 or 2 stars, against 9.3% of on-time orders.
- **Late delivery's effect on repeat buying is not confirmed.** A significance test could not separate it from chance (p = 0.14).
- **Lateness is spread out**, not caused by one region or seller. RJ and the largest sellers are the best places to start.

## 3. Dataset

[Brazilian E-Commerce Public Dataset by Olist (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce): about 99,000 orders from Sept 2016 to Oct 2018, in 9 linked tables (orders, customers, order_items, order_reviews, payments, products, sellers, geolocation, category translation).

The data files are not included in this repo. Download them from Kaggle and place them in a `data/` folder.

## 4. Repository structure

```
olist-delivery-retention-analysis/
├── README.md
├── sql/                 queries from this README, in order
├── python/
│   ├── load_to_mysql.py
│   ├── export_data.py
│   └── stats_check.py
├── dashboard/           Power BI file and screenshot
└── memo/                one-page recommendation memo
```

## 5. How the project was built

| Phase | What I did | Result |
|---|---|---|
| 1 | Understood the data and checked it for traps | Found the customer ID trap, NULL delivery dates, duplicate reviews |
| 2 | Cleaned the data and built one analysis table | `orders_clean`: one row per order, 99,441 rows |
| 3 | Measured repeat purchases | 3.04% repeat rate, cohorts, 90-day comparison |
| 4 | Studied late delivery and reviews | Strong effect on reviews, holds across states |
| 5 | Looked at sellers and customer value | Lateness spread across sellers; revenue concentrated in big spenders |
| 6 | Wrote recommendations | Three recommendations with trade-offs |
| 7 | Dashboard, memo, README | Power BI dashboard and this README |

---

## 6. Key findings

### Retention

| Metric | Value |
|---|---|
| Customers (unique people) | 96,096 |
| Repeat customers, all orders | 2,997 (3.12%) |
| Repeat customers, excluding canceled and unavailable orders | 2,888 of 94,990 (**3.04%**) |
| Customers with exactly 2 orders | 2,745 (about 92% of repeat customers) |
| Customers with 3 or more orders | 252 (0.26%) |
| Revenue from repeat customers | 5.7% |

Early-2017 cohorts returned at about 4 to 5%. Later cohorts look lower mostly because they had less time to return.

### Delivery and reviews

| Metric | On time or early | Late |
|---|---|---|
| Orders | 89,936 | 6,534 (6.77%) |
| Average review | 4.29 | 2.27 |
| Share of 1 to 2 star reviews | 9.3% | **62.4%** |

- Late orders are 6.8% of deliveries but about **32%** of all bad reviews.
- The review score falls steadily as the delay grows. The sharpest drop is between 1 to 3 days late (32% bad reviews) and 4 to 7 days late (68%).
- Orders 4 or more days late are **71%** of all late orders.
- The late vs on-time review gap holds in **all 12 states** with 1,000 or more orders (gap of 1.6 to 2.3 points), so it is not just a state effect.
- 74% of orders arrive 8 or more days before the promised date, so the delivery estimates look padded.

### Retention effect of late delivery

| First order | Customers | Returned within 90 days |
|---|---|---|
| On time | 69,650 | 2.32% |
| Late | 5,690 | 2.02% |

Two-proportion z-test: z = -1.461, **p = 0.144**. The gap is not statistically convincing, and the late group is small. This does not prove there is no effect, only that this data cannot confirm one.

### Where the problem is

| Area | Finding |
|---|---|
| RJ | 12.11% late rate (SP: 4.49%), 22.9% of all late orders |
| SP | 27.9% of late orders only because it is the biggest state |
| Northeast | High late rates (AL 21.4%, MA 17.4%, SE 15.2%) but small volumes |
| Top 100 sellers by late orders | 42.0% of orders, 50.5% of late orders, late rate 8.05% vs 6.69% overall |
| Top 20 sellers by late rate | Only about 6% of late orders |

### Customer value

- The top 10% of customers bring in 38.3% of revenue.
- Repeat customers spend about 10% less per order than one-time customers (145.87 vs 161.22 BRL).
- Higher-spending customers get late deliveries slightly more often (7.87% in the top decile vs 5.47% in the bottom).

---

## 7. Recommendations

1. **Treat low repeat buying as its own problem.** The data does not show that fixing delivery will bring customers back. Test retention ideas directly with a small A/B test. Each extra percentage point of repeat rate is about 950 customers, roughly 1% of revenue (estimate).
2. **Fix severe delays first, starting with RJ and the northeast.** If RJ reached SP's late rate, there would be about 940 fewer late orders and roughly 500 fewer bad reviews (estimate). The case for this is satisfaction and reputation, not repeat sales.
3. **Monitor the largest sellers instead of removing them.** Bringing the top 100 sellers down to the average would avoid about 550 late orders (estimate). This overlaps with recommendation 2, so the two should not be added together.

## 8. Limitations

- **No ad cost data**, so delivery cannot be compared with ads.
- **Correlation, not proven cause.** The link between lateness and reviews is strong and consistent, but seller quality, product type and distance were not controlled for.
- **Short window.** The data covers about 2 years, and later customers had little time to return.
- **Selection effect.** Sellers were chosen because they had many late orders, so part of their lateness is chance.
- **Multi-seller orders** (1,278 orders) count against every seller involved.
- **Payment value includes freight** and is in Brazilian reais.
- **Scenario numbers** assume the improvements are achievable, which I did not test.

## 9. What I would do next

- Analyse freight and distance to see why RJ is slow.
- Check whether bulky products explain why top spenders get more late deliveries.
- Test whether longer delivery promises in slow regions reduce bad reviews, and what they do to sales.
- Use a longer follow-up window for repeat purchases.

---

## 10. Dashboard

![Dashboard](dashboard/dashboard.png)

*(Screenshot to be added.)* The Power BI page has four cards (delivered orders, late rate, average review, repeat rate), a state slicer, and charts for review by delivery delay, bad review rate (late vs on time), late rate by state, and late orders by state.

<details>
<summary>Power BI measures and columns (DAX)</summary>

```
Delivered Orders = SUM(orders_clean[is_valid_delivery])

Late Rate = DIVIDE(SUM(orders_clean[is_late]), [Delivered Orders])

Late Orders = SUM(orders_clean[is_late])

Avg Review = CALCULATE(AVERAGE(orders_clean[review_score]), orders_clean[is_valid_delivery] = 1)

Repeat Rate = DIVIDE(
    CALCULATE(COUNTROWS(customer_value), customer_value[orders] >= 2),
    COUNTROWS(customer_value)
)

Bad Review Rate =
DIVIDE(
    CALCULATE(COUNTROWS(orders_clean),
              orders_clean[is_valid_delivery] = 1,
              orders_clean[review_score] <= 2),
    CALCULATE(COUNTROWS(orders_clean),
              orders_clean[is_valid_delivery] = 1,
              NOT(ISBLANK(orders_clean[review_score])))
)

Delivery Status =
SWITCH(orders_clean[is_late], 1, "Late", 0, "On time or early", BLANK())

Delivery Bucket =
SWITCH(
    TRUE(),
    orders_clean[is_valid_delivery] <> 1, BLANK(),
    orders_clean[days_vs_estimate] <= -8, "1) 8+ days early",
    orders_clean[days_vs_estimate] <= -1, "2) 1-7 days early",
    orders_clean[days_vs_estimate] = 0, "3) on promised day",
    orders_clean[days_vs_estimate] <= 3, "4) 1-3 days late",
    orders_clean[days_vs_estimate] <= 7, "5) 4-7 days late",
    orders_clean[days_vs_estimate] <= 14, "6) 8-14 days late",
    "7) 15+ days late"
)
```

</details>

---

## 11. Problems I faced and how I fixed them

| Problem | Cause | Fix |
|---|---|---|
| Repeat customers would have looked like zero | `customer_id` is generated per order; `customer_unique_id` identifies the real person | Used `customer_unique_id` for every customer-level count |
| Order counts inflated after a join | 547 orders have more than one review | Kept only the latest review per order with `ROW_NUMBER()` |
| Cannot do date math | Date columns were loaded as text | Converted with `CAST(... AS DATETIME)` in the clean table |
| Delivery and estimated dates were identical | A copy-paste slip: both columns read the delivered date. The row count still looked right | Looked at actual rows, not just counts, and fixed the source column |
| Late orders might be counted as on time | An order delivered at 3 pm on the promised day looked "late" by hours | Compared calendar dates with `DATEDIFF` |
| Canceled orders distorted the late rate | Using 0 for "not applicable" counted them as on time | Used NULL, so averages and counts skip them (6.77% vs 6.57% if 0 is used) |
| `Error 2013: Lost connection` | No indexes on join columns, and a view was recalculated on every use | Added indexes and saved the cleaned reviews as a real table |
| Nothing would run | Five copies of the same slow query were still running | `SHOW FULL PROCESSLIST`, then `KILL <id>`. Lesson: never re-run a slow query, check first |
| `Access denied for user` from Python | The new MySQL user had not been created correctly | Dropped and re-created the user, then re-ran the load |
| `cd` command failed in Git Bash | Git Bash treats a backslash differently from Command Prompt | Used a forward slash, or opened Command Prompt inside the folder |
| Late rate by month was misleading | Newer customers had less time to come back | Used a fixed 90-day window for everyone |
| Top 20 sellers by late rate looked bad but explained little | Small samples exaggerate rates | Ranked by number of late orders, and compared with each group's share of all orders |

### Lessons

1. Check the data before analysing it.
2. A column name does not always mean what you assume.
3. After every join, the row count must not change.
4. Counts can look right while the data is wrong, so look at real rows.
5. Use NULL for "not applicable", not 0.
6. A fair comparison needs the same time window for everyone.
7. "Not significant" means the data is too thin to tell, not that the effect is zero.

---

## 12. Setup

1. Install MySQL and create a database: `CREATE DATABASE olist;`
2. Create a user with access to it (replace the placeholder password):
   ```sql
   CREATE USER 'analyst'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD';
   GRANT ALL PRIVILEGES ON olist.* TO 'analyst'@'localhost';
   FLUSH PRIVILEGES;
   ```
3. Download the Kaggle CSV files into `data/`.
4. `pip install pandas sqlalchemy pymysql statsmodels`
5. Run `python python/load_to_mysql.py`, then the SQL sections below in order.

---

## 13. SQL

Run these in order. Run one statement at a time, and do not re-run a slow query while it is still running.

### Phase 1: Understand the data

<details>
<summary>Order status counts</summary>

```sql
SELECT order_status,
       COUNT(*) AS status_count
FROM orders
GROUP BY order_status;
```

</details>

<details>
<summary>Date range</summary>

```sql
SELECT MIN(order_purchase_timestamp) AS min_orderdate,
       MAX(order_purchase_timestamp) AS max_orderdate
FROM orders;
```

</details>

<details>
<summary>customer_id vs customer_unique_id</summary>

```sql
SELECT COUNT(DISTINCT customer_id)        AS distinct_customer_id,
       COUNT(DISTINCT customer_unique_id) AS distinct_unique_id
FROM customers;
```

</details>

<details>
<summary>NULL checks in orders</summary>

```sql
SELECT COUNT(*) AS total_orders,
       COUNT(*) - COUNT(order_approved_at)               AS null_approved,
       COUNT(*) - COUNT(order_delivered_carrier_date)    AS null_carrier,
       COUNT(*) - COUNT(order_delivered_customer_date)   AS null_delivered,
       COUNT(*) - COUNT(order_estimated_delivery_date)   AS null_estimated
FROM orders;
```

```sql
SELECT order_status,
       COUNT(*) AS total_orders,
       COUNT(*) - COUNT(order_delivered_customer_date) AS null_delivery_date
FROM orders
GROUP BY order_status;
```

</details>

<details>
<summary>Duplicate reviews</summary>

```sql
SELECT COUNT(*) AS orders_with_multiple_reviews
FROM (
    SELECT order_id
    FROM order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1
) t;
```

```sql
SELECT COUNT(*) AS orders_with_different_scores
FROM (
    SELECT order_id
    FROM order_reviews
    GROUP BY order_id
    HAVING COUNT(*) > 1
       AND MIN(review_score) <> MAX(review_score)
) t;
```

</details>

### Phase 2: Clean data and build the analysis table

<details>
<summary>Indexes (needed for speed)</summary>

```sql
CREATE INDEX idx_orders_order_id ON orders (order_id(32));
CREATE INDEX idx_orders_customer_id ON orders (customer_id(32));
CREATE INDEX idx_customers_customer_id ON customers (customer_id(32));
CREATE INDEX idx_reviews_order_id ON order_reviews (order_id(32));
```

</details>

<details>
<summary>One review per order (keep the latest)</summary>

```sql
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
```

```sql
CREATE TABLE reviews_final AS
SELECT order_id, review_id, review_score, review_answer_timestamp
FROM reviews_clean;

CREATE INDEX idx_reviews_final_order_id ON reviews_final (order_id(32));
```

</details>

<details>
<summary>The analysis table: orders_clean (one row per order)</summary>

```sql
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
```

</details>

<details>
<summary>Validation checks (expected: 99,441 / 96,470 / 89,936 / 6,534 / 2,971)</summary>

```sql
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_orders
FROM orders_clean;

SELECT SUM(is_valid_delivery) AS valid_deliveries FROM orders_clean;

SELECT is_late, COUNT(*) AS orders FROM orders_clean GROUP BY is_late;

SELECT AVG(is_late) AS late_rate_with_null,
       AVG(COALESCE(is_late, 0)) AS late_rate_if_null_were_zero
FROM orders_clean;
```

</details>

### Phase 3: Do customers come back?

<details>
<summary>Orders per customer (distribution)</summary>

```sql
SELECT counts AS orders_per_customer,
       COUNT(*) AS no_of_customers
FROM (
    SELECT customer_unique_id, COUNT(*) AS counts
    FROM orders_clean
    GROUP BY customer_unique_id
) t
GROUP BY counts
ORDER BY orders_per_customer ASC;
```

</details>

<details>
<summary>Repeat rate, excluding canceled and unavailable orders</summary>

```sql
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
```

</details>

<details>
<summary>Monthly cohorts</summary>

```sql
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
```

</details>

<details>
<summary>Late first order vs repeat purchase, 90-day window</summary>

```sql
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
```

</details>

### Phase 4: Late delivery and reviews

<details>
<summary>Average review and bad review share, late vs on time</summary>

```sql
SELECT is_late,
       COUNT(*) AS orders,
       ROUND(AVG(review_score), 2) AS avg_review_score,
       SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
       ROUND(100 * SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) / COUNT(review_score), 1) AS pct_bad
FROM orders_clean
WHERE is_valid_delivery = 1
GROUP BY is_late;
```

</details>

<details>
<summary>Late rate by state</summary>

```sql
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
```

</details>

<details>
<summary>Does the review gap hold inside each state?</summary>

```sql
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
```

</details>

<details>
<summary>Review score by delay bucket</summary>

```sql
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
```

</details>

### Phase 5: Sellers and customer value

<details>
<summary>One row per order and seller</summary>

```sql
CREATE INDEX idx_items_order ON order_items (order_id(32));

CREATE TABLE order_seller AS
SELECT DISTINCT order_id, seller_id
FROM order_items;

CREATE INDEX idx_os_order ON order_seller (order_id(32));
CREATE INDEX idx_os_seller ON order_seller (seller_id(32));
```

```sql
SELECT COUNT(*) AS orders_with_multiple_sellers
FROM (
    SELECT order_id
    FROM order_items
    GROUP BY order_id
    HAVING COUNT(DISTINCT seller_id) > 1
) t;
```

</details>

<details>
<summary>Worst sellers by late rate (minimum 50 orders)</summary>

```sql
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
```

</details>

<details>
<summary>Seller concentration: share of late orders vs share of all orders</summary>

```sql
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
```

</details>

<details>
<summary>Order value and customer value</summary>

```sql
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
```

</details>

<details>
<summary>Repeat vs one-time customers: value and share of revenue</summary>

```sql
SELECT CASE WHEN orders >= 2 THEN 'repeat' ELSE 'one-time' END AS segment,
       COUNT(*) AS customers,
       ROUND(AVG(total_value), 2) AS avg_value_per_customer,
       ROUND(SUM(total_value) / SUM(orders), 2) AS avg_value_per_order,
       ROUND(SUM(total_value), 0) AS total_value,
       ROUND(100 * SUM(total_value) / SUM(SUM(total_value)) OVER (), 1) AS share_of_revenue_pct
FROM customer_value
GROUP BY segment;
```

</details>

<details>
<summary>Revenue by customer spend decile</summary>

```sql
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
```

</details>

<details>
<summary>Late rate and review by spend decile</summary>

```sql
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
```

</details>

---

## 14. Python

<details>
<summary>load_to_mysql.py: load the CSV files into MySQL</summary>

```python
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine

user = "analyst"
password = "YOUR_PASSWORD"
host = "localhost"
port = 3306
database = "olist"

engine = create_engine(f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}")

data_dir = Path("data")

table_names = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "category_translation",
}

for file, table in table_names.items():
    df = pd.read_csv(data_dir / file)
    df.to_sql(table, engine, if_exists="replace", index=False, chunksize=10000)
    print(f"{table}: {len(df)} rows")
```

</details>

<details>
<summary>export_data.py: export two tables for Power BI</summary>

```python
import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine

engine = create_engine("mysql+pymysql://analyst:YOUR_PASSWORD@localhost:3306/olist")

Path("exports").mkdir(exist_ok=True)

for table in ["orders_clean", "customer_value"]:
    df = pd.read_sql(f"SELECT * FROM {table}", engine)
    df.to_csv(f"exports/{table}.csv", index=False)
    print(table, ":", len(df), "rows")
```

</details>

<details>
<summary>stats_check.py: is the retention gap real?</summary>

```python
from statsmodels.stats.proportion import proportions_ztest, proportion_confint

late_returned, late_total = 115, 5690
ontime_returned, ontime_total = 1618, 69650

z, p = proportions_ztest([late_returned, ontime_returned], [late_total, ontime_total])
print("z =", round(z, 3), " p-value =", round(p, 4))

for name, c, n in [("late first order", late_returned, late_total),
                   ("on-time first order", ontime_returned, ontime_total)]:
    low, high = proportion_confint(c, n, method="wilson")
    print(name, ":", round(100 * c / n, 2), "%  (95% range:",
          round(100 * low, 2), "to", round(100 * high, 2), "%)")
```

Output: `z = -1.461  p-value = 0.1441`. The late group's 95% range (1.69% to 2.42%) overlaps heavily with the on-time group's (2.21% to 2.44%).

</details>

---

## 15. Skills used

SQL (joins, CTEs, window functions, `CASE WHEN`, indexing), data validation, cohort and retention analysis, basic hypothesis testing in Python, Power BI (DAX measures, dashboard design), and writing a recommendation with trade-offs and limitations.
