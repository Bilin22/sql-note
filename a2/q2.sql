-- Getting soft?

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
	grader_username varchar(25) NOT NULL,
	grader_name varchar(100) NOT NULL,
	average_mark_all_assignments real NOT NULL,
	mark_change_first_last real NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS candidate CASCADE;
DROP VIEW IF EXISTS assigned CASCADE;
DROP VIEW IF EXISTS checklist CASCADE;
DROP VIEW IF EXISTS notalways CASCADE;
DROP VIEW IF EXISTS atleastone CASCADE;
DROP VIEW IF EXISTS gradedcheck CASCADE;
DROP VIEW IF EXISTS actuallygraded CASCADE;
DROP VIEW IF EXISTS notevery CASCADE;
DROP VIEW IF EXISTS gradedevery CASCADE;
DROP VIEW IF EXISTS check10 CASCADE;
DROP VIEW IF EXISTS atleast10 CASCADE;
DROP VIEW IF EXISTS atleast10grader CASCADE;
DROP VIEW IF EXISTS AGPair CASCADE;
DROP VIEW IF EXISTS SumWeights CASCADE;
DROP VIEW IF EXISTS percentmark CASCADE;
DROP VIEW IF EXISTS gradermark CASCADE;
DROP VIEW IF EXISTS withmember CASCADE;
DROP VIEW IF EXISTS avgmark CASCADE;
DROP VIEW IF EXISTS withdue CASCADE;
DROP VIEW IF EXISTS qualified CASCADE;
DROP VIEW IF EXISTS lastdate CASCADE;
DROP VIEW IF EXISTS lastdatemark CASCADE;
DROP VIEW IF EXISTS firstdate CASCADE;
DROP VIEW IF EXISTS firstdatemark CASCADE;
DROP VIEW IF EXISTS difference CASCADE;
DROP VIEW IF EXISTS avgall CASCADE;


-- Define views for your intermediate steps here:

-- they have been assigned to grade at least one group on every assignment.
create view candidate as
select username
from markususer
where type = 'instructor' or type = 'TA';

create view assigned as
select username, assignment_id 
from grader natural join assignmentgroup;

create view checklist as
select * 
from (select username from candidate) as username,
(select assignment_id from assignment) as assignment_id;

create view notalways as
(select * from checklist) except (select * from assigned);

create view atleastone as
(select username from assigned) except (select username from notalways);

-- have complete grading for at least 10 groups on each assignment.

-- checklist for graded at least one group on every assignment
create view gradedcheck as
select assignment_id, username 
from assignment,atleastone;

create view actuallygraded as
select assignment_id, username 
from result natural join assignmentgroup natural join atleastone;

create view notevery as
(select * from gradedcheck) except (select * from actuallygraded);

-- username and assignment_id for grader that have graded at least one group for every assignment
create view gradedevery as
(select * from actuallygraded) except (select * from notevery);


-- problem!!
-- less than 10 if count >= 1
create view check10 as
select assignment_id, username
from result natural join assignmentgroup natural join gradedevery 
group by assignment_id, username 
having count(group_id) < 10;

-- at least 10 (username) -- problem
create view atleast10 as
(select username from gradedevery) except (select username from check10);


-- the avg grade per students on each assignment have gone up overtime
-- already got the username of graders satisfied 2 conditions

-- tag them with group_id
create view atleast10grader as
select username as grader_username, group_id
from atleast10 natural join grader; 


-- the group_id, the assignment_id and the percent total mark
CREATE VIEW AGPair as
select assignment_id, group_id, mark
from assignment natural join assignmentgroup natural join result;

create view SumWeights as
select assignment_id, sum(weight)
from RubricItem
group by assignment_id;


create view percentmark as
select assignment_id, group_id, (mark/sum)*100 as percentage
from AGPair natural join SumWeights;

-- assignment_id, group_id, percentage, grader_username
create view gradermark as
select assignment_id, group_id, percentage, grader_username
from atleast10grader natural join percentmark;

create view withmember as
select group_id, assignment_id, percentage, grader_username, username
from gradermark natural join membership;

create view avgmark as
select assignment_id, grader_username, sum(percentage)/count(group_id) as avgeach
from withmember
group by assignment_id, grader_username;


create view withdue as
select assignment_id, grader_username, avgeach, due_date
from avgmark natural join assignment;

create view qualified as
select assignment_id, grader_username, avgeach, due_date
from withdue w1
where not exists (select * 
				from withdue w2
				where w2.due_date > w1.due_date and w2.avgeach < w1.avgeach);

create view lastdate as
select grader_username, max(due_date) as last
from qualified
group by grader_username;

create view lastdatemark as
select qualified.grader_username, qualified.avgeach as lastmark
from qualified join lastdate on qualified.due_date = lastdate.last;

create view firstdate as
select grader_username, min(due_date) as first
from qualified
group by grader_username;

create view firstdatemark as
select qualified.grader_username, qualified.avgeach as firstmark
from qualified join firstdate on qualified.due_date = firstdate.first;

create view difference as
select grader_username, lastmark - firstmark as mark_change_first_last
from firstdatemark natural join lastdatemark;

create view avgall as
select grader_username, firstname||' '||surname as grader_name, 
	avg(avgeach) as average_mark_all_assignments
from qualified,markususer 
where qualified.grader_username = markususer.username
group by grader_username, firstname||' '||surname;




-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
select grader_username, grader_name, average_mark_all_assignments, mark_change_first_last
from avgall natural join difference;
