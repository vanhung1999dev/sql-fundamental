# 🧠 INTERNAL EXECUTION PIPELINE

```sql
SELECT department, COUNT(*) AS c
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) > 10;
```

## Internal pipeline:

#### Step 1 — WHERE filters raw rows
- Row-level filtering: only rows that satisfy salary > 50000 survive.

#### Step 2 — GROUP BY partitions rows
- Database builds hash tables or uses sort-based grouping.
- Each group maintains aggregate accumulators:
  - COUNT: integer counter
  - SUM: running sum
  - AVG: (sum, count) pair
  - etc.
 
#### Step 3 — Aggregate state finalized
- For each group, DB now has final values:
  - department = "Sales"
  - COUNT = 25
  - SUM = 340000
  - etc.

#### Step 4 — HAVING applies to the group output
- HAVING acts as a filter on aggregated output rows.
- Only groups whose post-aggregation state satisfies the condition remain.

# 🧬 WHAT HAPPENS TO HAVING IN OPTIMIZER?

### 🟦 Key fact:

HAVING sometimes gets rewritten into WHERE (if legal). <br>

#### Example 1 — No aggregate in HAVING:

```sql
SELECT dept
FROM employees
GROUP BY dept
HAVING dept LIKE 'A%';
```

Internal rewrite → HAVING moved to WHERE: <br>
```sql
WHERE dept LIKE 'A%'
GROUP BY dept
```

#### Example 2 — Mixed conditions:

```sql
HAVING COUNT(*) > 5 AND dept = 'Sales'
```

Rewritten to: <br>

- dept = 'Sales' → can push to WHERE
- COUNT(*) > 5 → stays in HAVING

So DB will rewrite to: <br>

```sql
WHERE dept = 'Sales'
GROUP BY dept
HAVING COUNT(*) > 5
```

### Rule
| HAVING contains…              | Optimizer rewrite         |
| ----------------------------- | ------------------------- |
| Only non-aggregate predicates | Move to WHERE             |
| Aggregates only               | Keep in HAVING            |
| Mix                           | Split into WHERE + HAVING |


# 🧠 TWO INTERNAL IMPLEMENTATIONS

## 1️⃣ HAVING WITH ONLY AGGREGATES

```sql
HAVING SUM(sales) > 1000
```

### Internally:
- The database must perform full aggregation first.
- Once every group has computed SUM(sales), then apply filter.
- Cannot push this to WHERE because aggregate depends on all rows in the group.


#### Execution plan operator:
- HashAggregate → Filter

### 2️⃣ HAVING WITH NON-AGGREGATES
```sql
HAVING department = 'IT'
```

This does not depend on aggregates. <br>
Thus database rewrites: <br>

#### Rewritten internally:
```sql
WHERE department = 'IT'
GROUP BY department
```

## 📊 WHEN HAVING CAUSES SLOW QUERIES (INTERNAL REASONS)

#### HAVING used instead of WHERE
- Forces full grouping then filtering.

#### Long GROUP BY + heavy aggregates
HAVING evaluated once per group → large hash tables.

#### DISTINCT in HAVING
Forces nested hash tables.

#### HAVING on expressions
Prevents predicate pushdown


## 🧩 TWO-PHASE AGGREGATION + HAVING

`Partial Aggregate → Final Aggregate → HAVING` <br>

Parallel workers: <br>
- Each worker computes local aggregates.
- A final aggregation stage merges them.
- HAVING is evaluated only after final aggregation.
- This enables parallel GROUP BY.

# Summary
| Concept                         | Explanation                                |
| ------------------------------- | ------------------------------------------ |
| HAVING filters groups           | After grouping/aggregate step              |
| Can be rewritten into WHERE     | Only when predicates contain no aggregates |
| Evaluated once per group        | Never row-by-row                           |
| Can cause slowdowns             | If used incorrectly                        |
| Works after partial aggregation | In parallel plans                          |
