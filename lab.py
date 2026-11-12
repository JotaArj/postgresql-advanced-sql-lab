"""Small PostgreSQL lab runner. No student SQL solutions are included."""
import argparse
from collections import Counter
from collections import defaultdict
from datetime import date, datetime
from decimal import Decimal
import json
import os
from pathlib import Path
import platform
import statistics
import sys
import time
import uuid

import psycopg
from psycopg import sql

ROOT = Path(__file__).resolve().parent
TABLES = ['customers','categories','products','orders','order_items','payments','customer_updates']


def read(path):
    return (ROOT / path).read_text(encoding='utf-8-sig')


def connect():
    env = {}
    if (ROOT/'.env').exists():
        for line in read('.env').splitlines():
            if line.strip() and not line.lstrip().startswith('#'):
                key, value = line.split('=',1)
                env[key.strip()] = value.strip()
    password = os.getenv('POSTGRES_PASSWORD', env.get('POSTGRES_PASSWORD'))
    if not password:
        raise ValueError('Set POSTGRES_PASSWORD in .env. See .env.example.')
    conn = psycopg.connect(host='127.0.0.1',port=os.getenv('LAB_PORT',env.get('LAB_PORT','55432')),
                          dbname='sql_challenge',user='lab',password=password,connect_timeout=10)
    conn.execute("SET timezone='UTC'")
    conn.execute("SET statement_timeout='120s'")
    version, database = conn.execute('SELECT current_setting(\'server_version_num\')::int,current_database()').fetchone()
    if version//10000 != 16 or database != 'sql_challenge':
        conn.close()
        raise ValueError('This runner requires PostgreSQL 16 and the dedicated sql_challenge database.')
    conn.commit()
    return conn


def scalar(conn, query):
    return conn.execute(query).fetchone()[0]


def counts(conn, schema):
    return {t:scalar(conn,sql.SQL('SELECT count(*) FROM {}.{}').format(sql.Identifier(schema),sql.Identifier(t))) for t in TABLES}


def verify_base(conn):
    actual = counts(conn,'lab')
    required = dict(customers=2000,categories=10,products=500,orders=15000,order_items=37500,payments=15789,customer_updates=3100)
    if actual != required:
        raise AssertionError(f'Base counts: expected {required}, got {actual}')
    conn.execute('SET search_path TO lab')
    checks = {
        'customers_without_orders': 'SELECT count(*) FROM customers c WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id)',
        'products_without_lines': 'SELECT count(*) FROM products p WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.product_id=p.product_id)',
        'null_country': 'SELECT count(*) FROM customers WHERE country IS NULL',
        'cancelled_orders': "SELECT count(*) FROM orders WHERE status='cancelled'",
        'pending_orders': "SELECT count(*) FROM orders WHERE status='pending'",
        'failed_payments': "SELECT count(*) FROM payments WHERE status='failed'",
        'duplicate_events': 'SELECT count(*) FROM (SELECT source_event_id FROM customer_updates GROUP BY source_event_id HAVING count(*)>1) d',
        'repeated_order_dates': 'SELECT count(*) FROM (SELECT ordered_at FROM orders GROUP BY ordered_at HAVING count(*)>1) d',
        'out_of_order_updates': 'SELECT count(*) FROM customer_updates a JOIN customer_updates b ON a.customer_id=b.customer_id AND a.received_at>b.received_at AND a.source_updated_at<b.source_updated_at',
        'multi_month_customers': "SELECT count(*) FROM (SELECT customer_id FROM orders GROUP BY customer_id HAVING count(DISTINCT date_trunc('month',ordered_at))>1) d",
    }
    coverage = {name:scalar(conn,q) for name,q in checks.items()}
    if not all(v>0 for v in coverage.values()):
        raise AssertionError(f'Missing required data scenario: {coverage}')
    constraints = conn.execute("SELECT conname,convalidated FROM pg_constraint WHERE connamespace='lab'::regnamespace AND contype='f'").fetchall()
    if len(constraints)!=5 or not all(valid for _,valid in constraints):
        raise AssertionError('Expected five validated foreign keys.')
    print(json.dumps({'counts':actual,'coverage':coverage,'foreign_keys':'5 validated'},indent=2))


