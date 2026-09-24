-- 1. Total revenue by day.
SELECT EXTRACT('DAY' FROM o.order_time) AS order_day, SUM(oi.quantity * oi.unit_price)
FROM fact_order o
INNER JOIN fact_order_item oi ON o.order_sk = oi.order_sk
GROUP BY EXTRACT('DAY' FROM o.order_time)


-- 2. Top 3 best-selling products each week (by quantity sold).
SELECT * 
FROM( 
  SELECT sub.week, sub.product_sk, DENSE_RANK() OVER(PARTITION BY week ORDER BY sub.total_quantity DESC) AS ranking
  FROM (
    SELECT EXTRACT('WEEK' FROM o.order_time) AS week, product_sk, SUM(oi.quantity) AS total_quantity
    FROM fact_order o
    INNER JOIN fact_order_item oi ON o.order_sk = oi.order_sk
    GROUP BY EXTRACT('WEEK' FROM o.order_time), product_sk
  ) AS sub
)
WHERE ranking <= 3;


-- 3. Payment success rate (paid orders / total orders).
SELECT COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM fact_order o INNER JOIN fact_order_payment op ON o.order_sk = op.order_sk) AS success_rate
FROM fact_order o
INNER JOIN fact_order_payment op ON o.order_sk = op.order_sk
WHERE op.status = 'SUCCESS'

