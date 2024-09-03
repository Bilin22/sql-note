-- 2. For each person in the database, 
-- report their ID and the number of recording sessions they have played at.
--  Include everyone, even if they are a manager or engineer, 
-- and even if they never played at any sessions.

set search_path to recording;
DROP TABLE IF EXISTS q2 CASCADE;

create table q2 (
    artist_id integer not null,
    session_num integer not null
);

-- drop view
drop view if exists allstaff cascade;
drop view if exists  sessioncount cascade;



-- intermediate views
create view allstaff as
    select staff_id as artist_id
    from staff;

create view sessioncount as
    select artist_id, coalesce(count(distinct session_id), 0) as session_num 
    from allstaff natural full join play group by artist_id;

insert into q2
select * 
from sessioncount;

select * from q2;