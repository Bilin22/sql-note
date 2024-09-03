-- Never solo by choice.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q8 CASCADE;

CREATE TABLE q8 (
	username varchar(25) NOT NULL,
	group_average real NOT NULL,
	solo_average real DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS expected CASCADE;
DROP VIEW IF EXISTS actualsub CASCADE;
DROP VIEW IF EXISTS notsubevery CASCADE;
DROP VIEW IF EXISTS subevery CASCADE;
DROP VIEW IF EXISTS allowmulti CASCADE;
DROP VIEW IF EXISTS multigroup CASCADE;
DROP VIEW IF EXISTS actualgroup CASCADE;
DROP VIEW IF EXISTS checkgroup CASCADE;
DROP VIEW IF EXISTS notalwaysmult CASCADE;
DROP VIEW IF EXISTS satisfiedboth CASCADE;
DROP VIEW IF EXISTS mustsolo CASCADE;
DROP VIEW IF EXISTS inmulti CASCADE;
DROP VIEW IF EXISTS SumWeight CASCADE;
DROP VIEW IF EXISTS multipercent CASCADE;
DROP VIEW IF EXISTS havesolo CASCADE;
DROP VIEW IF EXISTS solopercent CASCADE;


-- Define views for your intermediate steps here:

-- if student not in any group, in no case they can submit file for any assignment
-- so, select students from membership.

-- checklist for one student one file
CREATE VIEW expected AS
select distinct username, assignment_id
from membership, assignment
order by username;

-- the actual submission
create view actualsub as
select username, assignment_id
from Assignment natural left join AssignmentGroup natural join membership 
	natural right join Submissions;

-- not submit every!
create view notsubevery as
(select * from expected) except (select * from actualsub);

-- student's username that satisfied the first conition
create view subevery as
(select username from actualsub) except (select username from notsubevery);

-- find every assignment allows multimember group
create view allowmulti as
select assignment_id 
from Assignment
where group_max > 1;

-- find every group in such assignment that are multi-member
create view multigroup as
select assignment_id, group_id
from allowmulti natural join AssignmentGroup natural join membership
group by assignment_id, group_id
having count(username) > 1;

create view actualgroup as
select assignment_id,username
from multigroup natural join Membership;

create view checkgroup as
select assignment_id, username
from allowmulti, subevery;

create view notalwaysmult as
(select * from checkgroup) except (select * from actualgroup);

-- the username of students satisfied both conditions
create view satisfiedboth as
((select username from actualgroup) except 
	(select username from notalwaysmult)) intersect (select * from subevery);

-- the assignment id that only allow solo group
create view mustsolo as
(select assignment_id from assignment) except (select * from allowmulti);


-- the qualified students in multi-member group
create view inmulti as
select username, group_id, assignment_id, mark
from satisfiedboth natural join Membership natural join AssignmentGroup natural join allowmulti 
	natural join result;

-- sum of rubric item
create view SumWeight as
select assignment_id, sum(weight)
from RubricItem
group by assignment_id;

create view multipercent as
select username, avg((mark/sum)*100) as group_average
from inmulti natural join SumWeight
group by username, assignment_id;

-- work solo
create view havesolo as
select username, group_id, assignment_id, mark
from satisfiedboth natural join Membership natural join AssignmentGroup natural join mustsolo 
	natural join result;

create view solopercent as
select username, avg((mark/sum)*100) as solo_average
from havesolo natural join SumWeight
group by username, assignment_id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q8
select username, group_average, solo_average
from solopercent natural join multipercent;
