# sql-fundamental

✅ 1. Full SQL Learning Roadmap (PostgreSQL)

Here is a clean checklist — if you know everything here, your SQL foundation is very strong.

# A. SQL Basics

- SELECT, FROM
- WHERE (operators: =, <, >, BETWEEN, LIKE, ILIKE, IN)
- ORDER BY
- LIMIT / OFFSET
- DISTINCT
- Aliasing (AS)

# B. Joins (Core for Data Engineer)
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- FULL OUTER JOIN
- CROSS JOIN
- SELF JOIN
- USING() vs ON
- Multiple joins, join ordering

# C. Aggregations
- GROUP BY
- HAVING
- aggregate functions: COUNT, SUM, AVG, MIN, MAX
- GROUPING SETS
- ROLLUP
- CUBE

# D. Subqueries
- Scalar subquery
- Correlated subquery
- EXISTS / NOT EXISTS
- IN vs EXISTS performance differences
- LATERAL JOIN (Postgres superpower)

# E. Window Functions (Must-have for Data Engineers)
- OVER(), PARTITION BY, ORDER BY
- ROW_NUMBER, RANK, DENSE_RANK
- LAG, LEAD
- MOVING AVERAGE, RUNNING TOTAL
- FRAME clauses (ROWS BETWEEN …)

# F. Data Modeling
- Primary key
- Foreign key
- UNIQUE
- CHECK
- Many-to-many
- Composite keys
- Normal forms (1NF → 3NF)

# G. PostgreSQL-Specific
- TEXT vs VARCHAR
- JSON & JSONB
- Arrays
- ENUM
- HSTORE
- UPSERT (INSERT ON CONFLICT DO)
- RETURNING clause
- Materialized Views

# H. Indexing (Deep)
- B-tree
- Hash
- GIN
- GiST
- BRIN
- Composite indexes
- Partial indexes
- COVERING indexes
- Index-only scans
- EXPLAIN / EXPLAIN ANALYZE
- Vacuum, Autovacuum

# I. Advanced Query Techniques
- CTEs
- Recursive CTEs
- PIVOT / UNPIVOT patterns
- Full-text search
- Query tuning

# J. Data Engineering Essentials
- Partitioned tables (range, list)
- Time-series design
- ETL/ELT SQL
- Incremental loads
- CDC concepts
- DDL vs DML
- Transactions & isolation levels
- Lock types
- Bulk inserts (COPY)
