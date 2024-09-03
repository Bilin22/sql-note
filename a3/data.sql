set search_path to recording;

-- Staff
insert into 
Staff(staff_id, staff_name, email, phone_number, is_engineer)
values
(1233, 'Donna Meagle', 'donna@gmail.com', '1233', FALSE),
(1232, 'Leslie Knope', 'leslie@gmail.com', '1232', FALSE),
(1234, 'Tom Haverford', 'tom@gmail.com', '1234', FALSE),
(1231, 'April Ludgate', 'april@gmail.com', '1231', FALSE),
(5678, 'Ben Wyatt', 'ben@gmail.com', '5678', TRUE),
(9942, 'Ann Perkins', 'ann@gmail.com', '9942', TRUE),
(6521, 'Chris Traeger', 'chris@gmail.com', '6521', TRUE),
(6754, 'Andy Dwyer','andy@gmail.com', '6754', FALSE),
(4523, 'Andrew Burlinson', 'andrew@gmail.com', '4523', FALSE),
(2224, 'Michael Chang', 'mi@gmail.com', '2224', FALSE),
(7832, 'James Pierson', 'j@gmail.com', '7832', FALSE),
(1000, 'Duke Silver', 'duke@gmail.com', '1000', FALSE);

-- Certification
insert into
	Certification(staff_id, certificates)
	values
	(5678, 'ABCDEFGH-123I'),
	(5678, 'JKLMNOPQ-456R'),
	(9942, 'SOUND-123-AUDIO');


-- Band
insert into
	Band(band_id, band_name)
	values
	(1, 'Mouse Rat');

-- Member
insert into 
	Member(member_id, band_id)
	values
	(6754, 1),
	(4523, 1),
	(2224, 1),
	(7832, 1);


-- Studio
insert into
	Studio(studio_id, studio_name, studio_address)
	values
	(90, 'Pawnee Recording Studio', 
		'123 Valley spring lane, Pawnee, Indiana'),
	(91, 'Pawnee Sound', '353 Western Ave, Pawnee, Indiana'),
	(92, 'Eagleton Recording Studio', '829 Division, Eagleton, Indiana');

-- Manage
insert into
	Manage(management_id, studio_id, manager_id, manage_date)
	values
	(81, 90, 1233, '2018-12-02'),
	(82, 90, 1234, '2017-01-13'),
	(83, 90, 1231, '2008-03-21'),
	(84, 91, 1233, '2011-05-07'),
	(85, 92, 1232, '2020-09-05'),
	(86, 92, 1234, '2016-09-05'),
	(87, 92, 1232, '2010-09-05');



-- Session
insert into
	Session(session_id)
	values
	(1),
	(2),
	(3),
	(4),
	(5),
	(6),
	(7),
	(8);


-- Support
insert into
	Support(session_id, engineer_id)
	values
	(1, 5678),
	(1, 9942),
	(2, 5678),
	(2, 9942),
	(3, 5678),
	(3, 9942),
	(4, 5678),
	(5, 5678),
	(6, 6521),
	(7, 5678),
	(8, 5678);


-- Accommodate
insert into
	Accommodate(studio_id, session_id, starts_at, ends_at, fee)
	values
	(90, 1, 'Jan-08-2023 10:00', 'Jan-08-2023 15:00', 1500),
	(90, 2, 'Jan-10-2023 13:00', 'Jan-11-2023 14:00', 1500),
	(90, 3, 'Jan-12-2023 18:00', 'Jan-13-2023 20:00', 1500),
	(90, 4, 'Mar-10-2023 11:00', 'Mar-12-2023 15:00', 2000),
	(90, 5, 'Mar-11-2023 13:00', 'Mar-12-2023 15:00', 2000),
	(90, 6, 'Mar-13-2023 10:00', 'Mar-13-2023 20:00', 1000),
	(92, 7, 'Sep-25-2023 11:00', 'Sep-26-2023 23:00', 1000),
	(92, 8, 'Sep-29-2023 11:00', 'Sep-30-2023 23:00', 1000);

-- Play
insert into 
	Play(session_id, artist_id)
	values
	(1, 6754),
	(1, 4523),
	(1, 2224),
	(1, 7832),
	(1, 1000),
	(2, 6754),
	(2, 4523),
	(2, 2224),
	(2, 7832),
	(2, 1000),
	(3, 6754),
	(3, 4523),
	(3, 2224),
	(3, 7832),
	(3, 1000),
	(4, 6754),
	(4, 4523),
	(4, 2224),
	(4, 7832),
	(5, 6754),
	(5, 4523),
	(5, 2224),
	(5, 7832),
	(6, 6754),
	(6, 1234),
	(7, 6754),
	(8, 6754);

