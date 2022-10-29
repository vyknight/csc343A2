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
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- #### USE LIMITS TO GET THE TOP 5 RESULTS XXDDDDD

-- Define views for your intermediate steps here:
create view TenDayDrivers as 
    select driver_id
    from ClockedIn join dispatch on clockedin.shift_id = dispatch.shift_id 
    -- this is to make sure that rides actually happened in these shifts
    group by driver_id
    having count(distinct datetime::date) >= 10;

-- create view RatingPerDayWithUnqualifiedDrivers as
--     select driver_id, datetime::date as date, sum(rating) as sum_rating, count(rating) as count_rating 
--     from DriverRating, Dispatch, ClockedIn
--     where DriverRating.request_id = Dispatch.request_id and Dispatch.shift_id = ClockedIn
--     group by driver_id, datetime::date;

-- create view RatingPerDay as
--     select * from RatingPerDayWithUnqualifiedDrivers natural join TenDayDrivers;

create view EarlyDays as
    select driver_id,  
    from RatingPerDay
    group by driver_id
    order by date [ASC];

-- create view FirstDay as 
--     select driver_id, date, sum_rating, count_rating
--     from RatingPerDay
--     group by driver_id
--     having min(date);

-- create view RatingPerDayAfterFirst as
--     (RatingPerDay) except (FirstDay);

-- create view SecondDay as
--     select driver_id, date, sum_rating, count_rating
--     from RatingPerDayAfterFirst
--     group by driver_id
--     having min(date);

-- create view RatingPerDayAfterSecond as
--     (RatingPerDayAfterFirst) except (SecondDay);

-- create view ThirdDay as
--     select driver_id, date, sum_rating, count_rating
--     from RatingPerDayAfterSecond
--     group by driver_id
--     having min(date);

-- create view RatingPerDayAfterThird as 
--     (RatingPerDayAfterSecond) except (ThirdDay);

-- create view FourthDay as
--     select driver_id, date, sum_rating, count_rating
--     from RatingPerDayAfterThird
--     group by driver_id
--     having min(date);

-- create view RatingPerDayAfterFourth as 
--     (RatingPerDayAfterThird) except (FourthDay);

-- create view FifthDay as
--     select driver_id, date, sum_rating, count_rating
--     from RatingPerDayAfterFourth
--     group by driver_id
--     having min(date);

-- create view RatingsLaterDays as 
--     (RatingPerDayAfterFourth) except (FifthDay)

-- create view EarlyDays as
--     (((FirstDay) UNION (SecondDay)) UNION ((ThirdDay) UNION (FourthDay))) UNION (FifthDay);

-- create view AverageEarlyDays as
--     select trained, sum(sum_rating) / sum(count_rating) as average_rating
--     from (EarlyDays join Driver on EarlyDays.driver_id = Drier.driver_id)
--     group by trained

-- Your query that answers the question goes below the "insert into" line:

-- unfinished, I suspect that there is something I'm missing that will make all of this really simple. Something to do with aggregation and ordering. Otherwise it would be extraordinarily difficult to implement the average is null thing unless something is built to handle it 