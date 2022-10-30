-- Ratings histogram.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q7 CASCADE;

CREATE TABLE q7(
    driver_id INTEGER,
    r5 INTEGER,
    r4 INTEGER,
    r3 INTEGER,
    r2 INTEGER,
    r1 INTEGER
);

DROP VIEW IF EXISTS RatingWithID CASCADE;
DROP VIEW IF EXISTS OneStar CASCADE;
DROP VIEW IF EXISTS TwoStar CASCADE;
DROP VIEW IF EXISTS ThreeStar CASCADE;
DROP VIEW IF EXISTS FourStar CASCADE;
DROP VIEW IF EXISTS FiveStar CASCADE;
DROP VIEW IF EXISTS NoReviews CASCADE;
DROP VIEW IF EXISTS DriverIDs CASCADE;

create view RatingWithID as
    select driver_id, rating 
    from DriverRating, Dispatch, ClockedIn
    where (DriverRating.request_id = Dispatch.request_id) 
            and (Dispatch.shift_id = ClockedIn.shift_id);

create view DriverIDs as
	select driver_id from Driver;
            
create view OneStar as
	select d.driver_id, coalesce(sum(rating), 0) as r1
	from DriverIDs d left join RatingWithID r on d.driver_id = r.driver_id and r.rating = 1
	group by d.driver_id;

create view TwoStar as
	select d.driver_id, coalesce(sum(rating) / 2, 0) as r2
	from DriverIDs d left join RatingWithID r on d.driver_id = r.driver_id and r.rating = 2
	group by d.driver_id;

create view ThreeStar as 
	select d.driver_id, coalesce(sum(rating) / 3, 0) as r3
	from DriverIDs d left join RatingWithID r on d.driver_id = r.driver_id and r.rating = 3
	group by d.driver_id;

create view FourStar as
	select d.driver_id, coalesce(sum(rating) / 4, 0) as r4
	from DriverIDs d left join RatingWithID r on d.driver_id = r.driver_id and r.rating = 4
	group by d.driver_id;

create view FiveStar as
	select d.driver_id, coalesce(sum(rating) / 5, 0) as r5
	from DriverIDs d left join RatingWithID r on d.driver_id = r.driver_id and r.rating = 5
	group by d.driver_id;

--create view NoReviews as 
--    select distinct d.driver_id,
--            integer '0' as r1, 
  --          integer '0' as r2, 
    --        integer '0' as r3,
      --      integer '0' as r4,
        --    integer '0' as r5
--    from ClockedIn d
--    where not exists (select * from clockedin natural join RatingWithID where driver_id = d.driver_id);
    
INSERT INTO Q7 
-- THERE IS AN ABSOLUTELY INSANE ERROR WHERE IT JUST DOESN'T SELECT THE RIGHT THING AND GIVE THEM THE RIGHT ATTRIBUTES 
-- THE FOLLOWING GIVES THE RIGHT RESULTS BUT IT'S CLEARLY WRONG
--	select onestar.driver_id as driver_id, r5 as r1, r4 as r2, r3 as r3, r2 as r4, r1 as r5
--	from OneStar natural join
--		TwoStar natural join 
--		ThreeStar natural join 
--		FourStar natural join FiveStar;
-- THIS GIVES THE RATINGS BACKWARDS BUT IT'S CLEARLY RIGHT WITH NO AMBIGUITY 
-- ALSO WORKS IF YOU RUN THIS QUERY BY HAND IN THE TERMINAL 
-- ALSO CHECKED BY CHANGING UP NAMES 
	select onestar.driver_id as driver_id, r5, r4, r3, r2, r1
	from OneStar natural join
		TwoStar natural join 
		ThreeStar natural join 
		FourStar natural join FiveStar;
-- by the way i have in fact tried hard naming using the as keyword 
-- turns out the issue is that it needs to be in the same order (???!) as the schema

--INSERT INTO Q7
--	select * from NoReviews;
	
-- TESTED

