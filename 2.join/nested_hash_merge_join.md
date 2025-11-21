# 🔍 What Do “Outer” and “Inner” Mean in Joins?
| Role                       | Meaning                                               |
| -------------------------- | ----------------------------------------------------- |
| **Outer (Left) Relation**  | The table whose rows are processed first              |
| **Inner (Right) Relation** | The table that is looked up for each row in the outer |

### 📦 Example (simple)
```sql
SELECT *
FROM customers c
JOIN orders o
ON c.id = o.customer_id;
```

Execution plan might say: <br>
```pgsql
Nested Loop
  -> Seq Scan on customers (outer)
  -> Index Scan on orders (inner)
```

Meaning:
- PostgreSQL reads customers first → outer
- For each customer row, it probes orders using an index → inner

## 🎯 How the planner chooses outer vs inner
#### Depends on:
- estimated row counts
- join selectivity
- presence of indexes
- disk vs memory cost
- join type
- join algorithm

### Example
#### Nested Loop
- outer = small
- inner = large table with index

#### Hash Join
- inner (build side) = the smaller relation
- outer (probe side) = larger relation

#### Merge Join
- whichever input matches sorted order best

# 🚀 1. Nested Loop Join (NLJ) — Internal Mechanics
This is the simplest join algorithm. It iterates outer rows and probes the inner relation for each. <br>

### 🔧 1.1 Internal Process (step-by-step)

#### Let outer = A, inner = B
```sql
for each row a in A:
    for each matching row b in B:
        if join condition matches:
            output (a, b)
```

But internally there are multiple inner table access strategies: <br>

### Variant A: NLJ + Index Scan (fastest)
Used when: <br>
- inner table has an index on join key
- outer rows are few

Process: <br>
```rust
for each a in A:
    use B's index to find rows where B.key = a.key
```
This is extremely fast because each lookup is O(log N) or even O(1). <br>

### Variant B: NLJ + Seq Scan (slowest)
Used when: <br>
- no index
- or planner is wrong

For every outer row: <br>
```css
scan entire B
```
This becomes O(N × M) — very bad. <br>

### Variant C: NLJ + Bitmap Scan
Used when: <br>
- inner index exists but many outer rows share conditions
- PostgreSQL batches lookups
Postgres builds a bitmap of pages → reduces random I/O. <br>

### 🎯 1.2 Pros
- ✔ Best when outer is small
- ✔ Very fast with index on inner table
- ✔ Works with ANY join condition
- (cons: hash join only works with equalities)

- ✔ Returns first rows quickly
- Better for LIMIT queries.

### ⚠️ 1.3 Cons
- ❌ Slow when both tables large
- ❌ Slow if no index on inner table
- ❌ Random I/O per outer row
- ❌ Very sensitive to cardinality misestimates
- ❌ Worst-case: O(N × M)

# 🧠 2. Hash Join — Internal Mechanics
Used for large datasets, equality joins, and when memory is sufficient. <br>

## ⚙️ 2.1 Internal Process
Let A = outer (probe), B = inner (build)

### Phase 1: Build hash table on inner table
```css
for each b in B:
    compute hash(b.key)
    place b into hash bucket
```

This is an in-memory hash table when possible. <br>
If memory too small, Postgres creates temporary batches on disk: <br>
- spills parts of the hash table
- processes batch-by-batch

### Phase 2: Probe phase
```css
for each a in A:
    compute hash(a.key)
    lookup matching bucket
    output matches
```
Only works for equality predicates (=). <br>

### 🧠 2.2 Additional Internal Notes
#### 🌡 Spilling to disk

If hash table > work_mem:
- PostgreSQL writes partitions to temporary files
- Repeats build + probe for each batch

#### 📊 Skew optimization
- Recent PG versions detect skewed values → special skew buckets.

#### 🔎 Recheck condition
- Even after hash match, PG checks join condition again to handle hash collisions.

### 🎯 2.3 Pros

- ✔ Best for large tables
- ✔ Fast when enough memory
- ✔ Does not require sorted inputs
- ✔ Great for equality joins
- ✔ Predictable performance (linear time)
- ✔ Not sensitive to random I/O (scans both tables once)

### ⚠️ 2.4 Cons

- ❌ Only works for =` joins
- ❌ Consumes memory (hash table)
- ❌ Can spill to disk → slow
- ❌ Bad with skewed data distribution
- ❌ Cannot return first rows early (needs whole hash phase)

### 📏 Time Complexity
| Case           | Complexity               |
| -------------- | ------------------------ |
| Fits in memory | **O(N + M)**             |
| Spills to disk | **O((N + M) × batches)** |


## 🔥 3. Merge Join — Internal Mechanics
Best when:
- both tables sorted
- join condition is equality or inequality (=, <, <=, >)
Merge join is the only one efficient for inequality joins. <br>

### ⚙️ 3.1 Internal Process
#### Precondition:
- Both inputs must be sorted by join key.
- If not already sorted → PostgreSQL performs Sort nodes before merge.

`Step-by-step` <br>
Let A and B sorted by key. <br>
```vnnet
get first row from A and B

while both not exhausted:
    if A.key == B.key:
        output pair
        advance either A or B depending on duplicates
    else if A.key < B.key:
        advance A
    else:
        advance B
```
Very similar to merging two sorted lists. <br>

### ⭐ Important: Merge join is the only join that supports:
- BETWEEN
- <
- >
- <=
- >=
- non-equi joins efficiently

Nested loop also works but slow. <br>
Hash join cannot do it at all. <br>

### 🎯 3.2 Pros

- ✔ Excellent for sorted inputs
- ✔ Good for large tables
- ✔ Supports inequality joins
- ✔ Low memory usage
- ✔ Can perform well with indexes that maintain sort order
- (b-tree indexes produce sorted output)

### 📏 Time Complexity
#### If both already sorted:
- O(N + M)

#### If sorting required:
- O(N log N + M log M)

# 🥊 Summary Table (Deep Performance Comparison)
| Feature                   | Nested Loop                | Hash Join                    | Merge Join                    |
| ------------------------- | -------------------------- | ---------------------------- | ----------------------------- |
| Best for                  | Small outer; indexed inner | Large tables; equality joins | Sorted data; inequality joins |
| Worst for                 | Large × large              | Memory-limited; skew         | Unsorted inputs               |
| Memory                    | Low                        | High                         | Medium-low                    |
| Needs sorting?            | No                         | No                           | Yes (if not already sorted)   |
| Supports inequality joins | Yes (slow)                 | ❌ No                         | ✔ Yes                         |
| Returns first rows early  | ✔ Yes                      | ❌ No                         | ❌ Usually no                  |
| Handles NULLs             | Yes                        | Yes                          | Yes                           |
