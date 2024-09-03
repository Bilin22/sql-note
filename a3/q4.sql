-- 4. Find the album that required the greatest number of recording sessions. 
-- Report the album ID and name, the number of recording sessions, 
-- and the number of different people who played on the album. 
-- If a person played both as part of a band and in a solo capacity, 
-- count them only once.

set search_path to recording;
DROP TABLE IF EXISTS q4 CASCADE;

create table q4 (
    album_id integer not null,
    album_name text not null,
    num_session integer not null,
    num_artist integer not null
);

-- drop view
drop view if exists countsession cascade;
drop view if exists  greatestsession cascade;
drop view if exists  withname cascade;



-- intermediate views
create view countsession as
    select album_id, 
        count(distinct session_id) as num_session, 
        count(distinct artist_id) as num_artist
    from trackinalbum natural join segmentintrack 
        natural join recordedsegment natural join play
    group by album_id;

create view greatestsession as
    select *
    from countsession c1
    where not exists (select * 
            from countsession c2
            where c1.num_session < c2.num_session);

create view withname as
    select album_id, album_name, num_session, num_artist
    from greatestsession natural join album;



insert into q4
select * 
from withname;

select * from q4;