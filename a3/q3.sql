-- 3. Find the recording session that produced the 
-- greatest total number of seconds of recording segments. 
-- Report the ID and name of everyone who played at that session, 
-- whether as part of a band or in a solo capacity.

set search_path to recording;
DROP TABLE IF EXISTS q3 CASCADE;

create table q3 (
    artist_id integer not null,
    artist_name text not null
);

-- drop view
drop view if exists totaltime cascade;
drop view if exists  greatest cascade;
drop view if exists  artist cascade;



-- intermediate views
create view totaltime as
    select session_id, sum(length) as total 
    from recordedsegment 
    group by session_id;


create view greatest as
    select session_id 
    from totaltime t1 
    where not exists (
        select * from totaltime t2 
        where t1.total < t2.total);

create view artist as
    select artist_id, staff_name as artist_name 
    from (greatest natural join play) join staff 
        on artist_id = staff_id;



insert into q3
select * 
from artist;

select * from q3;