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


-- Define views for your intermediate steps here:

-- rides whose request pick up and drop off are on the same day 
Create view SameDayRides As
select pickup.datetime::date as date, dropoff.datetime - pickup.datetime as ride_duration
from pickup, dropoff
where (pickup.request_id = dropoff.request_id)
      and 
      (pickup.datetime::date = dropoff.datetime::date);

-- get the driver for each ride by going SameDayRides -> Dispatch -> Shift_id -> ClockedIn -> ClockedIn.driver_id
Create view 

-- group by driver and day and sum up the ride durations 

-- find drivers and days who violate the bylaw 

-- Your query that answers the question goes below the "insert into" line:

-- find the driver who has three violating days in a row (cartesian product 3 tuples into the same row )
INSERT INTO q3 