-- Do drivers improve?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4(
    type VARCHAR(9),
    number INTEGER,
    early FLOAT,
    late FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS TenDays CASCADE;
DROP VIEW IF EXISTS RatingsPerDay CASCADE;
DROP VIEW IF EXISTS DriverEarlyReviews CASCADE;
DROP VIEW IF EXISTS DriverLaterReviews CASCADE;
DROP VIEW IF EXISTS TrainedStats CASCADE;
DROP VIEW IF EXISTS UntrainedStats CASCADE;

-- Define views here 
create view TenDays as
    select driver_id
    from ClockedIn c join Dispatch d on c.shift_id = d.shift_id
    group by driver_id
    having count(distinct datetime::date) >= 10;

create view RatingsPerDay as 
    select driver_id, d.datetime::date as date, sum(rating) as sum_rating, count(rating) as count_rating
    from DriverRating dr, Dispatch d, (ClockedIn natural join TenDays) c
    where d.request_id = dr.request_id and d.shift_id = c.shift_id
    group by driver_id, datetime::date
    order by datetime::date asc; -- important! 

create view DriverEarlyReviews as
    select sum(sum_rating) as sum_rating, sum(count_rating) as count_rating, driver_id 
    from RatingsPerDay
    group by driver_id
    limit 5;

create view DriverLaterReviews as
    select sum(sum_rating) as sum_rating, sum(count_rating) as count_rating, driver_id 
    from RatingsPerDay
    group by driver_id
    limit ALL offset 5;

create view TrainedStats as
    select 'trained' as type, count(*) as number, 
            sum(de.sum_rating) / sum(de.count_rating) as early
            sum(dl.sum_rating) / sum(dl.count_rating) as late
    from DriverEarlyReviews de join DriverLaterReviews dl on de.driver_id = dl.driver_id
    where de.driver_id in (select * driver_id from Drivers where trained = TRUE);

create view UntrainedStats as 
    select 'untrained' as type, count(*) as number, 
            sum(de.sum_rating) / sum(de.count_rating) as early
            sum(dl.sum_rating) / sum(dl.count_rating) as late
    from DriverEarlyReviews de join DriverLaterReviews dl on de.driver_id = dl.driver_id
    where de.driver_id in (select * driver_id from Drivers where trained = FALSE);

INSERT INTO q4
    (TrainedStats) UNION (UntrainedStats);

-- UNTESTED 