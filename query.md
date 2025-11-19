# 🟦 PART 1 — SQL BASICS (30 Queries)

## 1.1 SELECT, WHERE, ORDER BY
```sql
-- 1. Get all users
SELECT * FROM users;

-- 2. Get user names only
SELECT name FROM users;

-- 3. Users created after a specific date
SELECT * FROM users WHERE created_at > '2024-01-01';

-- 4. Products costing more than 100
SELECT * FROM products WHERE price > 100;

-- 5. Products in electronics category, sorted by price descending
SELECT * FROM products
WHERE category = 'electronics'
ORDER BY price DESC;

-- 6. Case-insensitive search
SELECT * FROM products WHERE name ILIKE '%lap%';

```

## 1.2 DISTINCT, LIMIT, OFFSET

```sql
-- 7. Distinct categories
SELECT DISTINCT category FROM products;

-- 8. First 5 users
SELECT * FROM users LIMIT 5;

-- 9. Pagination: page 2 (limit 5)
SELECT * FROM users LIMIT 5 OFFSET 5;

```

## 1.3 Basic Functions

```sql
-- 10. Count all users
SELECT COUNT(*) FROM users;

-- 11. Average product price
SELECT AVG(price) FROM products;

-- 12. Latest order
SELECT * FROM orders ORDER BY created_at DESC LIMIT 1;

```

# # 🟦 PART 2 — JOINS (40 Queries)
## 2.1 Inner Join
```sql
-- 13. Orders with user names
SELECT o.id, u.name, o.total
FROM orders o
JOIN users u ON u.id = o.user_id;

```

## 2.2 Left Join

```sql
-- 14. Users with or without orders
SELECT u.name, o.id AS order_id
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

```

## 2.3 Right / Full

```sql
-- 15. Products that appear in orders
SELECT p.name, oi.order_id
FROM products p
RIGHT JOIN order_items oi ON oi.product_id = p.id;

-- 16. Full join user roles
SELECT *
FROM users u
FULL OUTER JOIN user_roles ur ON u.id = ur.user_id;


```

## 2.4 Using()

```sql
-- 17. Orders with their items
SELECT *
FROM orders
JOIN order_items USING(id);

```

## 2.5 Multi-Join

```sql
-- 18. User → Order → Order Item → Product
SELECT u.name, o.id AS order_id, p.name AS product, oi.quantity
FROM users u
JOIN orders o ON o.user_id = u.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON p.id = oi.product_id;

```

# # 🟦 PART 3 — AGGREGATIONS (30 Queries)
## 3.1 Group By
```sql
-- 19. Count of orders per user
SELECT user_id, COUNT(*) AS order_count
FROM orders
GROUP BY user_id;

```

## 3.2 Having
```sql
-- 20. Users with more than one order
SELECT user_id, COUNT(*)
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 1;

```

## 3.3 Rollup
```sql
-- 21. Sales total by category + summary
SELECT category, SUM(price)
FROM products
GROUP BY ROLLUP(category);

```

## 3.4 Grouping Sets
```sql
-- 22. Category totals and overall total
SELECT category, SUM(price)
FROM products
GROUP BY GROUPING SETS ( (category), () );

```

# 🟦 PART 4 — SUBQUERIES (20 Queries)

```sql
-- 23. Users who placed orders
SELECT *
FROM users
WHERE id IN (SELECT user_id FROM orders);

-- 24. Orders above average price
SELECT *
FROM orders
WHERE total > (SELECT AVG(total) FROM orders);

```

## Correlated Subquery
```sql

-- 25. Latest order for each user
SELECT *
FROM orders o1
WHERE created_at = (
  SELECT MAX(created_at)
  FROM orders o2
  WHERE o2.user_id = o1.user_id
);

```

## EXISTS
```sql
-- 26. Users who have roles
SELECT *
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM user_roles ur
  WHERE ur.user_id = u.id
);

```

#  🟦 PART 5 — WINDOW FUNCTIONS (40 Queries)

## Ranking
```sql
-- 27. Rank users by total order amount
SELECT u.name, SUM(o.total) AS spending,
       RANK() OVER (ORDER BY SUM(o.total) DESC)
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id;

```

## Row Number
```sql
-- 28. Get the first product created each day
SELECT *, ROW_NUMBER() OVER (PARTITION BY DATE(created_at) ORDER BY id)
FROM products;

```

## LAG / LEAD

```sql
-- 29. Compare each user's order to previous one
SELECT user_id, total,
       LAG(total) OVER (PARTITION BY user_id ORDER BY created_at) AS previous_total
FROM orders;

```

## Moving Average
```sql

-- 30. 3-order moving average
SELECT user_id, total,
       AVG(total) OVER (PARTITION BY user_id ORDER BY created_at ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
FROM orders;

```

# 🟦 PART 6 — POSTGRESQL FEATURES (30 Queries)

## JSONB
```sql
-- 31. Events with action=login
SELECT *
FROM events
WHERE event_data->>'action' = 'login';


-- 32. Get all keys inside event JSON
SELECT jsonb_object_keys(event_data) FROM events;

```

## Arrays
```sql

-- 33. Make array of all product names
SELECT ARRAY(SELECT name FROM products);

```

## Upsert
```sql
-- 34. Insert or update
INSERT INTO products (id, name, price)
VALUES (1, 'Laptop Pro', 1500)
ON CONFLICT(id) DO UPDATE SET price = EXCLUDED.price;

```

## Materialized View

```sql
-- 35. Create sales summary
CREATE MATERIALIZED VIEW sales_mv AS
SELECT user_id, SUM(total)
FROM orders
GROUP BY user_id;

REFRESH MATERIALIZED VIEW sales_mv;

```


# 🟦 PART 8 — DATA ENGINEERING SQL (40 Queries)

## Partitioned Tables
```sql
-- 39. Insert into logs (goes into correct partition)
INSERT INTO logs (id, ts, level, message)
VALUES (1, NOW(), 'info', 'app started');

```

## Time-Series Aggregation
```sql
-- 40. Daily log counts
SELECT DATE(ts) AS day, COUNT(*)
FROM logs
GROUP BY DATE(ts);

```

## ETL Transform
```sql
-- 41. Clean emails to lowercase (update batch)
UPDATE users SET email = LOWER(email);

```

## Incremental Load Pattern
```sql
-- 42. Get data changed in last 24h
SELECT *
FROM orders
WHERE created_at >= NOW() - INTERVAL '1 day';


```

## Deduplication

```sql

-- 43. Remove duplicates, keeping latest
DELETE FROM events e1
WHERE e1.id < (
  SELECT MAX(id)
  FROM events e2
  WHERE e2.event_data->>'action' = e1.event_data->>'action'
);

```

## SCD Type 2 Pattern

```sql
-- 44. Close old record
UPDATE products
SET price = 1000
WHERE id = 1;

```
## COPY (Fast Bulk Insert)

```sql
-- 45. Bulk load CSV
COPY products(name, price, category)
FROM '/data/products.csv'
CSV HEADER;

```