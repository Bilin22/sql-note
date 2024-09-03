-- Uneven workloads.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	assignment_id integer NOT NULL,
	username varchar(25) NOT NULL,
	num_assigned integer NOT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS assigned CASCADE;
DROP VIEW IF EXISTS countgroup CASCADE;
DROP VIEW IF EXISTS greater10 CASCADE;


-- Define views for your intermediate steps here:
create view assigned as
select assignment_id, group_id, username
from grader natural join assignmentgroup;

create view countgroup as
select assignment_id, username, count(group_id) as num_assigned
from assigned
group by assignment_id, username;


-- assignment_id of range greater than 10
create view greater10 as
select assignment_id
from countgroup
group by assignment_id
having max(num_assigned) - min(num_assigned) > 10;





-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
select assignment_id, username, num_assigned
from greater10 natural join countgroup;