def setup(conn):
    # Entire schema and seed succeed together, or neither is committed.
    if scalar(conn,"SELECT to_regnamespace('lab') IS NOT NULL"):
        raise ValueError('lab already exists. Use check; setup never resets existing data.')
    conn.execute(read('sql/schema.sql'))
    conn.execute(read('sql/seed.sql'))
    verify_base(conn)
    conn.commit()
    print('Setup committed. Student exercises remain unsolved.')


def fixture(conn, case='main'):
    schema = 'test_' + uuid.uuid4().hex
    conn.execute(sql.SQL('CREATE SCHEMA {}').format(sql.Identifier(schema)))
    ddl=read('sql/schema.sql').replace('CREATE SCHEMA IF NOT EXISTS lab;','').replace('SET search_path TO lab;',f'SET search_path TO {schema};')
    conn.execute(ddl)
    fixtures=read('tests/fixtures.sql').split('-- FIXTURE: ranking',1)
    conn.execute(fixtures[0] if case=='main' else fixtures[1])
    return schema


def normalize(value):
    if isinstance(value,(datetime,date)):
        return value.isoformat()
    if isinstance(value,Decimal):
        return str(value)
    return value


def compare(rows, expected):
    actual = [[normalize(x) for x in row] for row in rows]
    expected = [[normalize(x) for x in row] for row in expected]
    def equal(a,b):
        if len(a)!=len(b): return False
        for x,y in zip(a,b):
            if x is None or y is None:
                if x is not y: return False
            elif isinstance(y,(int,float)) or (isinstance(y,str) and y.replace('.','',1).lstrip('-').isdigit()):
                try:
                    if Decimal(str(x))!=Decimal(str(y)): return False
                except Exception:
                    return False
            elif x!=y: return False
        return True
    if len(actual)!=len(expected):
        raise AssertionError(f'Row count: expected {len(expected)}, got {len(actual)}. Example actual: {actual[:1]}')
    for n,(a,b) in enumerate(zip(actual,expected),1):
        if not equal(a,b):
            raise AssertionError(f'Row {n}: expected {b}; actual {a}')


def contract(cursor, spec):
    fields=[x.strip().split() for x in spec.split(',')]
    actual=[d.name for d in cursor.description or []]
    expected=[f[0] for f in fields]
    if actual!=expected:
        raise AssertionError(f'Columns: expected {expected}; actual {actual}')
    types={'bigint':{20,21,23},'integer':{20,21,23},'numeric':{1700,20,21,23},'text':{25,1043},'timestamp':{1114},'date':{1082}}
    for d,f in zip(cursor.description,fields):
        if d.type_code not in types[f[1]]:
            raise AssertionError(f'Type of {d.name}: expected {f[1]}, actual PostgreSQL OID {d.type_code}')


