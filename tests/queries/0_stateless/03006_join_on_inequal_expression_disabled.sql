-- Tags: disabled
-- Enable after fix
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;


CREATE TABLE t1 (
    key UInt32,
    a UInt32
) ENGINE = MergeTree ORDER BY key;

CREATE TABLE t2 (
    key UInt32,
    a UInt32
) ENGINE = MergeTree ORDER BY key;

INSERT INTO t1 (key, a) VALUES (1, 10), (2, 15), (3, 20);
INSERT INTO t2 (key, a) VALUES (1, 5), (2, 10), (4, 25);

SET allow_experimental_analyzer=1;
SET allow_experimental_join_condition=1;
SET join_algorithm='hash';
-- { echoOn }

-- These queries work
SELECT t1.*, t2.* FROM t1 LEFT JOIN t2 ON t1.key = t2.key AND ((t2.a IN (SELECT a FROM t1 WHERE a = 10))) ORDER BY t1.key, t2.key;

SELECT t1.*, t2.* FROM t1 LEFT JOIN t2 ON t1.key = t2.key AND (t1.a=2 AND (t2.a IN (SELECT a FROM t1 WHERE a = 10))) ORDER BY t1.key, t2.key;

SELECT t1.*, t2.* FROM t1 LEFT JOIN t2 ON t1.key = t2.key AND (t1.a=2 OR (t2.a != (SELECT a FROM t1 WHERE a = 10))) ORDER BY t1.key, t2.key;

-- LOGICAL_ERROR Not-ready Set is passed as the second argument for function 'in'
SELECT t1.*, t2.* FROM t1 LEFT JOIN t2 ON t1.key = t2.key AND (t1.a=2 OR (t2.a IN (SELECT a FROM t1 WHERE a = 10))) ORDER BY t1.key, t2.key;

