# 🔥 WHAT ARE GROUPING SETS?

GROUPING SETS allow you to compute multiple GROUP BYs in a single scan. <br>

```sql
SELECT category, region, SUM(sales)
FROM orders
GROUP BY GROUPING SETS (
   (category, region),   -- detailed
   (category),           -- rollup to category
   ()                    -- grand total
);
```

### 1️⃣ Unified Key Concept for GROUPING SETS

- SQL engine internally creates one hash table.
- The columns of the hash table key are the union of all columns used in all grouping sets.

#### Example:
```sql
GROUP BY GROUPING SETS (
  (a, b),
  (c)
)
```

- Columns used: `a, b, c`
-  Unified internal key structure:
-  Columns not used in a grouping set → set to NULL in the key.

### 2️⃣ How Input Rows Are Processed
For each row: <br>
- Iterate over each grouping set.
- Build a group key according to the grouping set:
  - Columns used → real value
  - Columns not used → NULL
- Hash the key and look up the hash table:
  - If key exists → update aggregates
  - If key does not exist → create new entry
 
```python
for row in table:
    for grouping_set in grouping_sets:
        key = build_key(row, grouping_set)  # NULL unused columns
        if key in hash_table:
            update_aggregates(hash_table[key], row)
        else:
            hash_table[key] = initialize_aggregates(row)
```

### 3️⃣ Internal Key Representation
| a | b | c | value |
| - | - | - | ----- |
| 1 | X | 5 | 10    |
| 1 | Y | 5 | 20    |

Query: <br>
```sql
GROUP BY GROUPING SETS ((a,b), (c))
```

#### Unified key: (a,b,c)

##### Internal hash table after processing:
| a    | b    | c    | SUM(value) | grouping_set_id |
| ---- | ---- | ---- | ---------- | --------------- |
| 1    | X    | NULL | 10         | 0b001           |
| 1    | Y    | NULL | 20         | 0b001           |
| NULL | NULL | 5    | 30         | 0b110           |


```
