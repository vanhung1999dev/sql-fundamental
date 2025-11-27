# Diagram
<img width="709" height="833" alt="image" src="https://github.com/user-attachments/assets/ad6aa777-1c71-4d45-a3d2-35d5759b84b4" />


## 🔥 1. INNER JOIN (a.k.a. “only matching rows”)
### ✔ What it returns
- Only rows where the join condition matches in `both` tables.

```sql
SELECT *
FROM A
INNER JOIN B ON A.id = B.id;
```

Result set: 
| A.id  | B.id  | Included? |
| ----- | ----- | --------- |
| match | match | ✔ yes     |
| match | null  | ❌ no      |
| null  | match | ❌ no      |

### 🔧 Internal execution behavior

PostgreSQL:
- Scans both tables
- Applies a join algorithm (NLJ, Hash, Merge)
- Keeps ONLY rows that match the join condition
- All join algorithms support INNER JOIN.

## 🔥 2. LEFT JOIN (Left Outer Join)
### ✔ What it returns
- Everything from the LEFT table, plus matching rows from the right.
- Unmatched right-side rows become NULL.

```psql
SELECT *
FROM A
LEFT JOIN B ON A.id = B.id;
```

Result set: 
| A.id  | B.id  | Included?  |
| ----- | ----- | ---------- |
| match | match | ✔          |
| match | null  | ✔ (B=null) |
| null  | match | ❌          |

### 🔧 Internal execution behavior

PostgreSQL evaluates:

- produce all rows of A
- look up matching rows in B
- if no match → produce a row with NULL for B columns

All three join algorithms (nested, hash, merge) can perform LEFT joins. <br>
But internally: <br>

- With hash join → unmatched A rows are output after probe
- With nested loop → inner table can return 0 rows, and engine fills NULLs
- With merge join → works but more complex, requires outer-marking

#### 🎯 Pros
- ✔ Guaranteed return of all left table rows
- ✔ Common for parent–child queries
- ✔ Good for optional relations

#### ⚠️ Cons
- ❌ Harder to index/optimize if many left rows have no match
- ❌ NULLs can cause logic mistakes
- ❌ Cannot use index-only scans on right if no matching rows

## 🔥 3. RIGHT JOIN (Right Outer Join)
### ✔ What it returns
- `RIGHT JOIN` returns all rows from the right table, plus matching rows from the left table.
Non-matching rows from the left side become NULL.

```sql
SELECT *
FROM A
RIGHT JOIN B
  ON A.id = B.id;
```

### Internal Working (Execution Steps)
(DB engine may reorder the join, but conceptually:) <br>

- Choose join strategy: nested loop, hash join, or merge join depending on indexes + statistics.
- Make sure all rows from Right table are included.
- For each right table row:
  - Find matching left table rows (using join condition).
  - If match → output combined row.
  - If no match → output right row with NULL for left columns.
- Apply projection (selected columns), ORDER BY, and other clauses afterwards.

#### Note: Internally, SQL engines often rewrite RIGHT JOIN into a LEFT JOIN for optimization.


### Pros
- Useful when you think from the “right table perspective”.
- Helps retain all rows from a secondary dataset even without matches.

### Cons
- Rarely used in industry → reduces readability.
- Can always be rewritten as a LEFT JOIN (clearer).
- May confuse query optimizers (rewriting is common but sometimes complicates plans).

## FULL OUTER JOIN

### Definition
- Returns all rows from both tables.
- Unmatched rows get NULLs on the other side:

```sql
SELECT *
FROM A
FULL OUTER JOIN B
  ON A.id = B.id;
```

### Internal Working
This join is conceptually: `LEFT JOIN + RIGHT JOIN (deduplicated)`

#### Execution typically:

- Run join algorithm (hash join is most common because FULL JOIN forces full table access).
- Produce:
  - Matching rows.
  - Left-only rows.
  - Right-only rows.
- Deduplicate rows where both sides matched.
- Output the merged set.

#### Note: FULL OUTER JOIN is difficult to optimize because:
- Neither side can be filtered early.
- Both tables must often be fully scanned.

### Pros
- Ensures complete dataset from both sources.
- Useful for reconciliation (e.g., comparing lists, data warehousing audits).

### Cons
- Slow for large tables: requires full scan or hash tables.
- Cannot use many index optimizations.
- Not supported in some databases (like MySQL ≤ 8.0) without workarounds.

## CROSS JOIN
- Produces the Cartesian product: `A row count × B row count`

```sql
SELECT *
FROM A
CROSS JOIN B;
```

### Internal Working

Simplest join internally: <br>

- For each row in A:
  - Combine with every row in B.
- No filter, no join condition.

If A=1,000 rows, B=5,000 rows → output = 5 million rows. <rb>

### Pros
- Very fast algorithmically because it is literal iteration.
- Useful for:
  - Generating test data
  - Creating date tables
  - Pivoting via dynamic matrices

 ### Cons
- Can explode row count → huge memory + CPU cost.
- Often mistakenly used when user forgets to include join condition (in non-ANSI join syntax).
- Quickly becomes unusable for large tables.

