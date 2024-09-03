drop schema if exists recording cascade;
create schema recording;
set search_path to recording;


-- Could not:
-- 1. Every session has at most 3 sound engineers.
-- Reason: since the engineers associated with the session
--         is recorded in "Support" table, we cannot make 
--         sure that the upper limit is 3 because (engineer_id, session_id)
--         together forms the primary key.
-- 2. An Album contains at least 2 tracks.
-- Reason: Though it may seen reasonable to add "track1"
--         "track2" attributes to the Album table, we would
--          violate the no null constraint if the album contains
--          exactly 3 track.
     

-- Did not:
-- 1. A band must have at least 1 member.
-- Reason: this constraint can be enforced if we put 
--         member_id together with band_id in the Band table.
--         But this would result in redundancy for bands with
--         multiple members.


-- Extra Constraints:
-- 1. Every track must contain at least one sound segment.
-- 2. The end (date+time) of a session must greater than
--    the start (date+time) of a session.
-- 3. no two staffs own the same email and phone_number.
-- 4. no two studios have same studio_name and studio_address.



-- Assumptions:
-- 1. Each member belongs to exactly one band. (i.e. no
--    one can be the member of more than one bands.)
-- 2. If a band played on a session, all members of 
-- this band are played on this session.
-- 3. The same segment can be used in different tracks.
-- 4. The same tracks can be used in different albums.
-- 5. Every staff that is sound engineer (appears in the soundengineer table) 
-- and support the recording session 
-- will have attribute "is_engineer" set to TRUE.
-- 6. Only sound engineers have certificates.



-- Schema

-- Staff
-- The staffs involved in the recording procedures
-- staffs are identified by staff_id
-- everyone has a staff_id, a staff_name, an email (unique),
-- and a phone_number (unique), and a boolean attribute called is_engineer
-- which default is FALSE.

create table Staff (
     staff_id integer primary key,
     staff_name text not null,
     email text not null unique,
     phone_number text not null unique,
     is_engineer boolean not null default false);


-- Certification
-- the certifications of sound engineers
-- every certification is associated the corresponding staff_id
-- an engineer may have 0, 1, or many cerificates.
-- the sound engineer have 0 certificate will not be recorded here.

create table Certification (
     staff_id integer not null references Staff(staff_id),
     certificates text not null,
     primary key(staff_id, certificates));


-- Band
-- a group of people who sometimes play together
-- every Band is uniquely identified by its band_id
-- every band has a band_name
create table Band (
     band_id integer primary key,
     band_name text not null
);

-- Member 
-- member of a band
-- each member is uniqueli identified by member_id
-- every band has at least one member
create table Member(
     member_id integer not null references Staff(staff_id),
     band_id integer not null references Band(band_id),
     primary key(member_id)
);


-- Studio
-- a studio
-- each studio is identified by its studio_id
-- each studio has its studio_name and studio_address, this combination
-- is unique
create table Studio (
     studio_id integer primary key,
     studio_name text not null,
     studio_address text not null,
     unique(studio_name, studio_address)
);


-- Session
-- a recording session
-- each session is uniquely identified by session_id
create table Session(
     session_id integer not null,
     primary key(session_id)
);

-- Support
-- the technical support for a session
-- each session has at least 1, at most 3 sound engineers.
create table Support(
     session_id integer not null references Session(session_id),
     engineer_id integer not null references Staff(staff_id),
     primary key(session_id, engineer_id));



-- Accommodate
-- a description of the session studio combination
-- accommodation relationship is uniquely identified 
-- by the combination of studio_id and session_id
-- it also records the start time(starts_at), end time
-- (ends_at) and the fee of each session, 
-- where starts_at is unique if two session are held in the same studio.
-- each session must accompany by at least 1
-- at most 3 sound engineers.

create table Accommodate(
     studio_id integer not null references Studio(studio_id),
     session_id integer not null references Session(session_id),
     starts_at timestamp not null,
     ends_at timestamp not null,
     fee real not null,
     unique(studio_id, starts_at),
     check (ends_at > starts_at),
     primary key(studio_id, session_id)
);



-- Manage
-- the history of a studio's managers
-- each management is uniquely identified by the management_id
-- each manager is identified by their manager_id
-- each manager has their manage_date, and the studio_id
-- of the studio they are managing from manage_date
-- the combination of (manage_date, studio_id) is unique
create table Manage(
     management_id integer primary key,
     studio_id integer not null references Studio(studio_id),
     manager_id integer not null references Staff(staff_id),
     manage_date date not null,
     unique(manage_date, studio_id)

);


-- Play
-- the performance at the recording session
-- every play is identified by an artist_id, and
-- has one session_id (belongs to one session)
create table Play(
     session_id integer not null references Session(session_id),
     artist_id integer not null references Staff(staff_id),
     primary key(session_id, artist_id)
);


-- RecordedSegment
-- segment of sound recording as a product of recording session
-- each segment has a segment_id, a length(integer number of sec), 
-- a format, and belongs
-- to one session_id.
create table RecordedSegment(
     segment_id integer primary key,
     length integer not null,
     format text not null,
     session_id integer not null references Session(session_id)
);

-- Album
-- each album has a unique album_id, an album_name, a release_date
-- and the track_id it contains
create table Album(
     album_id integer not null,
     album_name text not null,
     release_date date not null,
     primary key(album_id)
);


-- Track
-- The soundtrack used some segments
-- each track has a track_id, a track_name
create table Track(
     track_id integer primary key,
     track_name text not null
);

-- SegmentInTrack
-- desctiption that which segment belongs to which track
-- each combination is uniquely described by segment_id and track_id
create table SegmentInTrack(
     segment_id integer not null references RecordedSegment(segment_id),
     track_id integer not null references Track(track_id),
     primary key(segment_id, track_id)
);



-- TrackInAlbum
-- which track used in which albums
-- each combination is uniquely described by track_id
-- and album_id
create table TrackInAlbum(
     album_id integer not null references Album(album_id),
     track_id integer not null references Track(track_id),
     primary key(album_id, track_id)

);












