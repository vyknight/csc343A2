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

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS RatingWithID CASCADE;
DROP VIEW IF EXISTS OneStar CASCADE;
DROP VIEW IF EXISTS TwoStar CASCADE;
DROP VIEW IF EXISTS ThreeStar CASCADE;
DROP VIEW IF EXISTS FourStar CASCADE;
DROP VIEW IF EXISTS FiveStar CASCADE;
DROP VIEW IF EXISTS NoReviews CASCADE;


-- Define views for your intermediate steps here:

-- for each rating add one to that star level 
-- at the end sum up each category 

-- link driver to rating
create view RatingWithID as
    select driver_id, rating 
    from DriverRating, Dispatch, ClockedIn
    where (DriverRating.request_id = Dispatch.request_id) 
            and (Dispatch.shift_id = ClockedIn.shift_id);

create view OneStar as
    select driver_id,
            integer '1' as r1, 
            integer '0' as r2, 
            integer '0' as r3,
            integer '0' as r4,
            integer '0' as r5
    from RatingWithID where rating = integer '1';

create view TwoStar as
    select driver_id,
            integer '0' as r1, 
            integer '1' as r2, 
            integer '0' as r3,
            integer '0' as r4,
            integer '0' as r5
    from RatingWithID where rating = integer '2';

create view ThreeStar as
    select driver_id,
            integer '0' as r1, 
            integer '0' as r2, 
            integer '1' as r3,
            integer '0' as r4,
            integer '0' as r5
    from RatingWithID where rating = integer '3';

create view FourStar as
    select driver_id,
            integer '0' as r1, 
            integer '0' as r2, 
            integer '0' as r3,
            integer '1' as r4,
            integer '0' as r5
    from RatingWithID where rating = integer '4';

create view FiveStar as
    select driver_id,
            integer '0' as r1, 
            integer '0' as r2, 
            integer '0' as r3,
            integer '0' as r4,
            integer '1' as r5
    from RatingWithID where rating = integer '5';

create view NoReviews as 
    select driver_id,
            integer '0' as r1, 
            integer '0' as r2, 
            integer '0' as r3,
            integer '0' as r4,
            integer '0' as r5
    from Driver
    where not exists (select * from driver natural join RatingWithID); -- should nat join on driver_id

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q7
    select OneStar.driver_id as driver_id,
            sum(r5) as r5,
            sum(r4) as r4,
            sum(r3) as r3,
            sum(r2) as r2,
            sum(r1) as r1
    from OneStar Union TwoStar Union ThreeStar Union FourStar Union FiveStar UNION NoReviews; 

-- NOT TESTED 