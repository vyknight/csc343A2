-- Scratching backs?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q8 CASCADE;

CREATE TABLE q8(
    client_id INTEGER,
    reciprocals INTEGER,
    difference FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Reciprocals CASCADE;
DROP VIEW IF EXISTS ReciprocalsWithID;

-- Define views for your intermediate steps here:
-- reciprocals 
create view Reciprocals as
    select ClientRating.rating as crate, DriverRating.rating as drate, ClientRating.request_id as request_id 
    from ClientRating join DriverRating on ClientRating.request_id = DriverRating.request_id;

-- inserting client id
create view ReciprocalsWithID as
    select abs(crate - drate) as difference, client_id
    from reciprocals natural join request;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q8
    select client_id, count(*) as reciprocals, avg(difference) as difference
    from reciprocalsWithID
    group by client_id;

-- TESTED 
