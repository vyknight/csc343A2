-- Lure them back.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2(
    client_id INTEGER,
    name VARCHAR(41),
  	email VARCHAR(30),
  	billed FLOAT,
  	decline INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS FiveHundo CASCADE;
DROP VIEW IF EXISTS OneToTenRides CASCADE;
DROP VIEW IF EXISTS FewerRides CASCADE;
DROP VIEW IF EXISTS Rides CASCADE; 


-- Define views for your intermediate steps here:

-- successful rides (requests that has a matching dropped off)
Create View Rides as 
	select Request.request_id as request_id, client_id, request.datetime as datetime
	from request join dropoff on request.request_id = dropoff.request_id;


-- clients who had 1 to 10 rides in 2020
Create View OneToTenRides as
	select c.client_id as client_id
	from client c join Rides r on c.client_id = r.client_id
	where r.datetime::date >= '2020-01-01'::date and r.datetime < '2021-01-01'::date
	group by c.client_id
	having count(*) >= 1 and count(*) <= 10;
	-- count(*) >= 1 is actually redundant because to pass the join filter one need to have at least 1 request 

-- clients who had spent 500$ in total before 2020
-- assuming that's what the rather ambiguous question was asking for 
Create View FiveHundo As 
	select client_id, sum(amount) as billed
	from request join billed on billed.request_id = request.request_id
	where request.datetime::date < '2020-01-01'::date 
	group by client_id
	having sum(amount) >= 500;

-- clients who had fewer rides in 2021 than in 2020 
Create View FewerRides As 
	select twenty.client_id as client_id, twenty.numRides - twentyone.numRides as decline
	from 
		(select client_id, count(*) as numRides 
			from rides 
			where datetime::date >= '2020-01-01'::date 
				and datetime::date < '2021-01-01'::date
			group by client_id) twenty
		join 
		(select client_id, count(*) as numRides 
			from rides 
			where datetime::date >= '2021-01-01'::date 
				and datetime < '2022-01-01'::date
			group by client_id) twentyone
		on twenty.client_id = twentyone.client_id
	where twenty.numRides > twentyone.numRides; 


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
	Select client_id, CONCAT(firstname, ' ', surname) as name, 
		Coalesce(email, 'unknown') as email, billed, decline
	from ((OneToTenRides natural join FiveHundo) natural join FewerRides) natural join client;

-- TESTED