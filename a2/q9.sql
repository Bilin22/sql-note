-- Inseparable.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q9 CASCADE;

CREATE TABLE q9 (
	student1 varchar(25) NOT NULL,
	student2 varchar(25) NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS allowmulti CASCADE;
DROP VIEW IF EXISTS checkgroup CASCADE;
DROP VIEW IF EXISTS atleast1 CASCADE;
DROP VIEW IF EXISTS multimember CASCADE;
DROP VIEW IF EXISTS inmulti CASCADE;
DROP VIEW IF EXISTS allpair CASCADE;
DROP VIEW IF EXISTS notalwaysmult CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW allowmulti AS 
select distinct assignment_id
from Assignment natural left join AssignmentGroup
where group_max > 1;

create view checkgroup as
select assignment_id, group_id
from allowmulti natural left join AssignmentGroup natural left join membership;

create view atleast1 as
select assignment_id, group_id
from checkgroup
where not exists (select * 
				from checkgroup
				where group_id is null);

-- find all groups that allow multimember
create view multimember as
select assignment_id, group_id
from atleast1 natural left join AssignmentGroup natural left join membership
group by assignment_id, group_id
having count(username) > 1;

-- tagged with each group member
create view inmulti as
select assignment_id,group_id, username
from multimember natural join Membership;

-- all pairs of students in alpha order of each assignment each group
create view allpair as
select i1.assignment_id, i1.username as student1, i2.username as student2
from inmulti i1, inmulti i2
where i1.username < i2.username and i1.assignment_id = i2.assignment_id and 
	i1.group_id = i2.group_id;


-- we only have one assignment for now
-- select pairs that never appear again in another assignment
create view notalwaystgt as
select a1.student1, a1.student2
from allpair a1, allpair a2
where a1.assignment_id < a2.assignment_id
		and not exists (select * 
						from allpair a3
						where a1.student1 = a3.student2 and a1.student2 = a3.student2 and
							a1.assignment_id <> a3.assignment_id);



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q9
(select student1, student2 from allpair) except (select student1, student2 from notalwaystgt);
