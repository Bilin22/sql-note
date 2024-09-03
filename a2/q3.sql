-- Solo superior.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
	assignment_id integer NOT NULL,
	description varchar(100) NOT NULL,
	num_solo integer NOT NULL,
	average_solo real NOT NULL,
	num_collaborators integer NOT NULL,
	average_collaborators real NOT NULL,
	average_students_per_group real NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS AGPair  CASCADE;
DROP VIEW IF EXISTS SumWeights CASCADE;
DROP VIEW IF EXISTS percentmark CASCADE;
DROP VIEW IF EXISTS  withmember CASCADE;
DROP VIEW IF EXISTS nummember CASCADE;
DROP VIEW IF EXISTS  nonsolo CASCADE;
DROP VIEW IF EXISTS nonmult CASCADE;
DROP VIEW IF EXISTS  qualifiedid CASCADE;
DROP VIEW IF EXISTS mark CASCADE;
DROP VIEW IF EXISTS worksolo CASCADE;
DROP VIEW IF EXISTS soloavg CASCADE;
DROP VIEW IF EXISTS  ingroup CASCADE;
DROP VIEW IF EXISTS groupavg CASCADE;
DROP VIEW IF EXISTS highsolo CASCADE;
DROP VIEW IF EXISTS countsolo CASCADE;
DROP VIEW IF EXISTS countcollab CASCADE;
DROP VIEW IF EXISTS solograde CASCADE;
DROP VIEW IF EXISTS collabgrade CASCADE;
DROP VIEW IF EXISTS combine CASCADE;
DROP VIEW IF EXISTS avgperson CASCADE;


-- Define views for your intermediate steps here:
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

create view withmember as
select assignment_id, group_id, percentage, username
from percentmark natural join membership;

create view nummember as
select assignment_id, group_id, count(username) as num
from withmember
group by assignment_id, group_id;

create view nonsolo as
select assignment_id
from nummember
group by assignment_id
having min(num) > 1;

create view nonmult as
select assignment_id
from nummember
group by assignment_id
having max(num) = 1;

-- assignment_id
create view qualifiedid as
(select assignment_id from nummember) except 
((select * from nonsolo) union (select * from nonmult));

create view mark as
select assignment_id, group_id, percentage, username
from qualifiedid natural join withmember;

create view worksolo as
select assignment_id, group_id, count(username) as size
from mark
group by assignment_id, group_id
having count(username) = 1;


create view soloavg as
select assignment_id, avg(percentage) as soloavg
from worksolo natural join mark
group by assignment_id;

create view ingroup as
select assignment_id,  group_id, count(username) as size
from mark
group by assignment_id, group_id
having count(username) > 1;

create view groupavg as
select assignment_id, avg(percentage) as groupavg
from ingroup natural join mark
group by assignment_id;


-- assignment_id
create view highsolo as
select assignment_id
from groupavg natural join soloavg
where soloavg > groupavg;

-- count solo
create view countsolo as
select assignment_id, count(group_id) as num_solo 
from highsolo natural join worksolo 
group by assignment_id;


-- count collab
create view countcollab as
select assignment_id,sum(size) as num_collaborators
from highsolo natural join ingroup
group by assignment_id;


-- solo avg
create view solograde as
select assignment_id, avg(percentage) as average_solo
from highsolo natural join worksolo natural join mark
group by assignment_id;


-- collab avg
create view collabgrade as
select assignment_id, sum(distinct percentage)/count(distinct group_id) as average_collaborators
from highsolo natural right join ingroup natural left join mark
group by assignment_id;

-- avg person per group
create view combine as
(select * from worksolo) union (select * from ingroup);

create view avgperson as
select assignment_id, sum(size)/count(group_id) as average_students_per_group
from combine
group by assignment_id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
select assignment_id, description, num_solo, average_solo, 
	num_collaborators, average_collaborators, average_students_per_group
from countsolo natural join countcollab natural join solograde natural join collabgrade
	natural join avgperson natural join assignment;
