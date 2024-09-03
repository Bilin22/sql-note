
-- 1. For each studio, 
-- report the ID and name of its current manager, 
-- and the number of albums it has contributed to. 
-- A studio contributed to an album iff 
-- at least one recording segment recorded there is part of that album.

set search_path to recording;
DROP TABLE IF EXISTS q1 CASCADE;

create table q1 (
    studio_id integer not null,
    manager_id integer not null,
    manager_name text not null,
    album_num integer not null
);

-- drop view
drop view if exists manager cascade;
drop view if exists  current cascade;
drop view if exists  countalbum cascade;
drop view if exists  finalcount cascade;


-- intermediate views
create view manager as
    select studio_id, manage_date
    from manage m1
    where not exists (select *
                    from manage m2
                    where m2.studio_id = m1.studio_id 
                    and m2.manage_date > m1.manage_date);


-- manager_id + studio_id + manager_name
create view current as
    select studio_id, manager_id, staff_name as manager_name 
    from (manage natural join manager) join staff on staff_id = manager_id;

-- studio_id + count
create view countalbum as
    select studio_id, count(distinct album_id) 
    from recordedsegment natural join segmentintrack
        natural join trackinalbum 
        natural join accommodate 
    group by studio_id;

create view finalcount as
    select studio_id, manager_id, manager_name, coalesce(count, 0) 
        as album_num 
    from current natural full join countalbum;

insert into q1
select * 
from finalcount;

select * from q1;