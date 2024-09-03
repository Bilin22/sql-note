-- Steady work.

-- You must not change the next 2 lines or the table definition.
SET search_path TO markus;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6 (
	group_id integer NOT NULL,
	first_file varchar(25) DEFAULT NULL,
	first_time timestamp DEFAULT NULL,
	first_submitter varchar(25) DEFAULT NULL,
	last_file varchar(25) DEFAULT NULL,
	last_time timestamp DEFAULT NULL,
	last_submitter varchar(25) DEFAULT NULL,
	elapsed_time interval DEFAULT NULL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS A1group CASCADE;
DROP VIEW IF EXISTS A1sub CASCADE;
DROP VIEW IF EXISTS the1 CASCADE;
DROP VIEW IF EXISTS last CASCADE;

-- Define views for your intermediate steps here:
create view A1group as
select group_id, username
from assignment natural join assignmentgroup natural join membership
where description = 'A1';

-- submission for each group
create view A1sub as
select group_id, username, file_name, submission_date
from A1group natural join Submissions; -- matching on username + group_id


-- first one
create view the1 as 
select group_id, file_name as first_file, submission_date as first_time, 
	username as first_submitter
from A1sub s1
where not exists (select * 
				from A1sub s2
				where s2.group_id = s1.group_id and s2.submission_date < s1.submission_date);


-- last one
create view last as
select group_id, file_name as last_file, submission_date as last_time,
	username as last_submitter
from A1sub s1
where not exists (select *
				from A1sub s2
				where s2.group_id = s1.group_id and s2.submission_date > s1.submission_date);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6
select group_id, first_file, first_time, first_submitter, 
	last_file, last_time, last_submitter, (last_time) - (first_time) as elapsed_time
from the1 natural join last;
