-- Rest bylaw.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3(
    driver_id INTEGER,
    start DATE,
    driving INTERVAL,
    breaks INTERVAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS SameDayRides CASCADE;
DROP VIEW IF EXISTS RidesWithDrives CASCADE;
DROP VIEW IF EXISTS DriverDurationByDay CASCADE;
DROP VIEW IF EXISTS NotEnoughBreaks CASCADE;
DROP VIEW IF EXISTS Breaks CASCADE;

-- Define views for your intermediate steps here:

-- rides whose request pick up and drop off are on the same day 
Create view SameDayRides As
select 
    pickup.datetime::date as date, 
    dropoff.datetime - pickup.datetime as ride_duration, 
    pickup.request_id as request_id
from pickup, dropoff
where (pickup.request_id = dropoff.request_id)
      and 
      (pickup.datetime::date = dropoff.datetime::date);

-- get the driver for each ride by going SameDayRides -> Dispatch -> Shift_id -> ClockedIn -> ClockedIn.driver_id
Create view RidesWithDrivers as 
    select 
        ClockedIn.driver_id as driver_id, 
        SameDayRides.date as date, 
        SameDayRides.ride_duration as ride_duration
    from SameDayRides, Dispatch, ClockedIn
    where 
        (SameDayRides.request_id = Dispatch.request_id) 
        and 
        (Dispatch.shift_id = ClockedIn.shift_id);

-- group by driver and day and sum up the ride durations 
Create view DriverDurationByDay as 
    select driver_id, date, sum(ride_duration) as total_ride_duration
    from RidesWithDrivers
    group by driver_id, date
    having sum(ride_duration) >= INTERVAL '12' hours; -- check to make sure that this is is how you do interval comparisons

-- figure out which pick ups and drop offs happened on the same day, find duration 
create view Breaks as 
    select pickup.request_id as prid, 
            dropoff.request_id as drid, 
            pickup.datetime::date as date,
            pickup.datetime - dropoff.datetime as duration
    from pickup, dropoff
    where (pickup.datetime > dropoff.datetime) 
            and (pickup.datetime::date = dropoff.datetime::date)

-- figure out which of the above are by the same driver 
-- sum up the ride duration of each driver per day (group by driver and date), find those with <15 min

-- find drivers who had not enough breaks and the date where they didn't have enough breaks 
Create view NotEnoughBreaks as 
    select driver_id, date
    from 


-- find drivers and days who violate the bylaw 

-- Your query that answers the question goes below the "insert into" line:

-- find the driver who has three violating days in a row (cartesian product 3 tuples into the same row )
INSERT INTO q3 