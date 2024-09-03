-- A1 report.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q10 CASCADE;

CREATE TABLE q10 (
	group_id bigint NOT NULL,
	mark real DEFAULT NULL,
	compared_to_average real DEFAULT NULL,
	status varchar(5) DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS A1group CASCADE;
DROP VIEW IF EXISTS sumweight CASCADE;
DROP VIEW IF EXISTS A1percent CASCADE;
DROP VIEW IF EXISTS average CASCADE;
DROP VIEW IF EXISTS comparison CASCADE;
DROP VIEW IF EXISTS gradestatus CASCADE;


-- Define views for your intermediate steps here:
CREATE VIEW A1group AS
select assignment_id, group_id, mark
from Assignment natural full join AssignmentGroup natural full join Result
where description = 'A1';

-- sum of weights
create view sumweight as
select assignment_id, sum(weight)
from RubricItem
group by assignment_id;

create view A1percent as
select group_id, (mark/sum)*100 as mark
from A1group natural left join sumweight;

create view average as
select avg(mark) as avg
from A1percent;

create view comparison as
select group_id, mark, (mark - avg) as compared_to_average
from A1percent,average;

create view gradestatus as
select group_id, mark, compared_to_average, case
		when  compared_to_average < 0 then 'below'
		when  compared_to_average = 0 then 'at'
		when compared_to_average > 0 then 'above'
		else NULL
		end as status
from comparison;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10
select * 
from gradestatus;
