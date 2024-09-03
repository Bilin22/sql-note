-- Grader report.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	assignment_id integer NOT NULL,
	username varchar(25) NOT NULL,
	num_marked integer NOT NULL,
	num_not_marked integer NOT NULL,
	min_mark real DEFAULT NULL,
	max_mark real DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS AssignmentGrader CASCADE;
DROP VIEW IF EXISTS marks CASCADE;
DROP VIEW IF EXISTS SumWeights CASCADE;
DROP VIEW IF EXISTS percentmark CASCADE;
DROP VIEW IF EXISTS status CASCADE;
DROP VIEW IF EXISTS countmark CASCADE;
DROP VIEW IF EXISTS countnotmark CASCADE;
DROP VIEW IF EXISTS marking CASCADE;
DROP VIEW IF EXISTS minmaxmark CASCADE;




-- views

-- assignment-grader pairs
create view AssignmentGrader as
select assignment_id, username, grader.group_id
from assignmentgroup join grader on assignmentgroup.group_id = grader.group_id;


-- null values in marks
create view marks as
select group_id, assignment_id, username, mark 
from assignmentgrader natural left join result;

create view SumWeights as
select assignment_id, sum(weight)
from RubricItem
group by assignment_id;

-- convert final mark into percentage
create view percentmark as
select group_id, assignment_id, username, (mark/sum)*100 as percentage
from marks natural left join SumWeights;

-- num_mark for that assignment
create view status as
select group_id, assignment_id, percentage, username, CASE 
when percentage is null then 'not_marked' 
when percentage is not null then 'marked' 
end as status 
from percentmark;


create view countmark as
select assignment_id, username, count(status) as num_marked
from status
where status = 'marked'
group by assignment_id, username;


create view countnotmark as
select assignment_id, username, count(status) as num_not_marked
from status
where status = 'not_marked'
group by assignment_id, username;


create view marking as
select assignment_id, username, 
    COALESCE(num_marked, 0) as num_marked, COALESCE(num_not_marked, 0) as num_not_marked
from countmark natural full join countnotmark;

create view minmaxmark as
select assignment_id, username, min(percentage) as min_mark, max(percentage) as max_mark
from percentmark
group by assignment_id, username;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
select assignment_id, username, num_marked, num_not_marked, min_mark, max_mark
from minmaxmark natural full join marking;
