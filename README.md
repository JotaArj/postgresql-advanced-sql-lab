# PostgreSQL Advanced SQL Challenge

Eight SQL exercises on a reproducible e-commerce dataset: analysis, data quality,
incremental loading and query optimization. The learner writes the solutions.
PostgreSQL 16, Docker Compose and Python 3.11+ (psycopg). Estimated effort: 6–8 hours.

## Start

Run once in PowerShell, with Docker Desktop running:

```powershell
Copy-Item .env.example .env
# Set your local password in .env before continuing.
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
docker compose up -d --wait
.\.venv\Scripts\python.exe lab.py setup
```

The current workspace is already set up: use `check`, not `setup`.
Connection: `127.0.0.1:55432`, database `sql_challenge`, user `lab`, password in
ignored `.env`. `LAB_PORT` overrides the port. Setup is transactional and refuses
to replace existing data. Existing containers and volumes are left alone.

For interactive SQL:

```powershell
docker compose exec db psql -U lab -d sql_challenge
```

Use `SET search_path TO lab;` in that session. Each file in `sql/exercises/`
contains its statement followed by space for your SQL and explanation.

## Files and dataset

```text
README.md                 Setup, rules and results
lab.py                    Setup, validation and benchmark commands
sql/schema.sql            Relational model and constraints
sql/seed.sql              Deterministic dataset (seed 20261111)
sql/exercises/            Eight files: statement + learner solution
benchmarks/baseline.sql    Starting query for exercise 07
tests/                    Fixtures, expected cases and runner self-tests
```

`customers → orders → order_items → products → categories`; `payments` holds
order payment attempts. `customer_updates` is independent staging for customer snapshots.
Final tables enforce primary keys, five foreign keys, checks and unique emails.

Base counts: 2,000 customers, 10 categories, 500 products, 15,000 orders,
37,500 lines, 15,789 payments and 3,100 staging rows. Fixed integer formulas
produce the same 2024 dataset without depending on random state or the wall clock.

## Business rules

- Observation ends at **2025-01-01 00:00:00 exclusive**. Observed months are
  January–December 2024. Timestamps represent UTC without time zone; money is EUR.
- A valid purchase is a `completed` order with at least one `succeeded` payment.
  Multiple successful payments qualify an order once. Revenue is the sum of
  `quantity * unit_price - discount_amount` across its lines. Discounts are per line,
  not per unit. Payment amounts do not define revenue. Order time determines the month.
  All analytical exercises exclude purchases at or after the observation cutoff.
- Purchase order is `(ordered_at, order_id)` ascending; latest purchase reverses both
  keys. Zero-revenue purchases are valid. Preserve customers without purchases where
  requested. Month outputs are first-of-month SQL dates; durations are decimal days
  (seconds / 86400). Percentages use a 0–100 scale, rounded to two decimals.
  Do not round revenue before aggregation.
- Products and categories are immutable. Staging contains full snapshots: a NULL
  country clears the attribute. Business priority, descending, is
  `(source_updated_at, source_version, source_event_id)`. Physical duplicate ties use
  `(received_at, ingestion_id)` descending. Equal business priorities have identical
  payloads. Lower priorities are obsolete; equal priorities are replays and must not
  change the destination. Different events may share timestamps and versions.
- Exercise 04 considers all batches. Exercise 06 consumes one requested batch and uses
  isolated `incremental.customers`; conflicting email ownership must fail atomically.
  Exercise 07 uses `perf`. Neither may mutate the base `lab` schema.

## Exercises

| # | Exercise | Main skills | Status |
|---|---|---|---|
| 01 | Customer Purchase Analysis | Windows, chronology, aggregation, NULL | Not submitted |
| 02 | Product Revenue Ranking | Ties, monthly revenue, category shares | Not submitted |
| 03 | Monthly Customer Retention | Cohorts, calendar periods, inactive months | Not submitted |
| 04 | Data Deduplication | Version priority, deterministic selection | Not submitted |
| 05 | EXISTS, NOT EXISTS and LATERAL | Cardinality, correlated logic, latest purchase | Not submitted |
| 06 | Incremental Loading and Upserts | Transactions, versions, idempotence | Not submitted |
| 07 | Query Optimization | Plans, buffers, equivalent results, measurement | Not submitted |
| 08 | Integrated Business Case | Customer value, inactivity, temporal metrics | Not submitted |

No particular SQL construction is mandatory. Only exercise 07 includes a starting
query. Keep explanations and, later, actual benchmark conclusions in the exercise file.

## Validate

```powershell
.\.venv\Scripts\python.exe lab.py check
.\.venv\Scripts\python.exe lab.py validate 01 --file sql/exercises/01_customer_purchase_analysis.sql
.\.venv\Scripts\python.exe -m unittest discover -s tests -v
```

For exercise 05, write all three queries in its single file beneath `-- PART A`,
`-- PART B` and `-- PART C`. Validate each with `validate 05a`, `05b` or `05c`,
passing that same file. Other exercises use their two-digit number.

Tests use hand-authored fixtures and literal expected results, not SQL answer keys.
They check names, compatible types, row counts, order, exact values, duplicates and
NULLs. Cases include multiple payment successes, discounts, a zero-revenue purchase,
the exclusive cutoff, ranking ties and staging priorities. Exercise 06 checks full
destination state and physical no-op behavior for batches 1, 1, 2, 1, 2.

Source tables must be unqualified so fixtures can replace the search path. The runner
creates transactional test schemas and rolls them back; do not use COMMIT/ROLLBACK
in submissions. This is trusted local SQL, not a security sandbox. A failed check
shows the condition and an example without hints. Passing fixtures still requires
technical review before grading.

Assessment: correctness 40%, edge cases 20%, clarity 15%, technique 15%, performance
and justification 10%. For exercise 07: 30%, 10%, 10%, 10%, 40%, respectively.

## Optimization benchmark

```powershell
.\.venv\Scripts\python.exe lab.py perf --scale 10
.\.venv\Scripts\python.exe lab.py benchmark --file benchmarks/baseline.sql --label before
# After writing your candidate and applying your proposed changes in perf:
.\.venv\Scripts\python.exe lab.py benchmark --file sql/exercises/07_query_optimization.sql --label after
```

Scale 1–50 replicates order histories with consistent keys, sharing customers and
products. It refuses to overwrite `perf`. The benchmark compares the complete result
multiset in one snapshot, records EXPLAIN (ANALYZE, BUFFERS), one initial run and five
warm runs. Reports in ignored `artifacts/` include plans, times, counts, indexes,
PostgreSQL settings and client hardware details. Record actual RAM, storage, Docker
allocation, concurrent load and all proposed DDL in the exercise comments.

Compare warm medians and variability under comparable conditions; alternate query
order when investigating cache effects. The first run is not guaranteed cold.
Do not force plans. Claim a speedup only when measurements support it.
**No before/after benchmark or improvement claim is available yet.**

## Verified status and limits

Local setup on 2026-11-11: PostgreSQL 16.14, healthy on port 55432; expected base
counts and five validated foreign keys. Data checks cover customers without orders,
unsold products, NULLs, failed payments, duplicates and out-of-order updates.
Runner self-tests: **12 passed**. Scale-2 integrity was tested transactionally and
rolled back; base data stayed unchanged. No learner exercise has been passed or graded.

Synthetic formulas introduce correlations unlike production. The model omits refunds,
tax, shipping, changing categories and multiple currencies. Scaling adds orders rather
than customer diversity. Fixtures cannot prove correctness for every possible dataset.
This is a learning project, not professional experience. No commits or GitHub publication
are made automatically; final results must reflect the learner's actual solutions.
