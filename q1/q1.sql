-- Months.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    client_id INTEGER,
    email VARCHAR(30),
    months INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
    select Client.client_id, email, count(distinct to_char(Request.datetime, 'MON YYYY'))
    from Client 
    	left join 
    	(Request join Dropoff on request.request_id = dropoff.request_id) 
    	on Client.client_id = Request.client_id 
    group by client.client_id;
