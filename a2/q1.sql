-- Distributions.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
	assignment_id integer NOT NULL,
	average_mark_percent real DEFAULT NULL,
	num_80_100 integer NOT NULL,
	num_60_79 integer NOT NULL,
	num_50_59 integer NOT NULL,
	num_0_49 integer NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS AssignmentGroupPair CASCADE;
DROP VIEW IF EXISTS WeightSum CASCADE;
DROP VIEW IF EXISTS percentgrade CASCADE;
DROP VIEW IF EXISTS avgmark CASCADE;
DROP VIEW IF EXISTS interval80_100 CASCADE;
DROP VIEW IF EXISTS interval60_79 CASCADE;
DROP VIEW IF EXISTS interval50_59 CASCADE;
DROP VIEW IF EXISTS interval0_49 CASCADE;
DROP VIEW IF EXISTS total CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW AssignmentGroupPair as
select assignment_id, group_id, mark
from assignment natural left join assignmentgroup natural left join result;

create view WeightSum as
select assignment_id, sum(weight)
from RubricItem
group by assignment_id;


create view percentgrade as
select assignment_id, group_id, (mark/sum)*100 as percentage
from AssignmentGroupPair natural left join WeightSum;

create view avgmark as
select assignment_id, avg(percentage) as average_mark_percent
from percentgrade
group by assignment_id;


create view interval80_100 as
select assignment_id, count(percentage) as num_80_100
from percentgrade
where percentage in 
(select percentage from percentgrade where percentage >= 80 and percentage <= 100)
group by assignment_id;

create view interval60_79 as
select assignment_id, count(percentage) as num_60_79
from percentgrade
where percentage in 
(select percentage from percentgrade where percentage >= 60 and percentage < 80)
group by assignment_id;

-- modify these
create view interval50_59 as
select assignment_id, count(percentage) as num_50_59
from percentgrade
where percentage in 
(select percentage from percentgrade where percentage >= 50 and percentage < 60)
group by assignment_id;

create view interval0_49 as
select assignment_id, count(percentage) as num_0_49
from percentgrade
where percentage in 
(select percentage from percentgrade where percentage >= 0 and percentage < 50)
group by assignment_id;


create view total as
select assignment_id, average_mark_percent, COALESCE(num_80_100, 0) as num_80_100, 
COALESCE(num_60_79, 0) as num_60_79, COALESCE(num_50_59, 0) as num_50_59, COALESCE(num_0_49, 0) as num_0_49
from avgmark natural full join interval0_49 natural full join interval50_59 natural full join interval60_79 natural full join interval80_100;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
select * 
from total;
