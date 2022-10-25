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
DROP VIEW IF EXISTS BreaksWithPickupDriverID CASCADE;
DROP VIEW IF EXISTS DriverBreaks CASCADE;
DROP VIEW IF EXISTS Violators CASCADE;

-- Define views for your intermediate steps here:

-- Duration ##############

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

-- group by driver and day and sum up the ride durations, keep those with over 12 hours only
Create view DriverDurationByDay as 
    select driver_id, date, sum(ride_duration) as total_ride_duration
    from RidesWithDrivers
    group by driver_id, date
    having sum(ride_duration) >= INTERVAL '12' hours; -- check to make sure that this is is how you do interval comparisons

-- Breaks #############

-- figure out which pick ups and drop offs happened on the same day, find duration 
create view Breaks as 
    select pickup.request_id as prid, 
            dropoff.request_id as drid, 
            pickup.datetime::date as date,
            pickup.datetime - dropoff.datetime as duration
    from pickup, dropoff
    where (pickup.datetime > dropoff.datetime) 
            and (pickup.datetime::date = dropoff.datetime::date);

-- figure out which of the above are by the same driver 
-- I think I can do it all in the same query using subquerires but that's slightly harder so I won't do it
-- Also assuming that breaks happen within a shift, the instructions were a little ambiguous on whether these breaks can cross shifts. 
create view BreaksWithPickupDriverID as 
    select ClockedIn.driver_id as pdriver, drid, date, duration
    from Breaks, Dispatch, ClockedIn
    where (prid = request_id) and (Dispatch.shift_id = ClockedIn.shift_id);


-- sum up the ride duration of each driver per day (group by driver and date), find those with <=15 min breaks 
create view DriverBreaks as 
    select pdriver as driver_id, date, sum(duration) as break_duration
    from BreaksWithPickupDriverID, Dispatch, ClockedIn
    where (BreaksWithPickupDriverID.drid = Dispatch.request_id)
            and (Dispatch.shift_id = ClockedIn.shift_id)
            and (BreaksWithPickupDriverID.pdriver = ClockedIn.driver_id)
    group by pdriver, date
    having sum(duration) <= interval '15' minute;

-- find drivers who had not enough breaks and the date where they didn't have enough breaks 
Create view NotEnoughBreaks as 
    select DriverBreaks.driver_id as driver_id,
            DriverBreaks.date as date,
            break_duration,
            total_ride_duration 
    from DriverBreaks, DriverDurationByDay 
    where (DriverBreaks.date = DriverDurationByDay.date)
            and (DriverBreaks.driver_id = DriverDurationByDay.driver_id);

-- find drivers and days who violate the bylaw
Create view Violators as 
    select *
    from NotEnoughBreaks as n1, NotEnoughBreaks as n2, NotEnoughBreaks as n3
    where (n1.driver_id = n2.driver_id)
            and (n2.driver_id = n3.driver_id)
            and (n1.date + INTERVAL '1' day = n2.date)
            and (n2.date + INTERVAL '1' day = n3.date);
    

-- Your query that answers the question goes below the "insert into" line:

-- find the driver who has three violating days in a row (cartesian product 3 tuples into the same row )
INSERT INTO q3 
    select n1.driver_id as driver_id, 
            n1.date as start,
            n1.total_ride_duration + n2.total_ride_duration + n3.total_ride_duration as driving
            n1.break_duration + n2.break_duration + n3.break_duration as breaks
    from Violators;

-- NOT TESTED 
-- Only drivers who fit our description should be able to make it into any of these views
-- Duplicates should be covered by the day interval check in Violators 