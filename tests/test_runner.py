"""Infrastructure tests, not SQL solutions or learner submissions."""
from contextlib import redirect_stdout
from decimal import Decimal
import io
from pathlib import Path
import sys
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
import lab


class ComparisonTests(unittest.TestCase):
    def test_exact_decimal_and_null(self):
        lab.compare([(1,Decimal('10.00'),None)],[[1,'10',None]])

    def test_wrong_value_is_rejected(self):
        with self.assertRaisesRegex(AssertionError,'Row 1'):
            lab.compare([(1,Decimal('9.99'))],[[1,'10']])

    def test_wrong_null_is_rejected(self):
        with self.assertRaises(AssertionError):
            lab.compare([(1,0)],[[1,None]])

    def test_duplicate_is_rejected(self):
        with self.assertRaisesRegex(AssertionError,'Row count'):
            lab.compare([(1,),(1,)],[[1]])

    def test_order_is_checked(self):
        with self.assertRaises(AssertionError):
            lab.compare([(2,),(1,)],[[1],[2]])


class DatabaseTests(unittest.TestCase):
    def setUp(self):
        self.conn=lab.connect()

    def tearDown(self):
        self.conn.rollback()
        self.conn.close()

    def test_base_integrity_and_required_scenarios(self):
        with redirect_stdout(io.StringIO()):
            lab.verify_base(self.conn)

    def test_fixture_rolls_back_and_base_is_unchanged(self):
        before=lab.counts(self.conn,'lab')
        schema=lab.fixture(self.conn)
        self.assertEqual(lab.scalar(self.conn,'SELECT count(*) FROM customers'),3)
        self.conn.rollback()
        self.assertIsNone(self.conn.execute('SELECT to_regnamespace(%s)',(schema,)).fetchone()[0])
        self.assertEqual(before,lab.counts(self.conn,'lab'))

    def test_contract_rejects_name_and_type(self):
        with self.assertRaisesRegex(AssertionError,'Columns'):
            lab.contract(self.conn.execute('SELECT 1 AS wrong'),'sample_id bigint')
        with self.assertRaisesRegex(AssertionError,'Type'):
            lab.contract(self.conn.execute("SELECT 'wrong'::text AS sample_id"),'sample_id bigint')

    def test_only_supplied_reporting_query_matches_fixture(self):
        with redirect_stdout(io.StringIO()):
            lab.validate(self.conn,'07',lab.ROOT/'benchmarks/baseline.sql')

    def test_new_setup_is_refused(self):
        with self.assertRaisesRegex(ValueError,'already exists'):
            lab.setup(self.conn)

    def test_incremental_target_is_transactionally_isolated(self):
        lab.fixture(self.conn)
        self.conn.execute('CREATE SCHEMA incremental; CREATE TABLE incremental.customers (LIKE customers INCLUDING ALL); INSERT INTO incremental.customers SELECT * FROM customers')
        self.assertEqual(lab.scalar(self.conn,'SELECT count(*) FROM incremental.customers'),3)
        self.conn.rollback()
        self.assertIsNone(lab.scalar(self.conn,"SELECT to_regnamespace('incremental')"))

    def test_scaled_dataset_keeps_integrity_and_base_unchanged(self):
        before=lab.counts(self.conn,'lab')
        with redirect_stdout(io.StringIO()):
            lab.perf(self.conn,2,commit=False)
        scaled=lab.counts(self.conn,'perf')
        for table in ('orders','order_items','payments'):
            self.assertEqual(scaled[table],before[table]*2)
        for table in ('customers','products','categories','customer_updates'):
            self.assertEqual(scaled[table],before[table])
        self.assertEqual(lab.scalar(self.conn,"SELECT count(*) FROM pg_constraint WHERE connamespace='perf'::regnamespace AND contype='f' AND convalidated"),5)
        self.assertEqual(before,lab.counts(self.conn,'lab'))
        self.conn.rollback()
        self.assertIsNone(lab.scalar(self.conn,"SELECT to_regnamespace('perf')"))


if __name__=='__main__':
    unittest.main()