-- RecordedSegment

-- first session, 10 segments, no track
DO $$
BEGIN
	FOR i in 100..109 LOOP
	INSERT INTO RecordedSegment(segment_id, length, format, session_id)
	values(i, 60, 'WAV', 1);
	END LOOP;
END;
$$;

-- second session, 5 segments, used for
-- "5,000 Candles in the Wind" 
-- on album "The Awesome Album".
DO $$
BEGIN
	FOR i in 110..114 LOOP
	INSERT INTO RecordedSegment(segment_id, length, format, session_id)
	values(i, 60, 'WAV', 2);
	END LOOP;
END;
$$;

-- 3 session, 4 segments

DO $$
BEGIN
	FOR i in 115..118 LOOP
	INSERT INTO RecordedSegment(segment_id, length, format, session_id)
	values(i, 60, 'WAV', 3);
	END LOOP;
END;
$$;

-- 4 session, 2 segments
DO $$
BEGIN
	FOR i in 119..120 LOOP
	INSERT INTO RecordedSegment(segment_id, length, format, session_id)
	values(i, 120, 'WAV', 4);
	END LOOP;
END;
$$;

-- session 5, no segment

-- session 6, 5 segments, of one minute each, recorded as WAV.
DO $$
BEGIN
	FOR i in 121..125 LOOP
	INSERT INTO RecordedSegment(segment_id, length, format, session_id)
	values(i, 60, 'WAV', 6);
	END LOOP;
END;
$$;

-- session 7
-- 9 segments, of 3 minutes each, recorded as AIFF.

DO $$
BEGIN
	FOR i in 126..134 LOOP
	INSERT INTO RecordedSegment(segment_id, length, format, session_id)
	values(i, 180, 'AIFF', 7);
	END LOOP;
END;
$$;

-- session 8
-- 6 segments, of 3 minutes each, recorded as WAV.
DO $$
BEGIN
	FOR i in 135..140 LOOP
	INSERT INTO RecordedSegment(segment_id, length, format, session_id)
	values(i, 180, 'WAV', 8);
	END LOOP;
END;
$$;

-- Album
insert into 
	Album(album_id, album_name, release_date)
	values
	(1, 'The Awesome Album', '2023-05-25'),
	(2, 'Another Awesome Album', '2023-10-29');

-- Track
insert into 
	Track(track_id, track_name)
	values
	(71, '5,000 Candles in the Wind'),
	(72, 'Catch Your Dream'),
	(73, 'May Song'),
	(74, 'The Pit'),
	(75, 'Remember'),
	(76, 'The Way You Look Tonight'),
	(77, 'Another Song');

-- SegmentInTrack
-- session 2, 5 segments used for track71
DO $$
BEGIN
	FOR i in 110..114 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 71);
	END LOOP;
END;
$$;

-- session 3, 4 segments used for track 72
DO $$
BEGIN
	FOR i in 115..118 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 72);
	END LOOP;
END;
$$;

-- session 4, 2 segments, track 72
DO $$
BEGIN
	FOR i in 119..120 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 72);
	END LOOP;
END;
$$;

-- session 6, 5 segments, track71 & 72

DO $$
BEGIN
	FOR i in 121..125 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 71);
	END LOOP;
END;
$$;


DO $$
BEGIN
	FOR i in 121..125 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 72);
	END LOOP;
END;
$$;

-- session 7, first 5 unuse, next 2 used in 
-- track73, next 2 on track74
DO $$
BEGIN
	FOR i in 131..132 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 73);
	END LOOP;
END;
$$;

DO $$
BEGIN
	FOR i in 133..134 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 74);
	END LOOP;
END;
$$;

-- session 8 , 2 - track 75, 2- track 76, 2- track 77
DO $$
BEGIN
	FOR i in 135..136 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 75);
	END LOOP;
END;
$$;


DO $$
BEGIN
	FOR i in 137..138 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 76);
	END LOOP;
END;
$$;

DO $$
BEGIN
	FOR i in 139..140 LOOP
	INSERT INTO SegmentInTrack(segment_id, track_id)
	values(i, 77);
	END LOOP;
END;
$$;


-- TrackInAlbum
-- track 71 - album1
-- track 72 - album1
-- track 73 - album2
-- track74 - album2
-- 75, 76, 77- 2
DO $$
BEGIN
	FOR i in 71..72 LOOP
	INSERT INTO TrackInAlbum(album_id, track_id)
	values(1, i);
	END LOOP;
END;
$$;

DO $$
BEGIN
	FOR i in 73..77 LOOP
	INSERT INTO TrackInAlbum(album_id, track_id)
	values(2, i);
	END LOOP;
END;
$$;



