-- Frequent riders.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6(
    client_id INTEGER,
    year CHAR(4),
    rides INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Rides CASCADE;
DROP VIEW IF EXISTS clientYearlyRides CASCADE;
DROP VIEW IF EXISTS TopOne CASCADE;
DROP VIEW IF EXISTS TopTwo CASCADE;
DROP VIEW IF EXISTS TopThree CASCADE;
DROP VIEW IF EXISTS BottomOne CASCADE;
DROP VIEW IF EXISTS BottomTwo CASCADE;
DROP VIEW IF EXISTS BottomThree CASCADE;


-- Define views for your intermediate steps here:
create view Rides as
    select request.client_id as client_id, request.datetime as datetime
    from request join dropoff on request.request_id = dropoff.request_id;

create view clientYearlyRides as 
    select client_id, to_char(datetime, 'YYYY') as year, sum(*) as rides
    from Rides
    group by client_id, to_char(datetime, 'YYYY');

create view TopOne as
    select *
    from clientYearlyRides
    where rides = max(rides)

create view TopTwo as 
    select * 
    from (clientYearlyRides except (select * from TopOne)) as temp
    where rides = max(temp.rides);

create view TopThree as 
    select *
    from (clientYearlyRides except (select * from (TopOne UNION TopTwo)) as temp
    where rides = max(temp.rides);

create view BottomOne as
    select *
    from clientYearlyRides
    where rides = min(rides);

create view BottomTwo as 
    select * 
    from (clientYearlyRides except (select * from BottomOne)) as temp
    where rides = min(temp.rides);

create view BottomThree as 
    select *
    from (clientYearlyRides except (select * from (BottomOne UNION BottomTwo))) as temp
    where rides = min(tmep.rides);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6
    TopOne UNION TopTwo UNION TopThree UNION BottomOne UNION BottomTwo UNION BottomThree;

-- UNTESTED
