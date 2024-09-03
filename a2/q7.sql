-- High coverage.

SET search_path TO markus;
DROP TABLE IF EXISTS q7 CASCADE;

CREATE TABLE q7 (
	grader varchar(25) NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS actualassign CASCADE;
DROP VIEW IF EXISTS expect CASCADE;
DROP VIEW IF EXISTS notassignevery CASCADE;
DROP VIEW IF EXISTS assignevery CASCADE;
DROP VIEW IF EXISTS satisfied1 CASCADE;
DROP VIEW IF EXISTS allstudent CASCADE;
DROP VIEW IF EXISTS expectstudent CASCADE;
DROP VIEW IF EXISTS actualstudent CASCADE;
DROP VIEW IF EXISTS nonsense CASCADE;


-- Define views for your intermediate steps here:
create view actualassign as
select assignment_id, group_id, username as grader
from grader natural join AssignmentGroup;


CREATE VIEW expect AS
select assignment_id, username as grader
from Grader, Assignment;

create view notassignevery as
(select * from expect) except (select assignment_id, grader from actualassign);

create view assignevery as
(select grader from actualassign) except (select grader from notassignevery);

-- have been assigned at least one group each assignment
create view satisfied1 as
select assignment_id, group_id, grader
from (select grader from assignevery) as every natural join actualassign;

-- condition2
create view allstudent as
select username
from MarkusUser
where type = 'student';

create view expectstudent as
select username, grader
from allstudent, (select grader from satisfied1) as satisfied;

create view actualstudent as
select username, grader
from Membership natural join satisfied1;

-- student's username not in any group
create view nonsense as
(select username from expectstudent) except (select username from actualstudent);

-- create view satisfiedboth as
-- (select grader from satisfied1) except (select grader from nonsense natural join expectstudent);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q7
(select grader from satisfied1) except (select grader from nonsense natural join expectstudent);
