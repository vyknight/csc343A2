-- Consistent raters.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q9 CASCADE;

CREATE TABLE q9(
    client_id INTEGER,
    email VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS ClientAndDriver CASCADE;
DROP VIEW IF EXISTS RatingWithIDs CASCADE;
DROP VIEW IF EXISTS ClientsWhoDontRateEveryDriver CASCADE; 


-- Define views for your intermediate steps here:
-- client with every driver he's been with
create view ClientAndDriver as
    select client_id, driver_id
    from request, dispatch, dropoff, ClockedIn 
    -- dropoff included for those edge cases where there's a dispatch but the ride doens't go through 
    where request.request_id = dispatch.request_id
            and dispatch.shift_id = ClockedIn.shift_id
            and dispatch.request_id = dropoff.request_id;

-- linking driver with client rating
create view RatingWithIDs as
    select clockedin.driver_id as driver_id, request.client_id as client_id
    from DriverRating, Request, Dispatch, ClockedIn
    where DriverRating.request_id = Request.request_id
            and DriverRating.request_id = Dispatch.request_id
            and Dispatch.shift_id = ClockedIn.shift_id
    group by client_id, driver_id;
    
-- remember the old example of how we got a list of all the courses that aren't int the same semester 
-- clients who didn't rate every driver 
create view ClientsWhoDontRateEveryDriver as  
    select cd.client_id
    from ClientAndDriver cd
    where not exists (select * from RatingWithIds r 
    			where r.driver_id = cd.driver_id and r.client_id = cd.client_id);
    
    
  --  * from ((select * from ClientAndDriver) except (select * from RatingWithIDs)) a;
-- since we have one tuple for every single client and driver in ride pair and one tuple for every single client and driver in rating pair
-- they should cancel out 

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q9
    select c.client_id, email
    from (select distinct client.client_id, email 
    		from client join ClientAndDriver 
    		on client.client_id = ClientAndDriver.client_id) c
    where not exists 
    	 (select * from ClientsWhoDontRateEveryDriver d 
    	  where c.client_id = d.client_id);

-- TESTED

