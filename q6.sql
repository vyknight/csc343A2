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
DROP VIEW IF EXISTS clientYearlyRidesM CASCADE;
DROP VIEW IF EXISTS noRidesThatYear CASCADE;
DROP VIEW IF EXISTS clientsAndYears CASCADE;
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

create view clientYearlyRidesM as 
    select client_id, to_char(datetime, 'YYYY') as year, count(*) as rides
    from Rides
    group by client_id, to_char(datetime, 'YYYY');

-- if i used limits here i can't account for the fact that there might be ties

-- add 0 for clients who didn't ride that year
create view clientsAndYears as
	select *
	from (select client_id from client) c, (select year from clientYearlyRidesM) y;

create view noRidesThatYear as 
	select c.client_id as client_id, c.year as year, integer '0' as rides
	from clientsAndYears c
	where not exists (select * from clientYearlyRidesM m where c.client_id = m.client_id and c.year = m.year) ;
	
create view clientYearlyRides as
	select *
	from (select * from clientYearlyRidesM) a union (select * from noRidesThatYear);

create view TopOne as
    select *
    from clientYearlyRides
    group by client_id, year, rides
    having rides = (select max(rides) from clientYearlyRides);

create view TopTwo as 
    select * 
    from clientYearlyRides
    group by client_id, year, rides
    having rides = (select max(rides) from ((select * from clientYearlyRides) except (select * from TopOne)) b);

create view TopThree as 
    select *
    from clientYearlyRides
    group by client_id, year, rides
    having rides = (select max(rides) from ((select * from clientYearlyRides) except (select * from ((select * from TopOne) UNION (select * from TopTwo)) a )) as b);

create view BottomOne as
    select *
    from clientYearlyRides
    group by client_id, year, rides
    having rides = (select min(rides) from clientYearlyRides);

create view BottomTwo as 
    select * 
    from clientYearlyRides
    group by client_id, year, rides
    having rides = (select min(rides) from ((select * from clientYearlyRides) except (select * from BottomOne)) b);

create view BottomThree as 
    select *
    from clientYearlyRides
    group by client_id, year, rides
    having rides = (select min(rides) from ((select * from clientYearlyRides) except (select * from ((select * from BottomOne) UNION (select * from BottomTwo)) a )) as b);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6
    ((select * from TopOne) UNION (select * from TopTwo)
         UNION 
    (select * from TopThree) UNION (select * from BottomOne))
     UNION 
    (select * from BottomTwo) UNION (select * from BottomThree);
    -- USING UNION INSTEAD OF UNION ALL HERE BECAUSE EVEN THOUGH SOMEONE WITH TOP 3RD AND BOTTOM 3RD RIDES 
    -- THEY SHOULDN'T SHOW UP TWICE FOR THE SAME COMBINATION

-- TESTED 