def base_expectations(conn, exercise):
    """Independent checks built from source records, without reference SQL solutions."""
    customers=conn.execute('SELECT * FROM customers ORDER BY customer_id').fetchall()
    updates=conn.execute('SELECT * FROM customer_updates').fetchall()
    if exercise=='06':
        state={row[0]:list(row) for row in customers}
        expected={}
        for batch in sorted({row[1] for row in updates}):
            for row in updates:
                if row[1]!=batch: continue
                candidate=list(row[2:8])
                previous=state.get(candidate[0])
                if previous is None or tuple(candidate[3:])>tuple(previous[3:]):
                    state[candidate[0]]=candidate
            expected[batch]=[state[key][:] for key in sorted(state)]
        return expected
    if exercise=='04':
        winners={}
        for row in updates:
            priority=(row[5],row[6],row[7],row[8],row[0])
            previous=winners.get(row[2])
            if previous is None or priority>previous[0]:
                winners[row[2]]=(priority,list(row[2:8])+[row[0]])
        return [winners[key][1] for key in sorted(winners)]

    products=conn.execute('SELECT product_id,category_id FROM products').fetchall()
    categories=dict(products)
    paid={row[0] for row in conn.execute("SELECT order_id FROM payments WHERE status='succeeded'")}
    orders={row[0]:row for row in conn.execute('SELECT order_id,customer_id,ordered_at,status FROM orders')
            if row[3]=='completed' and row[0] in paid and row[2]<datetime(2025,1,1)}
    amounts=defaultdict(Decimal)
    category_amounts=defaultdict(lambda:defaultdict(Decimal))
    product_months=defaultdict(Decimal)
    sold=set()
    for oid,_,pid,quantity,price,discount in conn.execute('SELECT * FROM order_items'):
        if oid not in orders: continue
        net=quantity*price-discount
        amounts[oid]+=net
        customer=orders[oid][1]
        category_amounts[customer][categories[pid]]+=net
        month=orders[oid][2].date().replace(day=1)
        product_months[(month,categories[pid],pid)]+=net
        sold.add(pid)
    history=defaultdict(list)
    for oid,cid,when,_ in orders.values():
        history[cid].append((when,oid,amounts[oid]))
    for purchases in history.values(): purchases.sort()
    output=[]
    if exercise=='01':
        for cid,*_ in customers:
            purchases=history[cid]
            if not purchases:
                output.append([cid,None,None,None,None,0,Decimal(0),None,None])
            for pos,(when,oid,_) in enumerate(purchases):
                gap=None if pos==0 else Decimal(str((when-purchases[pos-1][0]).total_seconds()))/86400
                output.append([cid,oid,when,purchases[0][0],purchases[-1][0],len(purchases),
                               sum(p[2] for p in purchases),pos+1,gap])
    elif exercise=='02':
        groups=defaultdict(list)
        for (month,category,pid),amount in product_months.items(): groups[(month,category)].append((pid,amount))
        for (month,category),entries in sorted(groups.items()):
            total=sum(amount for _,amount in entries)
            levels=sorted({amount for _,amount in entries},reverse=True)
            for pid,amount in sorted(entries,key=lambda item:(-item[1],item[0])):
                rank=levels.index(amount)+1
                if rank<=3:
                    pct=None if total==0 else (amount*100/total).quantize(Decimal('.01'),rounding='ROUND_HALF_UP')
                    output.append([month,category,pid,amount,rank,pct])
    elif exercise=='03':
        cohorts=defaultdict(list)
        for cid,purchases in history.items():
            if purchases: cohorts[purchases[0][0].date().replace(day=1)].append(cid)
        for cohort,members in sorted(cohorts.items()):
            activity=cohort
            while activity<date(2025,1,1):
                active=sum(any(p[0].date().replace(day=1)==activity for p in history[cid]) for cid in members)
                offset=(activity.year-cohort.year)*12+activity.month-cohort.month
                pct=(Decimal(active)*100/len(members)).quantize(Decimal('.01'),rounding='ROUND_HALF_UP')
                output.append([cohort,activity,offset,len(members),active,pct])
                activity=date(activity.year+activity.month//12,activity.month%12+1,1)
    elif exercise=='05a':
        output=[[cid] for cid,purchases in sorted(history.items()) if len(purchases)>=2 and any(p[2]>=100 for p in purchases)]
    elif exercise=='05b':
        output=[[pid] for pid,_ in sorted(products) if pid not in sold]
    elif exercise=='05c':
        for cid,*_ in customers:
            p=history[cid][-1] if history[cid] else None
            output.append([cid,p[1],p[0],p[2]] if p else [cid,None,None,None])
    elif exercise=='07':
        monthly=defaultdict(Decimal)
        for cid,purchases in history.items():
            for when,_,amount in purchases:
                if when>=datetime(2024,7,1): monthly[(when.date().replace(day=1),cid)]+=amount
        output=[[month,cid,amount] for (month,cid),amount in sorted(monthly.items())]
    elif exercise=='08':
        for cid,purchases in history.items():
            total=sum(p[2] for p in purchases)
            if len(purchases)<2 or total<150 or purchases[-1][0]>=datetime(2024,10,1): continue
            last=purchases[-1][0]
            favorite=min(category_amounts[cid],key=lambda cat:(-category_amounts[cid][cat],cat))
            output.append([cid,last,Decimal(str((datetime(2025,1,1)-last).total_seconds()))/86400,
                           len(purchases),total,len({p[0].date().replace(day=1) for p in purchases}),favorite,
                           sum((p[2] for p in purchases if p[0]>=datetime(2024,7,1)),Decimal(0))])
        output.sort(key=lambda row:(-row[4],row[0]))
    return [[normalize(value) for value in row] for row in output]


def validate(conn, exercise, path, use_fixtures=False):
    if use_fixtures:
        fixture(conn)
    else:
        conn.execute('SET TRANSACTION ISOLATION LEVEL REPEATABLE READ')
        if exercise!='06': conn.execute('SET TRANSACTION READ ONLY')
        conn.execute('SET search_path TO lab')
    source='isolated fixtures' if use_fixtures else 'sql_challenge.lab (your dataset)'
    print(f'Validating {exercise} against {source}.',flush=True)
    cases=json.loads(read('tests/cases.json'))
    expected=cases['expected'] if use_fixtures else {exercise:base_expectations(conn,exercise)}
    submission=Path(path).read_text(encoding='utf-8-sig')
    if exercise.startswith('05'):
        marker='-- PART '+exercise[-1].upper()
        if marker not in submission:
            raise ValueError(f'Missing {marker} section in exercise 05.')
        submission=submission.split(marker,1)[1].split('-- PART ',1)[0]
    if exercise=='06':
        if scalar(conn,"SELECT to_regnamespace('incremental') IS NOT NULL"):
            raise ValueError('incremental schema already exists; use a clean dedicated database for fixture validation.')
        conn.execute('CREATE SCHEMA incremental; CREATE TABLE incremental.customers (LIKE customers INCLUDING ALL); INSERT INTO incremental.customers SELECT * FROM customers')
        previous=None
        if use_fixtures:
            schedule=[(1,False,'06_1'),(1,True,'06_1'),(2,False,'06_2'),(1,True,'06_2'),(2,True,'06_2')]
        else:
            expected=expected['06']
            batches=sorted(expected)
            schedule=[entry for batch in batches for entry in [(batch,False,batch),(batch,True,batch)]]
            if len(batches)>1: schedule.append((batches[0],True,batches[-1]))
        for batch,replay,state in schedule:
            conn.execute("SELECT set_config('lab.batch_id',%s,true)",(str(batch),))
            conn.execute(submission)
            rows=conn.execute('SELECT * FROM incremental.customers ORDER BY customer_id').fetchall()
            compare(rows,expected[state])
            physical=conn.execute('SELECT customer_id,ctid::text FROM incremental.customers ORDER BY customer_id').fetchall()
            if replay and physical!=previous:
                raise AssertionError(f'Batch {batch}: replay performed physical writes despite unchanged expected state')
            previous=physical
    else:
        spec=cases['contracts'][exercise]
        cursor=conn.execute(submission)
        if cursor.description is None:
            raise AssertionError('Submission must return the requested result columns.')
        contract(cursor,spec)
        compare(cursor.fetchall(),expected[exercise])
        if exercise=='02' and use_fixtures:
            conn.rollback()
            fixture(conn,'ranking')
            cursor=conn.execute(submission)
            contract(cursor,spec)
            compare(cursor.fetchall(),cases['ranking_expected'])
    conn.rollback()
    print(f'{exercise}: checks passed against {source}. Not graded; mentor review is still required.')


def perf(conn, scale, commit=True):
    if not 1<=scale<=50: raise ValueError('Scale must be between 1 and 50.')
    if scalar(conn,"SELECT to_regnamespace('perf') IS NOT NULL"):
        raise ValueError('perf already exists; refusing to overwrite it.')
    conn.execute('CREATE SCHEMA perf')
    for t in TABLES:
        conn.execute(sql.SQL('CREATE TABLE perf.{} (LIKE lab.{} INCLUDING ALL)').format(sql.Identifier(t),sql.Identifier(t)))
    for t in ['customers','categories','products','customer_updates']:
        conn.execute(sql.SQL('INSERT INTO perf.{} SELECT * FROM lab.{}').format(sql.Identifier(t),sql.Identifier(t)))
    for replica in range(scale):
        offset=replica*15000
        conn.execute('INSERT INTO perf.orders SELECT order_id+%s,customer_id,ordered_at,status FROM lab.orders',(offset,))
        conn.execute('INSERT INTO perf.order_items SELECT order_id+%s,line_no,product_id,quantity,unit_price,discount_amount FROM lab.order_items',(offset,))
        conn.execute('INSERT INTO perf.payments SELECT payment_id+%s,order_id+%s,paid_at,status,amount FROM lab.payments',(replica*30000,offset))
    for ddl in ['ALTER TABLE perf.products ADD FOREIGN KEY (category_id) REFERENCES perf.categories',
                'ALTER TABLE perf.orders ADD FOREIGN KEY (customer_id) REFERENCES perf.customers',
                'ALTER TABLE perf.order_items ADD FOREIGN KEY (order_id) REFERENCES perf.orders',
                'ALTER TABLE perf.order_items ADD FOREIGN KEY (product_id) REFERENCES perf.products',
                'ALTER TABLE perf.payments ADD FOREIGN KEY (order_id) REFERENCES perf.orders']:
        conn.execute(ddl)
    conn.execute('ANALYZE perf.orders; ANALYZE perf.order_items; ANALYZE perf.payments; ANALYZE perf.customers; ANALYZE perf.products; ANALYZE perf.categories')
    print(json.dumps(counts(conn,'perf'),indent=2))
    if commit:
        conn.commit()


def benchmark(conn,path,label):
    if not label.replace('_','').replace('-','').isalnum(): raise ValueError('Use an alphanumeric label.')
    conn.execute('SET TRANSACTION ISOLATION LEVEL REPEATABLE READ, READ ONLY')
    conn.execute('SET search_path TO perf')
    conn.execute("SET statement_timeout='300s'")
    query=Path(path).read_text(encoding='utf-8-sig').strip().rstrip(';')
    baseline=read('benchmarks/baseline.sql')
    # First six timed runs precede equivalence verification to preserve the first-run observation.
    times=[]
    for _ in range(6):
        start=time.perf_counter()
        cur=conn.execute(query)
        contract(cur,json.loads(read('tests/cases.json'))['contracts']['07'])
        rows=cur.fetchall()
        times.append((time.perf_counter()-start)*1000)
    reference=conn.execute(baseline).fetchall()
    if Counter(rows)!=Counter(reference):
        delta=Counter(rows)-Counter(reference)
        missing=Counter(reference)-Counter(rows)
        raise AssertionError(f'Not equivalent: extra example {list(delta)[:1]}, missing example {list(missing)[:1]}')
    plan=conn.execute('EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) '+query).fetchone()[0]
    result={'label':label,'first_run_ms':times[0],'warm_runs_ms':times[1:],'warm_median_ms':statistics.median(times[1:]),
            'equivalent':True,'rows':len(rows),'counts':counts(conn,'perf'),
            'server_version':scalar(conn,'SELECT version()'),'client_platform':platform.platform(),
            'client_cpu':platform.processor(),'client_logical_cpus':os.cpu_count(),
            'conditions':'first run may be cached; client wall time includes result transfer; fill hardware and Docker limits manually',
            'planner_settings':dict(conn.execute("SELECT name,setting FROM pg_settings WHERE name IN ('work_mem','shared_buffers','effective_cache_size','max_parallel_workers_per_gather','random_page_cost')").fetchall()),
            'indexes':conn.execute("SELECT indexname,indexdef FROM pg_indexes WHERE schemaname='perf' ORDER BY indexname").fetchall(),
            'recorded_at_utc':datetime.now(__import__('datetime').timezone.utc).isoformat(),
            'query':query,'plan':plan}
    out=ROOT/'artifacts';out.mkdir(exist_ok=True)
    target=out/f'benchmark_{label}_{time.time_ns()}.json'
    target.write_text(json.dumps(result,indent=2,default=str),encoding='utf-8')
    conn.rollback()
    print(f'Equivalent. Warm median {result["warm_median_ms"]:.2f} ms. Evidence: {target}')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest='command',required=True)
    sub.add_parser('setup');sub.add_parser('check')
    p=sub.add_parser('validate');p.add_argument('exercise',choices=['01','02','03','04','05a','05b','05c','06','07','08']);p.add_argument('--file',required=True);p.add_argument('--fixtures',action='store_true',help='Run additional small edge cases instead of the visible lab dataset')
    p=sub.add_parser('perf');p.add_argument('--scale',type=int,default=10)
    p=sub.add_parser('benchmark');p.add_argument('--file',required=True);p.add_argument('--label',required=True)
    args=parser.parse_args()
    with connect() as conn:
        try:
            if args.command=='setup': setup(conn)
            elif args.command=='check': verify_base(conn)
            elif args.command=='validate': validate(conn,args.exercise,args.file,args.fixtures)
            elif args.command=='perf': perf(conn,args.scale)
            else: benchmark(conn,args.file,args.label)
        except Exception:
            conn.rollback()
            raise


if __name__=='__main__':
    try: main()
    except (psycopg.Error,AssertionError,ValueError,KeyError) as exc:
        print(f'FAILED: {exc}',file=sys.stderr)
        sys.exit(1)
